# DESCRIPTION
# Shifts images through one of various perceptual color spaces and
# saves result. Supports HCT, okhsl, okhsv, oklch.
# Loads an image, converts it from sRGB to the specified color space,
# applies shifts to the relevant channels, converts back to sRGB,
# and saves the result with the adjustments encoded in the filename.
#
# White balance mode with --rgb-white-reference allows manual
# sampling of a white reference pixel from any color picker. Adding
# --no-hue-rotate can avoid hue rotation problems where hue isn't
# clear with that.
#
# DEPENDENCIES
# pip install Pillow numpy coloraide
# Optional GPU: install CUDA Toolkit + cupy-cuda12x
#
# USAGE
# python image_adjust_coloraide.py --source INPUT_FILE --colorspace {hct,okhsl,okhsv,oklch}
#                       [--destination OUTPUT_FILE] [--hue DEGREES]
#                       [--channel2 VALUE] [--channel3 VALUE] [--cores PERCENT]
#                       [--rgb-white-reference R G B] [--auto-white]

import argparse
import sys
import os
import numpy as np
from PIL import Image
from multiprocessing import Pool, cpu_count
import time

# Try GPU acceleration
try:
    import cupy as cp
    ON_GPU = True
    xp = cp
    print("GPU acceleration enabled (CuPy)", file=sys.stderr)
except ImportError:
    ON_GPU = False
    xp = np
    print("CPU mode (NumPy). Install CuPy + CUDA for GPU speed.", file=sys.stderr)

# Import Coloraide
try:
    from coloraide import Color
    from coloraide.everything import ColorAll
    HAS_COLORAIDE = True
    ColorSpace = ColorAll
except ImportError:
    HAS_COLORAIDE = False
    print("Error: Coloraide is required but not installed.", file=sys.stderr)
    print("Please install: pip install coloraide", file=sys.stderr)
    sys.exit(1)

# Define color space configurations
COLORSPACES = {
    'hct': {
        'name': 'HCT',
        'coloraide_name': 'hct',
        'channels': [
            {'name': 'hue', 'range': (0, 360), 'wrap': True},
            {'name': 'chroma', 'range': (0, 145), 'wrap': False},
            {'name': 'tone', 'range': (0, 100), 'wrap': False}
        ],
        'channel2': 'chroma',
        'channel3': 'tone',
        'format': {'chroma': '{:+.1f}', 'tone': '{:+.1f}'}
    },
    'okhsl': {
        'name': 'okhsl',
        'coloraide_name': 'okhsl',
        'channels': [
            {'name': 'hue', 'range': (0, 360), 'wrap': True},
            {'name': 'saturation', 'range': (0, 1), 'wrap': False},
            {'name': 'lightness', 'range': (0, 1), 'wrap': False}
        ],
        'channel2': 'saturation',
        'channel3': 'lightness',
        'format': {'saturation': '{:+.2f}', 'lightness': '{:+.2f}'}
    },
    'okhsv': {
        'name': 'okhsv',
        'coloraide_name': 'okhsv',
        'channels': [
            {'name': 'hue', 'range': (0, 360), 'wrap': True},
            {'name': 'saturation', 'range': (0, 1), 'wrap': False},
            {'name': 'value', 'range': (0, 1), 'wrap': False}
        ],
        'channel2': 'saturation',
        'channel3': 'value',
        'format': {'saturation': '{:+.2f}', 'value': '{:+.2f}'}
    },
    'oklch': {
        'name': 'oklch',
        'coloraide_name': 'oklch',
        'channels': [
            {'name': 'lightness', 'range': (0, 1), 'wrap': False},
            {'name': 'chroma', 'range': (0, 0.5), 'wrap': False},
            {'name': 'hue', 'range': (0, 360), 'wrap': True}
        ],
        'channel2': 'chroma',
        'channel3': 'lightness',
        'format': {'chroma': '{:+.3f}', 'lightness': '{:+.2f}'}
    }
}

