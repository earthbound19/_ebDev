#!/usr/bin/env python3
# DESCRIPTION
"""
PyBFXR2.py - Bfxr-style explosion sound generator

A Python implementation of the bfxr explosion sound effect generator,
based on increpare/bfxr2. Generates explosive / noise-type sounds
with customizable and / or random parameters (switches).

DEPENDENCIES
    Python 3.6+
    numpy (pip install numpy)
    soundfile (pip install soundfile)
    osc_gen (pip install osc-gen)

USAGE
    python PyBFXR2.py [OPTIONS]
    see python PyBFXR2.py --help and the print_help() function just below.

REFERENCE
original sfxr at: https://www.drpetter.se/project_sfxr.html
purported source code (ganked somehow?):
https://github.com/grimfang4/sfxr/tree/master
javascript port with more features:
https://www.bfxr.net/ - source: https://github.com/increpare/bfxr2, and:
https://github.com/increpare/bfxr2/blob/master/js/synths/Bfxr.js
https://github.com/increpare/bfxr2/blob/master/js/audio/Bfxr_DSP.js
These last two were referenced in developing this.
"""

def print_help():
    """Print detailed help text"""
    help_text = """
PYBFXR2 - Complete Parameter Guide
====================================

This script generates Bfxr-style explosion sounds with extensive
parameter control. All parameters can be randomized by default,
or fixed values can be provided.

GENERAL OPTIONS:
  -h, --help              Show this help message
  -v, --version           Show version information
  -o FILE, --output FILE  Output WAV file (for single sound or --one-shot)
  --spacing SECONDS       Spacing between sound starts in one-shot mode (default: back-to-back)
  -s, --seed SEED         Random seed for reproducible results
  --sample-rate RATE      Sample rate in Hz (default: 44100)
  --variations N          Generate N variations (default: 1)
  --one-shot              Place all variations sequentially into one WAV file

WAVEFORM OPTIONS:
  --waveform {white,bitnoise}
                          Noise type (default: white)

PITCH OPTIONS:
  --freq-start VALUE      Starting frequency (0.0-1.0, default: random)
                            overrides freq. min and max as noted below
  --freq-min VALUE        Minimum frequency for randomization (0.0-1.0, default: 0.0)
                            only used when --freq-start is not specified
  --freq-max VALUE        Maximum frequency for randomization (0.0-1.0, default: 1.0)
                            only used when --freq-start is not specified
  --freq-slide VALUE      Frequency slide (-0.5 to 0.5, default: random)
                            causes pitch to go up or down over time

ENVELOPE OPTIONS:
  --sustain VALUE         Sustain time (0.0-1.0, default: random)
  --decay VALUE           Decay/release time (0.0-1.0, default: random)
  --punch VALUE           Attack punch (0.0-1.0, default: random)

EFFECTS OPTIONS:
  --flanger-offset VALUE  Flanger offset (-1.0 to 1.0, default: 0)
  --flanger-sweep VALUE   Flanger sweep (-1.0 to 1.0, default: 0)
  --pitch-jump-speed VALUE  Pitch jump speed (0.0-1.0, default: 0)
  --pitch-jump-amount VALUE  Pitch jump amount (-1.0 to 1.0, default: 0)
  --compression VALUE     Compression amount (0.0-1.0, default: 0)

BLEND OPTIONS:
  --blend-sine PERCENT    Sine blend percentage (0-100, default: 0)
  --blend-saw PERCENT     Sawtooth blend percentage (0-100, default: 0)
  --blend-freq HZ         Blend frequency in Hz (default: 60)

NOTES:
- if --freq-start is specified, it ignores --freq-min and --freq-max (fixed frequency)
- if --freq-start is NOT specified, it randomizes within [freq-min, freq-max]
- if only one of min/max is specified, the other defaults to 0.0 or 1.0
- if min > max, they're swapped

Frequency translation:
freq	Squared     Period (samples)	Frequency (Hz) at 44.1kHz
0.0     0.0         100000              ~0.44 Hz (inaudible)
0.1     0.01    	9090	            ~4.85 Hz
0.2     0.04    	2439	            ~18 Hz
0.3     0.09        1101            	~40 Hz
0.4     0.16        621                 ~71 Hz
0.5     0.25        398                 ~110 Hz
0.6     0.36        277                 ~159 Hz
0.7     0.49        203                 ~217 Hz
0.8     0.64        156                 ~282 Hz
0.9     0.81        123                 ~358 Hz
1.0     1.0         99                  ~445 Hz
"""
    print(help_text)

