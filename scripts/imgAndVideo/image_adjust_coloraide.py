# DESCRIPTION
# Shifts images through various perceptual color spaces and saves result.
# Supports: HCT, okhsl, okhsv, oklch
# Loads an image, converts it from sRGB to the specified color space,
# applies shifts to the relevant channels, converts back to sRGB,
# and saves the result with the adjustments encoded in the filename.

# Written nearly entirely by a Large Language Model, deepseek, with
# human guidance in features and fixes.

# DEPENDENCIES
# pip install Pillow numpy coloraide
#
# Required versions:
# - Pillow>=9.0.0
# - numpy>=1.21.0
# - coloraide>=2.2.0

# USAGE
# python image_adjust_coloraide.py --source INPUT_FILE --colorspace {hct,okhsl,okhsv,oklch}
#                       [--destination OUTPUT_FILE] [--hue DEGREES]
#                       [--channel2 VALUE] [--channel3 VALUE] [--cores PERCENT]
#
# Examples:
#   # HCT adjustment
#   python image_adjust_coloraide.py -i photo.jpg --colorspace hct --hue 30 --chroma 10 --tone -5
#   
#   # okhsl adjustment  
#   python image_adjust_coloraide.py -i photo.jpg --colorspace okhsl --hue 45 --sat 0.2 --lig 0.1
#   
#   # okhsv adjustment
#   python image_adjust_coloraide.py -i photo.png --colorspace okhsv --hue 180 --sat -0.3 --val 0.15
#   
#   # oklch adjustment
#   python image_adjust_coloraide.py -i photo.jpg --colorspace oklch --hue 30 --chroma 0.05 --lig -0.1
#
#   python image_adjust_coloraide.py --help

# NOTES
# - Channel names and ranges vary by colorspace (see help for each)
# - If no destination is specified, filename encodes all adjustments with dashes
# - At least one channel adjustment must be specified
# - Processing uses specified percentage of CPU cores (default: 75%)
# - A progress bar shows completion percentage during processing


# CODE
import argparse
import sys
import os
import numpy as np
from PIL import Image
from multiprocessing import Pool, cpu_count
import time

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
            {'name': 'lightness', 'range': (0, 1), 'wrap': False},    # Index 0
            {'name': 'chroma', 'range': (0, 0.5), 'wrap': False},     # Index 1
            {'name': 'hue', 'range': (0, 360), 'wrap': True}          # Index 2
        ],
        'channel2': 'chroma',
        'channel3': 'lightness',
        'format': {'chroma': '{:+.3f}', 'lightness': '{:+.2f}'}
    }
}

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
                # Print error without special characters
                print(f"\nWarning: Error processing pixel: {e}", file=sys.stderr)
    
    result = (pixels.reshape(original_shape) * 255).astype(np.uint8)
    return result

def print_progress(percentage):
    """Display a progress bar - using ASCII only to avoid encoding issues."""
    bar_length = 40
    filled = int(bar_length * percentage / 100)
    # Use only ASCII characters
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
  %(prog)s -i photo.jpg --colorspace hct --hue 30 --chroma 10 --tone -5
  %(prog)s -i photo.jpg --colorspace okhsl --hue 45 --sat 0.2 --lig 0.1
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
        output_file = base + '.png'
        if os.path.exists(output_file):
            output_file = base + '_adj.png'

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