def parse_color_input(color_input):
    """Parse either RGB values (0-255 or 0-1) or hex color code.
    Returns tuple of (r, g, b) normalized to 0-1 range.
    """
    # Check if it's a hex string (starts with #)
    if isinstance(color_input, str) and color_input.startswith('#'):
        hex_color = color_input.lstrip('#')
        
        # Handle 3-digit hex (e.g., #FFF)
        if len(hex_color) == 3:
            r = int(hex_color[0] * 2, 16)
            g = int(hex_color[1] * 2, 16)
            b = int(hex_color[2] * 2, 16)
        # Handle 6-digit hex (e.g., #FFFFFF)
        elif len(hex_color) == 6:
            r = int(hex_color[0:2], 16)
            g = int(hex_color[2:4], 16)
            b = int(hex_color[4:6], 16)
        else:
            raise ValueError(f"Invalid hex color format: {color_input}")
        
        return (r / 255.0, g / 255.0, b / 255.0)
    
    # Otherwise assume it's already RGB
    return None

def rgb_to_target_space(rgb_normalized, colorspace):
    """Convert a single RGB pixel to target color space."""
    try:
        color = ColorSpace('srgb', rgb_normalized)
        color_converted = color.convert(colorspace)
        return list(color_converted.coords())
    except Exception as e:
        print(f"Warning: RGB to {colorspace} conversion failed: {e}", file=sys.stderr)
        return None

def compute_white_balance_shifts_from_rgb(rgb_ref, colorspace):
    """Given an RGB reference pixel (values 0-1) that should be white,
    compute the shifts needed in the target colorspace to make it true white."""
    
    if colorspace == 'oklch':
        # oklch order: [lightness, chroma, hue]
        coords = rgb_to_target_space(rgb_ref, colorspace)
        if coords is None:
            return None
        
        # Target white in oklch: lightness=1.0, chroma=0
        hue_shift = -coords[2]
        if hue_shift > 180:
            hue_shift -= 360
        elif hue_shift < -180:
            hue_shift += 360
        
        chroma_shift = -coords[1]
        lightness_shift = 1.0 - coords[0]
        
        return {'hue': hue_shift, 'channel2': chroma_shift, 'channel3': lightness_shift}
    
    else:
        # hct, okhsl, okhsv: [hue, channel2, channel3]
        coords = rgb_to_target_space(rgb_ref, colorspace)
        if coords is None:
            return None
        
        # Hue shift: bring reference hue to 0
        hue_shift = -coords[0]
        if hue_shift > 180:
            hue_shift -= 360
        elif hue_shift < -180:
            hue_shift += 360
        
        # Channel2 shift: bring saturation/chroma to 0
        channel2_shift = -coords[1]
        
        # Channel3 shift: bring to max (1.0 for okhsl/okhsv, 100 for hct)
        if colorspace == 'hct':
            target_ch3 = 100.0
        else:  # okhsl, okhsv
            target_ch3 = 1.0
        
        channel3_shift = target_ch3 - coords[2]
        
        return {'hue': hue_shift, 'channel2': channel2_shift, 'channel3': channel3_shift}

def process_chunk(args):
    """Process a chunk of the image in parallel."""
    chunk_data, width, chunk_height, colorspace, shifts = args
    
    # Convert to float for processing (0-1 range)
    chunk_float = chunk_data.astype(np.float32) / 255.0
    original_shape = chunk_float.shape
    
    # Reshape to pixel list
    pixels = chunk_float.reshape(-1, 3)
    
    # Create mask for non-black pixels
    mask = np.any(pixels > 0.01, axis=1)
    mask_indices = np.where(mask)[0]
    
    if len(mask_indices) > 0:
        for idx in mask_indices:
            r, g, b = pixels[idx]
            
            try:
                # Convert to target color space
                color = ColorSpace('srgb', [r, g, b])
                color_converted = color.convert(colorspace)
                coords = list(color_converted.coords())
                
                # Apply shifts based on color space coordinate ordering
                if colorspace == 'oklch':
                    # oklch order: [lightness, chroma, hue]
                    
                    # Hue shift (index 2)
                    if 'hue' in shifts and shifts['hue'] != 0:
                        coords[2] = (coords[2] + shifts['hue']) % 360
                    
                    # Chroma shift (index 1)
                    if shifts['channel2'] != 0:
                        ch2_min, ch2_max = COLORSPACES[colorspace]['channels'][1]['range']
                        coords[1] = np.clip(coords[1] + shifts['channel2'], ch2_min, ch2_max)
                    
                    # Lightness shift (index 0)
                    if shifts['channel3'] != 0:
                        ch3_min, ch3_max = COLORSPACES[colorspace]['channels'][0]['range']
                        coords[0] = np.clip(coords[0] + shifts['channel3'], ch3_min, ch3_max)
                
                else:
                    # All other spaces: [hue, channel2, channel3]
                    
                    # Hue shift (index 0)
                    if 'hue' in shifts and shifts['hue'] != 0:
                        coords[0] = (coords[0] + shifts['hue']) % 360
                    
                    # Channel2 shift (index 1)
                    if shifts['channel2'] != 0:
                        ch2_min, ch2_max = COLORSPACES[colorspace]['channels'][1]['range']
                        coords[1] = np.clip(coords[1] + shifts['channel2'], ch2_min, ch2_max)
                    
                    # Channel3 shift (index 2)
                    if shifts['channel3'] != 0:
                        ch3_min, ch3_max = COLORSPACES[colorspace]['channels'][2]['range']
                        coords[2] = np.clip(coords[2] + shifts['channel3'], ch3_min, ch3_max)
                
                # Convert back
                color_shifted = ColorSpace(colorspace, coords)
                color_rgb = color_shifted.convert('srgb')
                r_new, g_new, b_new = color_rgb.coords()
                
                pixels[idx] = [np.clip(r_new, 0, 1), 
                              np.clip(g_new, 0, 1), 
                              np.clip(b_new, 0, 1)]
                
            except Exception as e:
                print(f"\nWarning: Error processing pixel: {e}", file=sys.stderr)
    
    result = (pixels.reshape(original_shape) * 255).astype(np.uint8)
    return result