# CODE
import argparse
import sys
import os
import random
import string
from datetime import datetime
import numpy as np
import soundfile as sf
from osc_gen import sig
from osc_gen import dsp

# Version
__version__ = "1.1.8"


# ============================================================================
# SYNTHESIS ENGINE
# ============================================================================

class BfxrExplosion:
    """Bfxr-style explosion synthesizer"""
    
    def __init__(self, params):
        """
        Initialize with parameters dictionary
        
        Parameters:
            params: dict with keys:
                - sample_rate: int
                - waveform: 'white' or 'bitnoise'
                - freq_start: float (0.0-1.0, maps to 20-2000Hz)
                - freq_slide: float (-0.5 to 0.5)
                - sustain: float (0.0-1.0)
                - decay: float (0.0-1.0)
                - punch: float (0.0-1.0)
                - flanger_offset: float (-1.0 to 1.0)
                - flanger_sweep: float (-1.0 to 1.0)
                - pitch_jump_speed: float (0.0-1.0)
                - pitch_jump_amount: float (-1.0 to 1.0)
                - blend_sine: float (0-100, percentage)
                - blend_saw: float (0-100, percentage)
                - blend_freq: float (Hz)
                - seed: int or None
        """
        self.params = params
        self.sample_rate = params.get('sample_rate', 44100)
        self.seed = params.get('seed')
        
        # Set random seed if provided
        if self.seed is not None:
            random.seed(self.seed)
            np.random.seed(self.seed)

    def generate(self):
        """Generate an explosion sound using Bfxr's actual DSP algorithm"""
        
        # Map parameters (matching Bfxr's internal calculations)
        freq_start = self.params.get('freq_start', 0.3)
        freq_start = freq_start * freq_start  # Squared like Bfxr
        
        # frequency_period_samples = 100.0 / (freq_start^2 + 0.001)
        period_samples = int(100.0 / (freq_start * freq_start + 0.001))
        if period_samples < 8:
            period_samples = 8
        
        freq_slide = self.params.get('freq_slide', -0.2)
        # slide = 1.0 - freq_slide^3 * 0.01
        slide = 1.0 - abs(freq_slide) * abs(freq_slide) * abs(freq_slide) * 0.01
        
        # Get envelope parameters (matching Bfxr's calculations)
        attack_time = self.params.get('attackTime', 0.0)
        sustain_time = self.params.get('sustainTime', 0.3)
        decay_time = self.params.get('decayTime', 0.4)
        sustain_punch = self.params.get('sustainPunch', 0.0)
        
        # Envelope lengths in samples (matching Bfxr's math)
        attack_samples = int(attack_time * attack_time * 100000.0)
        sustain_samples = int(sustain_time * sustain_time * 100000.0)
        decay_samples = int(decay_time * decay_time * 100000.0 + 10)
        total_samples = attack_samples + sustain_samples + decay_samples
        
        # Clamp to reasonable length
        if total_samples < 8000:  # ~0.18 seconds at 44.1kHz
            scale = 8000.0 / total_samples
            attack_samples = int(attack_samples * scale)
            sustain_samples = int(sustain_samples * scale)
            decay_samples = int(decay_samples * scale)
            total_samples = attack_samples + sustain_samples + decay_samples
        
        # Pre-calculate envelope
        envelope = np.zeros(total_samples)
        phase_samples = 0
        
        # Attack phase: 0 to 1
        if attack_samples > 0:
            envelope[:attack_samples] = np.linspace(0, 1, attack_samples)
            phase_samples += attack_samples
        
        # Sustain phase: 1 with punch boost
        if sustain_samples > 0:
            # Punch boosts the sustain: 1.0 + (1.0 - t) * 2.0 * sustainPunch
            t = np.linspace(0, 1, sustain_samples)
            sustain_vals = 1.0 + (1.0 - t) * 2.0 * sustain_punch
            envelope[phase_samples:phase_samples + sustain_samples] = sustain_vals
            phase_samples += sustain_samples
        
        # Decay phase: 1 to 0
        if decay_samples > 0:
            envelope[phase_samples:phase_samples + decay_samples] = np.linspace(1, 0, decay_samples)
            phase_samples += decay_samples
        
        # Generate sound
        buffer = np.zeros(total_samples)
        
        # Oscillator state
        phase = 0
        period = period_samples
        slide_current = slide
        
        # Noise buffers (matching Bfxr's approach)
        noise_buffer = np.random.randn(32) * 2 - 1
        lores_buffer = np.zeros(32)
        
        # Bitnoise state (SN76489 style LFSR)
        bitnoise_state = 1 << 14
        bitnoise_sample = 0.0  # Initialize with a default value
        
        # Filter state
        lp_pos = 0.0
        lp_delta = 0.0
        hp_pos = 0.0
        lp_cutoff = 0.0
        hp_cutoff = 0.0
        
        # Bitcrush state
        bitcrush_phase = 0.0
        bitcrush_last = 0.0
        
        # Determine waveform type
        waveform = self.params.get('waveform', 'white')
        
        for i in range(total_samples):
            # Apply slide and acceleration (simplified)
            slide_current += 0.0  # frequency_acceleration would go here
            period = int(period_samples * slide_current)
            if period < 8:
                period = 8
            
            # Advance phase
            phase += 1
            if phase >= period:
                phase = phase - period
                # Regenerate noise for the next period (like Bfxr)
                noise_buffer = np.random.randn(32) * 2 - 1
                # Bitnoise update (SN76489 style)
                feed_bit = ((bitnoise_state >> 1) & 1) ^ (bitnoise_state & 1)
                bitnoise_state = (bitnoise_state >> 1) | (feed_bit << 14)
                bitnoise_sample = (~bitnoise_state & 1) - 0.5
            
            # Get sample based on waveform type
            if waveform == 'bitnoise':
                sample = bitnoise_sample
            else:
                # White noise - use noise buffer
                idx = int((phase * 32 / period)) % 32
                sample = noise_buffer[idx]
            
            # Apply compression
            compression = self.params.get('compression', 0)
            if compression > 0:
                factor = 1.0 / (1.0 + 4.0 * compression)
                if sample > 0:
                    sample = sample ** factor
                else:
                    sample = -((-sample) ** factor)
            
            # Apply envelope
            sample = sample * envelope[i]
            
            # Apply master volume
            master_volume = self.params.get('masterVolume', 0.5)
            sample = sample * master_volume * master_volume
            
            # Simple soft clipping
            sample = np.clip(sample, -1.0, 1.0)
            
            buffer[i] = sample
        
        # Trim silence
        threshold = 0.001
        non_silent = np.where(np.abs(buffer) > threshold)[0]
        if len(non_silent) > 0:
            end_sample = non_silent[-1] + 100
            buffer = buffer[:min(end_sample + 1000, len(buffer))]
        
        # Normalize
        max_val = np.max(np.abs(buffer))
        if max_val > 0:
            buffer = buffer / max_val
        
        return buffer

