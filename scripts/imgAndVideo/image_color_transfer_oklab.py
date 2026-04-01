# DESCRIPTION
# Transfers perceptually nearest colors from a comparison image to a source
# image using the Oklab color space, which models human color perception with
# uniform distance. For each pixel in the source image, finds the closest
# matching color in the comparison image (by Euclidean distance in Oklab space)
# and substitutes that color. The result is a copy of the source image recolored
# using only colors that exist in the comparison image.
#
# Key Features:
# - Exact color substitution - every output pixel is a color taken directly from
#   the comparison image (no averaging, no quantization)
# - Deduplication - only unique colors from comparison image are used as reference
# - k-d tree for efficient nearest neighbor search (O(log n) per pixel)
# - Oklab color space for perceptually uniform distance measurement
# - Parallel processing for RGB to Oklab conversion
# - Auto-output filename generation when -o omitted

# DEPENDENCIES
# pip install Pillow numpy scipy coloraide
#
# Required versions:
# - Pillow>=9.0.0
# - numpy>=1.21.0
# - scipy>=1.7.0
# - coloraide>=2.2.0

# USAGE
# python image_color_transfer_oklab.py -s SOURCE_IMAGE -c COMPARISON_IMAGE [-o OUTPUT_FILE] [--cores PERCENT]
#
# Examples:
# To have the output file name decided automatically:
#   python image_color_transfer_oklab.py -s photo.jpg -c reference.png
# To specify the output image file name:
#   python image_color_transfer_oklab.py -s photo.jpg -c reference.png -o result.jpg
# To use 75 percent of available CPUs:
#   python image_color_transfer_oklab.py -s photo.jpg -c reference.png --cores 0.75
#
# Short options:
#   -s : --sourceimage
#   -c : --comparisonimage
#   -o : --output
#
# NOTES
# - All source pixels are processed - no sampling is performed
# - Comparison image colors are deduplicated to unique RGB triplets
# - k-d tree enables efficient matching even for millions of comparison colors
# - Output filename auto-generates as: source_basename_colorTransfer_comparison_basename.png
# - Processing time scales with source image resolution
# - Use --cores to control CPU usage for parallel conversion (0.0-1.0, default: 0.75)
# - The script uses coloraide's native sRGB to Oklab conversion


# CODE
import argparse
import sys
import os
import numpy as np
from PIL import Image
from coloraide import Color
from coloraide.everything import ColorAll
from scipy.spatial import KDTree
from multiprocessing import Pool, cpu_count
import time

# ColorAll has all color spaces pre-registered
Color = ColorAll

def calculate_core_count(percent):
    """Calculate number of cores to use based on percentage."""
    total_cores = cpu_count()
    
    if percent <= 0:
        return 1
    elif percent >= 1:
        return total_cores
    
    core_count = max(1, int(round(total_cores * percent)))
    return core_count

def rgb_to_oklab(rgb):
    """
    Convert RGB triplet (0-255) to Oklab (L, a, b) using coloraide.
    """
    c = Color('srgb', [v/255.0 for v in rgb])
    oklab = c.convert('oklab')
    return np.array(oklab.coords(), dtype=np.float32)

def convert_chunk_to_oklab(chunk):
    """
    Convert a chunk of RGB pixels to Oklab coordinates.
    Used for parallel processing.
    """
    results = []
    for rgb in chunk:
        oklab = rgb_to_oklab(rgb)
        results.append(oklab)
    return np.array(results, dtype=np.float32)

def extract_unique_colors(img_array):
    """
    Extract unique RGB triplets from image array using structured array.
    Returns array of shape (n, 3) with unique colors.
    """
    pixels = img_array.reshape(-1, 3)
    
    # Use structured array for efficient unique operation
    dtype = np.dtype([('r', np.uint8), ('g', np.uint8), ('b', np.uint8)])
    structured = pixels.view(dtype).squeeze()
    unique_struct = np.unique(structured)
    
    # Convert back to normal array
    unique_colors = np.zeros((len(unique_struct), 3), dtype=np.uint8)
    unique_colors[:, 0] = unique_struct['r']
    unique_colors[:, 1] = unique_struct['g']
    unique_colors[:, 2] = unique_struct['b']
    
    return unique_colors