def print_progress(percentage):
    """Display a progress bar - using ASCII only to avoid encoding issues."""
    bar_length = 40
    filled = int(bar_length * percentage / 100)
    bar = '=' * filled + '-' * (bar_length - filled)
    print(f'\rProgress: [{bar}] {percentage:.1f}%', end='', flush=True)

def calculate_core_count(percent):
    """Calculate number of cores to use based on percentage."""
    total_cores = cpu_count()
    if percent <= 0:
        return 1
    elif percent >= 1:
        return total_cores
    return max(1, int(round(total_cores * percent)))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Unified image adjuster for multiple perceptual color spaces',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Supported color spaces:
  hct:    HCT (CAM16 + CIELAB) - hue(0-360), chroma(0-145), tone(0-100)
  okhsl:  okhsl - hue(0-360), saturation(0-1), lightness(0-1)
  okhsv:  okhsv - hue(0-360), saturation(0-1), value(0-1)
  oklch:  oklch - lightness(0-1), chroma(0-0.5), hue(0-360)

Examples:
  # Manual adjustments
  %(prog)s -i photo.jpg --colorspace hct --hue 30 --chroma 10 --tone -5

  # White balance with hue rotation (for tinted lighting)
  %(prog)s -i photo.jpg --colorspace okhsl --rgb-white-reference 220 210 200

  # White balance without hue rotation (for near-white reference)
  %(prog)s -i photo.jpg --colorspace okhsl --rgb-white-reference '#eff1f3' --no-hue-rotate

  # Hex color support
  %(prog)s -i photo.jpg --colorspace okhsl --rgb-white-reference '#E2D2C8'