# ============================================================================
# FILE NAMING AND LOGGING UTILITIES
# ============================================================================

def generate_filename(sound_type="EXPLOSION"):
    """Generate a unique filename in the format:
    yyyy_mm_dd_<sound_type>_hh_mm_ss_ms_<4random>_PyBFXR2.wav
    """
    now = datetime.now()
    timestamp = now.strftime("%Y_%m_%d_%H_%M_%S")
    milliseconds = f"{now.microsecond // 1000:03d}"
    random_chars = ''.join(random.choices(string.ascii_uppercase + string.digits, k=4))
    base = f"{timestamp}_{milliseconds}_{sound_type}_{random_chars}_PyBFXR2"
    return base


def log_parameters(filename_base, params_list, sound_durations, is_one_shot=False):
    """Write parameter logs to a .txt file"""
    log_filename = f"{filename_base}.txt"
    
    with open(log_filename, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("PyBFXR2 PARAMETER LOG\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"One-shot mode: {is_one_shot}\n")
        if is_one_shot:
            f.write(f"Number of sounds: {len(params_list)}\n")
            f.write(f"Spacing between starts: {params_list[0].get('spacing', 'N/A')}s\n")
        f.write("=" * 80 + "\n\n")
        
        for i, params in enumerate(params_list):
            f.write(f"--- SOUND {i+1} ---\n")
            f.write(f"Duration (actual): {sound_durations[i]:.3f}s\n")
            f.write(f"Seed: {params.get('seed', 'Random')}\n")
            f.write("\nPARAMETERS:\n")
            param_names = [
                'waveform', 'freq_start', 'freq_slide', 'sustain', 'decay', 
                'punch', 'flanger_offset', 'flanger_sweep', 'pitch_jump_speed',
                'pitch_jump_amount', 'compression', 'blend_sine', 'blend_saw', 
                'blend_freq', 'spacing'
            ]
            for name in param_names:
                if name in params:
                    f.write(f"  {name}: {params[name]}\n")
            f.write("\n")
        
        f.write("=" * 80 + "\n")
        f.write("END OF LOG\n")


# ============================================================================
# CLI IMPLEMENTATION
# ============================================================================

def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="PyBFXR2 - Bfxr-style explosion sound generator",
        add_help=False
    )
    
    # General options
    parser.add_argument('-h', '--help', action='store_true',
                       help='Show this help message')
    parser.add_argument('-v', '--version', action='store_true',
                       help='Show version information')
    parser.add_argument('-o', '--output', default=None,
                       help='Output WAV file (for single sound or --one-shot)')
    parser.add_argument('--spacing', type=float, default=None,
                       help='Spacing between sound starts in one-shot mode')
    parser.add_argument('-s', '--seed', type=int, default=None,
                       help='Random seed for reproducible results')
    parser.add_argument('--sample-rate', type=int, default=44100,
                       help='Sample rate in Hz (default: 44100)')
    parser.add_argument('--variations', type=int, default=1,
                       help='Number of variations to generate (default: 1)')
    parser.add_argument('--one-shot', action='store_true',
                       help='Place all variations sequentially into one WAV file')
    
    # Waveform options
    parser.add_argument('--waveform', choices=['white', 'bitnoise'], 
                       default='white',
                       help='Noise type (default: white)')
    
    # Pitch options
    parser.add_argument('--freq-start', type=float, default=None,
                       help='Starting frequency (0.0-1.0)')
    parser.add_argument('--freq-min', type=float, default=None,
                       help='Minimum frequency for randomization (0.0-1.0)')
    parser.add_argument('--freq-max', type=float, default=None,
                       help='Maximum frequency for randomization (0.0-1.0)')
    parser.add_argument('--freq-slide', type=float, default=None,
                       help='Frequency slide (-0.5 to 0.5)')
    
    # Envelope options
    parser.add_argument('--sustain', type=float, default=None,
                       help='Sustain time (0.0-1.0)')
    parser.add_argument('--decay', type=float, default=None,
                       help='Decay/release time (0.0-1.0)')
    parser.add_argument('--punch', type=float, default=None,
                       help='Attack punch (0.0-1.0)')
    
    # Effects options
    parser.add_argument('--flanger-offset', type=float, default=None,
                       help='Flanger offset (-1.0 to 1.0)')
    parser.add_argument('--flanger-sweep', type=float, default=None,
                       help='Flanger sweep (-1.0 to 1.0)')
    parser.add_argument('--pitch-jump-speed', type=float, default=None,
                       help='Pitch jump speed (0.0-1.0)')
    parser.add_argument('--pitch-jump-amount', type=float, default=None,
                       help='Pitch jump amount (-1.0 to 1.0)')
    parser.add_argument('--compression', type=float, default=None,
                       help='Compression amount (0.0-1.0)')
    
    # Blend options
    parser.add_argument('--blend-sine', type=float, default=None,
                       help='Sine blend percentage (0-100)')
    parser.add_argument('--blend-saw', type=float, default=None,
                       help='Sawtooth blend percentage (0-100)')
    parser.add_argument('--blend-freq', type=float, default=60,
                       help='Blend frequency in Hz (default: 60)')
    
    return parser.parse_args()


def get_params_from_args(args, variation_index=0):
    """Convert CLI arguments to parameter dictionary with randomization"""
    
    def rand_or_fixed(value, min_val, max_val, default=None):
        if value is not None:
            return value
        if default is not None:
            return default
        return min_val + random.random() * (max_val - min_val)
    
    params = {
        'sample_rate': args.sample_rate,
        'waveform': args.waveform,
        'seed': args.seed + variation_index if args.seed is not None else None,
        'spacing': args.spacing,
    }
    
    # Pitch parameters - with min/max support
    if args.freq_start is not None:
        # Fixed frequency - ignore min/max
        params['freq_start'] = max(0.0, min(1.0, args.freq_start))
    else:
        # Random frequency within min/max range
        freq_min = args.freq_min if args.freq_min is not None else 0.0
        freq_max = args.freq_max if args.freq_max is not None else 1.0
        # Clamp min/max to valid range
        freq_min = max(0.0, min(1.0, freq_min))
        freq_max = max(0.0, min(1.0, freq_max))
        # Ensure min <= max
        if freq_min > freq_max:
            freq_min, freq_max = freq_max, freq_min
        # Random within range (same distribution as before, just clamped)
        params['freq_start'] = freq_min + random.random() * (freq_max - freq_min)
    
    if args.freq_slide is not None:
        params['freq_slide'] = max(-0.5, min(0.5, args.freq_slide))
    else:
        if random.random() < 0.5:
            params['freq_slide'] = -0.1 + random.random() * 0.4
        else:
            params['freq_slide'] = -0.2 - random.random() * 0.2
    
    # Envelope parameters
    params['sustain'] = rand_or_fixed(args.sustain, 0.0, 1.0, 0.3)
    params['decay'] = rand_or_fixed(args.decay, 0.0, 1.0, 0.5)
    params['punch'] = rand_or_fixed(args.punch, 0.0, 1.0, 0.5)
    
    # Effects
    params['flanger_offset'] = args.flanger_offset if args.flanger_offset is not None else 0
    params['flanger_sweep'] = args.flanger_sweep if args.flanger_sweep is not None else 0
    params['pitch_jump_speed'] = args.pitch_jump_speed if args.pitch_jump_speed is not None else 0
    params['pitch_jump_amount'] = args.pitch_jump_amount if args.pitch_jump_amount is not None else 0
    params['compression'] = args.compression if args.compression is not None else 0
    
    # Blend parameters
    params['blend_sine'] = args.blend_sine if args.blend_sine is not None else 0
    params['blend_saw'] = args.blend_saw if args.blend_saw is not None else 0
    params['blend_freq'] = args.blend_freq
    
    return params


def main():
    """Main entry point"""
    args = parse_args()
    
    if args.help:
        print_help()
        sys.exit(0)
    
    if args.version:
        print(f"PyBFXR2 version {__version__}")
        sys.exit(0)
    
    if args.variations < 1:
        print("Error: --variations must be at least 1", file=sys.stderr)
        sys.exit(1)
    
    if args.one_shot and not args.output:
        print("Error: --one-shot requires an output filename with -o", file=sys.stderr)
        sys.exit(1)
    
    # Determine output base filename
    if args.output:
        filename_base = os.path.splitext(args.output)[0]
    else:
        filename_base = generate_filename("EXPLOSION")
    
    sounds = []
    all_params = []
    sound_durations = []
    
    print(f"Generating {args.variations} variation(s)...")
    
    for i in range(args.variations):
        # Set seed for this variation
        if args.seed is not None:
            variation_seed = args.seed + i
            random.seed(variation_seed)
            np.random.seed(variation_seed)
        else:
            random.seed()
            np.random.seed()
        
        params = get_params_from_args(args, i)
        all_params.append(params)
        
        synth = BfxrExplosion(params)
        audio = synth.generate()
        sounds.append(audio)
        sound_durations.append(len(audio) / args.sample_rate)
        
        print(f"  Variation {i+1}: duration {sound_durations[-1]:.3f}s")
    
    # Handle output
    if args.one_shot and args.variations > 1:
        positions = []
        current_pos = 0
        
        for audio in sounds:
            positions.append(current_pos)
            if args.spacing is not None:
                current_pos += int(args.spacing * args.sample_rate)
            else:
                current_pos += len(audio)
        
        total_samples = int(current_pos + max([len(s) for s in sounds]))
        mix_buffer = np.zeros(total_samples)
        
        for i, audio in enumerate(sounds):
            start = positions[i]
            end = start + len(audio)
            if end > len(mix_buffer):
                mix_buffer = np.pad(mix_buffer, (0, end - len(mix_buffer)))
            mix_buffer[start:end] += audio
        
        max_val = np.max(np.abs(mix_buffer))
        if max_val > 0:
            mix_buffer = mix_buffer / max_val
        
        wav_filename = f"{filename_base}.wav"
        sf.write(wav_filename, mix_buffer, args.sample_rate)
        print(f"Saved {args.variations} variations to {wav_filename}")
        print(f"  Total duration: {len(mix_buffer)/args.sample_rate:.3f}s")
        
        log_parameters(filename_base, all_params, sound_durations, is_one_shot=True)
        print(f"Parameter log saved to {filename_base}.txt")
    
    else:
        for i, audio in enumerate(sounds):
            if args.variations == 1:
                wav_filename = f"{filename_base}.wav"
            else:
                variation_base = f"{filename_base}_var{i+1:03d}"
                wav_filename = f"{variation_base}.wav"
            
            sf.write(wav_filename, audio, args.sample_rate)
            print(f"  Variation {i+1}: saved to {wav_filename}")
            
            log_parameters(
                wav_filename.replace('.wav', ''), 
                [all_params[i]], 
                [sound_durations[i]], 
                is_one_shot=False
            )
            print(f"  Parameter log saved to {wav_filename.replace('.wav', '.txt')}")
    
    if sound_durations:
        print("\nSummary:")
        print(f"  Average duration: {np.mean(sound_durations):.3f}s")
        print(f"  Min duration: {np.min(sound_durations):.3f}s")
        print(f"  Max duration: {np.max(sound_durations):.3f}s")


if __name__ == "__main__":
    main()