def build_color_tree(unique_colors):
    """
    Build k-d tree from unique colors using Oklab space.
    Returns tree and the original RGB colors (for lookup).
    """
    print(f"  Converting {len(unique_colors):,} unique colors to Oklab...")
    
    # Convert each unique color to Oklab
    oklab_array = []
    for rgb in unique_colors:
        oklab = rgb_to_oklab(rgb)
        oklab_array.append(oklab)
    
    oklab_array = np.array(oklab_array, dtype=np.float32)
    
    print(f"  Building k-d tree...")
    tree = KDTree(oklab_array)
    
    return tree, unique_colors

def transfer_colors(source_img, tree, unique_colors, cores_to_use):
    """
    Transfer colors from comparison image to source image.
    Uses parallel Oklab conversion followed by sequential k-d tree queries.
    """
    width, height = source_img.size
    source_array = np.array(source_img)
    pixels = source_array.reshape(-1, 3)
    total_pixels = len(pixels)
    
    print(f"\nStep 1: Converting {total_pixels:,} source pixels to Oklab...")
    print(f"  Using {cores_to_use} cores for parallel conversion")
    
    # Split pixels into chunks for parallel conversion
    chunk_size = max(1000, total_pixels // (cores_to_use * 4))
    chunks = []
    for i in range(0, total_pixels, chunk_size):
        chunk = pixels[i:i+chunk_size]
        chunks.append(chunk)
    
    # Convert source pixels to Oklab in parallel
    source_oklab_list = []
    start_convert = time.time()
    
    with Pool(processes=cores_to_use) as pool:
        for i, result in enumerate(pool.imap(convert_chunk_to_oklab, chunks)):
            source_oklab_list.append(result)
            if (i + 1) % max(1, len(chunks) // 10) == 0:
                pct = (i + 1) / len(chunks) * 100
                print(f"    Conversion: {pct:.0f}% complete", end='\r')
    
    print()  # New line after progress
    source_oklab = np.vstack(source_oklab_list)
    
    convert_time = time.time() - start_convert
    print(f"  Conversion completed in {convert_time:.2f} seconds")
    
    print(f"\nStep 2: Matching {total_pixels:,} pixels to nearest comparison colors...")
    
    # Prepare result array
    result_array = np.zeros_like(source_array)
    
    # Process each pixel (sequential k-d tree queries)
    start_match = time.time()
    
    for i in range(total_pixels):
        # Query k-d tree for nearest neighbor
        dist, idx = tree.query(source_oklab[i])
        
        # Get matched color (original RGB from comparison image)
        matched_rgb = unique_colors[idx]
        
        # DEBUG: Print first few matches
        if i < 10:
            print(f"  DEBUG pixel {i}: source RGB {pixels[i]} -> matched RGB {matched_rgb} (index {idx}, dist {dist:.4f})")
        
        # Write to result array
        result_array[i // width, i % width] = matched_rgb
        
        # Progress indicator
        if (i + 1) % max(1, total_pixels // 10) == 0:
            pct = (i + 1) / total_pixels * 100
            print(f"    Matching: {pct:.0f}% complete", end='\r')
    
    print()  # New line after progress
    
    match_time = time.time() - start_match
    print(f"  Matching completed in {match_time:.2f} seconds")
    
    return Image.fromarray(result_array, 'RGB')

def generate_output_filename(source_path, comparison_path):
    """Generate output filename: source_basename_colorTransfer_comparison_basename.png"""
    source_base = os.path.splitext(os.path.basename(source_path))[0]
    comparison_base = os.path.splitext(os.path.basename(comparison_path))[0]
    return f"{source_base}_colorTransfer_{comparison_base}.png"

def validate_image(image_path, description):
    """Validate that an image file exists and can be opened."""
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"{description} '{image_path}' not found")
    
    try:
        img = Image.open(image_path)
        img.verify()  # Verify it's a valid image
        return True
    except Exception as e:
        raise ValueError(f"{description} '{image_path}' is not a valid image: {e}")

def main():
    parser = argparse.ArgumentParser(
        description='Transfer colors from comparison image to source image using perceptual matching in Oklab space',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('-s', '--sourceimage', required=True,
                       help='Source image file path (image to be modified)')
    parser.add_argument('-c', '--comparisonimage', required=True,
                       help='Comparison image file path (provides colors to transfer)')
    parser.add_argument('-o', '--output',
                       help='Output file path (default: auto-generated)')
    parser.add_argument('--cores', type=float, default=0.75,
                       help='Percentage of CPU cores to use for conversion (0.0-1.0, default: 0.75)')
    
    args = parser.parse_args()
    
    # Validate cores parameter
    if args.cores < 0 or args.cores > 1:
        print("\nError: --cores must be between 0.0 and 1.0\n", file=sys.stderr)
        sys.exit(1)
    
    print(f"\n{'='*60}")
    print(f"COLOR TRANSFER TOOL (Oklab + k-d tree)")
    print(f"{'='*60}")
    print(f"Source image: {args.sourceimage}")
    print(f"Comparison image: {args.comparisonimage}")
    
    try:
        # Validate input files
        print(f"\nValidating input files...")
        validate_image(args.sourceimage, "Source image")
        validate_image(args.comparisonimage, "Comparison image")
        print(f"  Source image: OK")
        print(f"  Comparison image: OK")
        
        # Load images
        print(f"\nLoading images...")
        source_img = Image.open(args.sourceimage).convert('RGB')
        comparison_img = Image.open(args.comparisonimage).convert('RGB')
        
        source_size = source_img.size
        comparison_size = comparison_img.size
        print(f"  Source dimensions: {source_size[0]}x{source_size[1]} ({source_size[0] * source_size[1]:,} pixels)")
        print(f"  Comparison dimensions: {comparison_size[0]}x{comparison_size[1]} ({comparison_size[0] * comparison_size[1]:,} pixels)")
        
        # Extract unique colors from comparison image
        print(f"\nAnalyzing comparison image...")
        comparison_array = np.array(comparison_img)
        unique_colors = extract_unique_colors(comparison_array)
        
        if len(unique_colors) == 0:
            raise ValueError("Comparison image contains no colors")
        
        print(f"  Total pixels: {comparison_array.size // 3:,}")
        print(f"  Unique colors found: {len(unique_colors):,}")
        print(f"  Compression ratio: {(1 - len(unique_colors) / (comparison_array.size // 3)) * 100:.1f}% duplicate reduction")
        
        # Build k-d tree
        print(f"\nBuilding k-d tree from comparison colors...")
        tree, unique_colors_rgb = build_color_tree(unique_colors)
        
        # DEBUG: Test with a sample color
        test_rgb = np.array([255, 0, 0], dtype=np.uint8)  # Pure red
        test_oklab = rgb_to_oklab(test_rgb)
        dist, idx = tree.query(test_oklab)
        print(f"  DEBUG: Test red matches index {idx}: {unique_colors_rgb[idx]} (expected: {test_rgb})")
        print(f"  DEBUG: First 5 unique comparison colors: {unique_colors[:5]}")
        
        # Calculate cores to use
        cores_to_use = calculate_core_count(args.cores)
        print(f"\nUsing {cores_to_use} of {cpu_count()} available cores for conversion")
        
        # Transfer colors
        print(f"\n{'='*60}")
        print(f"TRANSFERRING COLORS")
        print(f"{'='*60}")
        
        start_time = time.time()
        result_img = transfer_colors(source_img, tree, unique_colors_rgb, cores_to_use)
        total_time = time.time() - start_time
        
        print(f"\n{'='*60}")
        print(f"Transfer completed in {total_time:.2f} seconds")
        
        # Save output
        output_path = args.output
        if not output_path:
            output_path = generate_output_filename(args.sourceimage, args.comparisonimage)
        
        result_img.save(output_path)
        print(f"\nResult saved to: {output_path}")
        print(f"Output dimensions: {result_img.size[0]}x{result_img.size[1]}")
        print(f"{'='*60}")
        print("Done!\n")
        
    except FileNotFoundError as e:
        print(f"\nError: {e}\n", file=sys.stderr)
        sys.exit(1)
    except ValueError as e:
        print(f"\nError: {e}\n", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error: {e}\n", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()