Output filenames auto-generate with parameters:
  photo_coloraide_okhsl_wb_eff1f3.png
  photo_coloraide_hct_h+30_chr+10_ton-5.png
        """
    )

    parser.add_argument('-i', '--source', required=True,
                       help='Source image file path')
    parser.add_argument('-d', '--destination',
                       help='Destination image file path (auto-generated if omitted)')
    parser.add_argument('--colorspace', required=True, choices=COLORSPACES.keys(),
                       help='Color space to use for adjustment')
    parser.add_argument('--hue', '-u', type=float, default=0,
                       help='Hue shift amount in degrees')
    parser.add_argument('--chroma', '-chr', type=float,
                       help='Chroma shift')
    parser.add_argument('--tone', '-ton', type=float,
                       help='Tone shift (for HCT)')
    parser.add_argument('--sat', '-sat', type=float,
                       help='Saturation shift (for okhsl, okhsv)')
    parser.add_argument('--lig', '-lig', type=float,
                       help='Lightness shift (for okhsl, oklch)')
    parser.add_argument('--val', '-val', type=float,
                       help='Value shift (for okhsv)')
    parser.add_argument('--cores', '-p', type=float, default=0.75,
                       help='Percentage of CPU cores to use (0.0-1.0)')
    parser.add_argument('--rgb-white-reference', nargs='+', metavar='REF',
                       help='White balance mode: provide an RGB reference that should be pure white. '
                            'Accepts three numbers (e.g., 220 210 200) OR a hex color (e.g., #E2D2C8). '
                            'Automatically computes hue/sat/lig shifts to make that color white, '
                            'overriding any manual --hue, --sat, --lig, etc. values. '
                            'See --no-hue-rotate for possible additional help.')
    parser.add_argument('--no-hue-rotate', action='store_true',
                        help='When used with --rgb-white-reference, do NOT apply hue rotation. '
                                'See examples in --help. Only adjusts saturation/lightness (or '
                                'chroma/tone). Useful when the reference is already near-white and hue '
                                'measurement is unreliable, and / or that punk kid Ben Skywalker gave '
                                'you a compressed image.')
    parser.add_argument('--auto-white', action='store_true',
                       help='Automatically find nearest-white pixel (experimental, may overcorrect)')

    args = parser.parse_args()

    # Validate cores parameter
    if args.cores < 0 or args.cores > 1:
        print("\nError: --cores must be between 0.0 and 1.0\n", file=sys.stderr)
        sys.exit(1)

    # Get color space config
    config = COLORSPACES[args.colorspace]

    # Collect shifts
    shifts = {'hue': args.hue, 'channel2': 0, 'channel3': 0}
    
    ch2_name = config['channel2']
    ch3_name = config['channel3']
    
    # Handle white balance modes FIRST (they override manual shifts)
    # If --rgb-white-reference is provided, the shifts below will completely
    # replace any manual --hue, --sat, --lig, --chroma, --tone, or --val values passed to the script.
    if args.rgb_white_reference:
        # Parse RGB reference (supports hex or 3 numbers)
        rgb_ref = None
        
        if len(args.rgb_white_reference) == 1 and isinstance(args.rgb_white_reference[0], str) and args.rgb_white_reference[0].startswith('#'):
            # Hex code
            hex_color = args.rgb_white_reference[0].lstrip('#')
            if len(hex_color) == 3:
                r = int(hex_color[0] * 2, 16)
                g = int(hex_color[1] * 2, 16)
                b = int(hex_color[2] * 2, 16)
            elif len(hex_color) == 6:
                r = int(hex_color[0:2], 16)
                g = int(hex_color[2:4], 16)
                b = int(hex_color[4:6], 16)
            else:
                print(f"\nError: Invalid hex color format\n", file=sys.stderr)
                sys.exit(1)
            rgb_ref = [r / 255.0, g / 255.0, b / 255.0]
        elif len(args.rgb_white_reference) == 3:
            # Three RGB numbers
            rgb_ref = [float(v) / 255.0 if float(v) > 1.0 else float(v) for v in args.rgb_white_reference]
        else:
            print(f"\nError: --rgb-white-reference takes either 3 RGB values or a single hex code\n", file=sys.stderr)
            sys.exit(1)
        
        wb_shifts = compute_white_balance_shifts_from_rgb(rgb_ref, args.colorspace)
        if wb_shifts is None:
            print(f"\nError: Failed to compute white balance from RGB reference\n", file=sys.stderr)
            sys.exit(1)
        
        # Apply shifts, conditionally skipping hue rotation
        if args.no_hue_rotate:
            shifts['hue'] = 0
            print(f"\nWhite balance mode: hue rotation DISABLED (--no-hue-rotate)", file=sys.stderr)
        else:
            shifts['hue'] = wb_shifts['hue']
        
        shifts['channel2'] = wb_shifts['channel2']
        shifts['channel3'] = wb_shifts['channel3']
        
        print(f"\nWhite balance mode: using RGB reference {args.rgb_white_reference[0] if len(args.rgb_white_reference)==1 else f'({rgb_ref[0]*255:.0f},{rgb_ref[1]*255:.0f},{rgb_ref[2]*255:.0f})'}", file=sys.stderr)
        print(f"  Computed shifts: hue={shifts['hue']:+.1f}°, {ch2_name}={shifts['channel2']:+.3f}, {ch3_name}={shifts['channel3']:+.3f}", file=sys.stderr)
    
    elif args.auto_white:
        print(f"\nAuto-white mode: not yet implemented. Use --rgb-white-reference for manual white balance.\n", file=sys.stderr)
        sys.exit(1)
    
    else:
        # Manual shifts from command line
        # Map channel 2
        if ch2_name == 'chroma' and args.chroma is not None:
            shifts['channel2'] = args.chroma
        elif ch2_name == 'saturation' and args.sat is not None:
            shifts['channel2'] = args.sat
        
        # Map channel 3
        if ch3_name == 'tone' and args.tone is not None:
            shifts['channel3'] = args.tone
        elif ch3_name == 'lightness' and args.lig is not None:
            shifts['channel3'] = args.lig
        elif ch3_name == 'value' and args.val is not None:
            shifts['channel3'] = args.val

        # Validate at least one non-zero shift
        if shifts['hue'] == 0 and shifts['channel2'] == 0 and shifts['channel3'] == 0:
            print(f"\nError: No adjustments specified for {args.colorspace}!\n", file=sys.stderr)
            sys.exit(1)

    # Check if source exists
    if not os.path.exists(args.source):
        print(f"\nError: Source file '{args.source}' not found!\n", file=sys.stderr)
        sys.exit(1)

    # Calculate cores
    total_cores = cpu_count()
    cores_to_use = calculate_core_count(args.cores)
    
    # Generate output filename if not specified
    if args.destination:
        output_file = args.destination
    else:
        base = os.path.splitext(args.source)[0]
        
        # Build parameters string for filename
        params = []
        
        # White balance mode takes precedence
        if args.rgb_white_reference:
            if len(args.rgb_white_reference) == 1 and str(args.rgb_white_reference[0]).startswith('#'):
                ref_str = args.rgb_white_reference[0].lstrip('#')
                params.append(f"wb_{ref_str}")
            else:
                r, g, b = [int(float(v)) for v in args.rgb_white_reference[:3]]
                params.append(f"wb_{r:02x}{g:02x}{b:02x}")
            if args.no_hue_rotate:
                params.append("no_hue")
        else:
            # Manual adjustments
            if args.hue != 0:
                params.append(f"h{args.hue:+.0f}")
            if args.chroma is not None and args.chroma != 0:
                params.append(f"chr{args.chroma:+.1f}")
            if args.tone is not None and args.tone != 0:
                params.append(f"ton{args.tone:+.0f}")
            if args.sat is not None and args.sat != 0:
                params.append(f"sat{args.sat:+.2f}".replace('.', '_'))
            if args.lig is not None and args.lig != 0:
                params.append(f"lig{args.lig:+.2f}".replace('.', '_'))
            if args.val is not None and args.val != 0:
                params.append(f"val{args.val:+.2f}".replace('.', '_'))
        
        # Add colorspace
        params.insert(0, args.colorspace)
        
        # Build filename
        if params:
            param_str = '_'.join(params)
            output_file = f"{base}_coloraide_{param_str}.png"
        else:
            output_file = base + '_coloraide.png'
        
        # Handle existing file
        counter = 1
        original_output = output_file
        while os.path.exists(output_file):
            output_file = original_output.replace('.png', f'_{counter}.png')
            counter += 1

    print(f"\nLoading image: {args.source}")
    print(f"Color space: {config['name']}")
    print(f"Adjustments: Hue={shifts['hue']:+.1f}°, {ch2_name}={shifts['channel2']:+.2f}, {ch3_name}={shifts['channel3']:+.2f}")
    print(f"CPU cores: {cores_to_use} of {total_cores} available ({args.cores*100:.0f}%)")
    
    try:
        # Load image
        img = Image.open(args.source).convert('RGB')
        width, height = img.size
        img_array = np.array(img)
        
        print(f"Image size: {width}x{height} pixels")
        print(f"Processing...")
        
        start_time = time.time()
        
        # Prepare chunks
        chunk_height = max(10, height // cores_to_use)
        chunks = []
        
        for i in range(0, height, chunk_height):
            chunk_end = min(i + chunk_height, height)
            actual_chunk_height = chunk_end - i
            chunk_data = img_array[i:chunk_end].copy()
            chunks.append((chunk_data, width, actual_chunk_height, config['coloraide_name'], shifts))
        
        # Process in parallel
        results = []
        with Pool(processes=cores_to_use) as pool:
            for j, result in enumerate(pool.imap(process_chunk, chunks)):
                results.append(result)
                print_progress((j + 1) / len(chunks) * 100)
        
        print()
        
        # Reassemble
        modified_array = np.vstack(results)
        
        elapsed = time.time() - start_time
        print(f"Processing completed in {elapsed:.2f} seconds")
        
        # Save
        result_img = Image.fromarray(modified_array)
        result_img.save(output_file)
        
        print(f"Saved to: {output_file}")
        print("Done!\n")
        
    except Exception as e:
        print(f"\nError processing image: {e}\n", file=sys.stderr)
        sys.exit(1)