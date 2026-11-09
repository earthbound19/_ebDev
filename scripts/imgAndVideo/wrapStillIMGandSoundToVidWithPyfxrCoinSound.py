#!/usr/bin/env python3
# DESCRIPTION
# Iterates over all image files of a specified type (-t/--type) in the current directory, 
# generates a random coin/bell chiptune-type sound mapped to a selected or random wind-chime 
# scale using pyfxr, and passes each generated sound and file pair into a target 
# shell script to create muxed videos of a still image with the tone. The result videos
# can in turn be muxed together via concatVideos.sh.

# DEPENDENCIES
# - Python 3.x
# - pyfxr Python library (install via `pip install pyfxr`)
# - MSYS2 Bash environment (to run the underlying shell script on Windows)
# - stillIMGAndSoundToVid.sh (shell script for video generation and muxing)
# - optional: concatVideos.sh

# USAGE
# Run the script from an MSYS2 bash terminal with these parameters:
#    -t, --type REQUIRED. File extension/type to iterate over (e.g., png, jpg)
#    -s, --script OPTIONAL. Recommend omitting. Shell script to execute (default:
#        stillIMGAndSoundToVid.sh)
#    --scale OPTIONAL. Name of a specific wind-chime scale to use (defaults to random choice)
#    --base-duration OPTIONAL. Base duration of tone in milliseconds. Default 818
#    --duration-variance OPTIONAL. Random duration variance window in milliseconds (default: 140)
# Example command to operate on all png files using the hirajoshi scale:
#    python3 /path/to/wrapStillIMGandSoundToVidWithPyfxrCoinSound.py -t png --scale hirajoshi --base-duration 400 --duration-variance 200

# NOTES
# - Includes 10 classic wind chime scales ranging from major/minor pentatonic to 
#   ambient whole-tone and Japanese modal tunings.
# - Each generated tone has very slight pitch jitter, random detune slide, and 
#   fully functional randomized duration variance.
# - Generated sound files are created as WAV files in the working directory 
#   during processing, and left around afterward.

# CODE
import argparse
import glob
import random
import wave
import pyfxr
import subprocess

# Dictionary of classic wind chime scales (frequencies in Hz)
WIND_CHIME_SCALES = {
    "major_pentatonic": [523.25, 587.33, 659.25, 783.99, 880.00],      # C5 Major Pentatonic (Bright & Joyful)
    "minor_pentatonic": [523.25, 622.25, 698.46, 783.99, 932.33],      # C5 Minor Pentatonic (Contemplative)
    "chinese_pentatonic": [523.25, 587.33, 698.46, 783.99, 932.33],    # Traditional Chinese modal scale
    "blues_scale": [523.25, 622.25, 698.46, 739.99, 783.99, 932.33],   # Smoky Blues hybrid scale
    "hirajoshi": [523.25, 554.37, 659.25, 698.46, 830.61],             # Japanese Garden (Zen & Atmospheric)
    "in_sen": [523.25, 554.37, 698.46, 783.99, 830.61],                # Japanese In Sen meditation scale
    "balinese_pelog": [523.25, 554.37, 622.25, 783.99, 830.61],        # Mystical Temple Pelog scale
    "whole_tone": [523.25, 587.33, 659.25, 739.98, 830.61, 932.33],    # Dreamy floating whole-tone scale
    "gregorian_modal": [523.25, 587.33, 659.25, 698.46, 783.99],       # Ancient ambient church mode
    "solfeggio_chakra": [417.00, 432.00, 528.00, 639.00, 741.00]       # Deep wellness frequency cluster
}

def generate_wind_chime_coin_sound(output_filename, scale_name=None, base_duration_ms=818, duration_variance_ms=140):
    # Select scale
    if scale_name and scale_name in WIND_CHIME_SCALES:
        chosen_scale_name = scale_name
        frequencies = WIND_CHIME_SCALES[scale_name]
    else:
        chosen_scale_name, frequencies = random.choice(list(WIND_CHIME_SCALES.items()))
    
    chosen_hz = random.choice(frequencies)
    jitter_factor = random.uniform(0.984, 1.016)
    final_hz = chosen_hz * jitter_factor
    mapped_base_freq = min(max((final_hz / 1000.0) * 0.9, 0.1), 0.9)
    random_ramp = random.uniform(-0.024, 0.024)
    
    # Calculate actual target duration with random variance offset
    actual_duration_ms = base_duration_ms + random.uniform(-duration_variance_ms, duration_variance_ms)
    actual_duration_ms = max(50.0, actual_duration_ms) # Prevent negative/zero lengths
    
    # Scale duration into seconds for pyfxr's envelope
    total_sec = actual_duration_ms / 1000.0
    sustain_time = total_sec * 0.5
    decay_time = total_sec * 0.5

    sound_sfx = pyfxr.SFX(
        base_freq=mapped_base_freq,
        freq_limit=0.0,
        freq_ramp=random_ramp,
        arp_speed=0.1,
        arp_mod=0.3
    )
    
    # Apply length/duration via pyfxr's built-in envelope method
    sound_sfx.envelope(attack=0.01, sustain=sustain_time, decay=decay_time, punch=0.0)

    with wave.open(output_filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(44100)
        wav_file.writeframes(bytes(sound_sfx))
        
    return chosen_scale_name

# Parse command line arguments
parser = argparse.ArgumentParser(description="Generate wind-chime pyfxr sounds and pair them with files.")
parser.add_argument("-t", "--type", required=True, help="File extension/type to iterate over (e.g., png,jpg)")
parser.add_argument("-s", "--script", default="stillIMGAndSoundToVid.sh", help="Target shell script to execute")
parser.add_argument("--scale", choices=list(WIND_CHIME_SCALES.keys()), help="Choose a specific wind chime scale by name")
parser.add_argument("--base-duration", type=float, default=None, help="Base duration of the sound effect in milliseconds (default: 818)")
parser.add_argument("--duration-variance", type=float, default=None, help="Random duration variance window in milliseconds (default: 140)")
args = parser.parse_args()

search_pattern = f"*.{args.type.lstrip('.')}"
files = glob.glob(search_pattern)

if not files:
    print(f"No files found matching type: {search_pattern}")
    exit(0)

print(f"Found {len(files)} files of type '{args.type}'. Processing...")

for index, file_path in enumerate(files):
    sound_filename = f"generated_sound_{index}.wav"
    
    print(f"\n--- Processing file: {file_path} ---")
    
    # FIXED: Now properly passing both base_duration and duration_variance down into the function!
    used_scale = generate_wind_chime_coin_sound(
        output_filename=sound_filename, 
        scale_name=args.scale, 
        base_duration_ms=args.base_duration,
        duration_variance_ms=args.duration_variance
    )
    print(f"Generating sound: {sound_filename} (Scale: {used_scale})")

    command = ["bash", args.script, sound_filename, file_path]
    
    print(f"Executing: {' '.join(command)}")
    result = subprocess.run(command)

    if result.returncode != 0:
        print(f"Error executing script for {file_path}. Exit code: {result.returncode}")

print("\nAll files processed successfully! To concatenate them, run the script / command:")
print("\n    concatVideos.sh mp4")
print("\n-- and watch the output for the created concatenated video file name. After")
print("\nconcatentation you may want to delete the other leftover intermediate .wav and .mp4 files.")