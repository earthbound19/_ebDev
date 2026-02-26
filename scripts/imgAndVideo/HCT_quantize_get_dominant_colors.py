# DESCRIPTION
# HCT Space Dominant Color Extractor (using Coloraide)
# Quantizes images in HCT color space to extract dominant colors.
# Loads an image, converts it from sRGB to HCT color space, performs
# K-means clustering on the HCT values to find dominant colors,
# and outputs cluster centers in either sRGB hex codes or HCT value format.
#
# Why HCT for quantization?
# - Hue (0-360): Perceptual hue from CAM16 (circular)
# - Chroma (0-145): Perceptual colorfulness/saturation from CAM16
# - Tone (0-100): Perceptual lightness from CIELAB D65
#
# HCT provides more perceptually uniform results than RGB clustering,
# meaning the extracted colors will better represent what humans perceive
# as the "dominant" colors in an image. This implementation uses the proper
# HCT color space from Coloraide (CAM16 hue/chroma + CIELAB tone).

# Written nearly entirely by a Large Language Model, deepseek, with human
# guidance in features and fixes.

# DEPENDENCIES
# pip install Pillow numpy scikit-learn coloraide
#
# Required versions:
# - Pillow>=9.0.0
# - numpy>=1.21.0
# - scikit-learn>=1.0.0
# - coloraide>=2.2.0

# USAGE
# python HCT_quantize_get_dominant_colors.py --input IMAGE_FILE [--numbercolors N] 
#                                           [--output FILE] [--output-format {hex,hct}]
#                                           [--cores PERCENT]
#
# Examples:
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg
#   python HCT_quantize_get_dominant_colors.py -i image.png -n 5
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg -n 3 -o colors.txt
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg -f hct
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg -n 4 -f hct -o hct_values.txt
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --cores 0.7  # Use 75% of CPU cores
#   python HCT_quantize_get_dominant_colors.py --help
#
# Short options:
#   -i : --input
#   -n : --numbercolors
#   -o : --output
#   -f : --output-format

# NOTES
# - If --numbercolors is omitted, defaults to 1 (most dominant color)
# - Output formats:
#   * hex: #RRGGBB format (one per line)
#   * hct: "HUE,CHROMA,TONE" format (one per line, e.g., "245.3,42.1,78.5")
# - The script uses K-means++ initialization for better cluster quality
# - Hue is treated as a circular coordinate for accurate clustering
# - Processing time increases with image size and number of colors requested
# - Use --cores to control CPU usage (0.0-1.0, default: 0.75)

# CODE
import argparse
import sys
import os
import numpy as np
from PIL import Image
from coloraide import Color
from coloraide.everything import ColorAll  # Registers all color spaces including HCT
from sklearn.cluster import KMeans
from multiprocessing import Pool, cpu_count
import warnings
import time
import math

# Suppress sklearn convergence warnings for large images
warnings.filterwarnings('ignore', category=UserWarning)

# Create a Color class with HCT pre-registered
HCTColor = ColorAll

def process_chunk_rgb_to_hct(args):
    """Process a chunk of RGB pixels and return HCT values."""
    chunk_data = args  # Simple chunk of RGB pixels
    
    # Convert to float and normalize to 0-1
    chunk_float = chunk_data.astype(np.float32) / 255.0
    pixels = chunk_float.reshape(-1, 3)
    
    # Convert each pixel to HCT
    hct_values = []
    for pixel in pixels:
        try:
            color = HCTColor('srgb', pixel.tolist())
            color_hct = color.convert('hct')
            h, c, t = color_hct.coords()
            hct_values.append([h, c, t])
        except Exception as e:
            # If conversion fails, append a default (black in HCT)
            hct_values.append([0.0, 0.0, 0.0])
    
    return np.array(hct_values, dtype=np.float32)

def calculate_core_count(percent):
    """Calculate number of cores to use based on percentage."""
    total_cores = cpu_count()
    
    if percent <= 0:
        return 1
    elif percent >= 1:
        return total_cores
    
    # Calculate core count based on percentage
    core_count = max(1, int(round(total_cores * percent)))
    return core_count

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Extract dominant colors from images using proper HCT space quantization (Coloraide)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
HCT Color Space Benefits for Quantization (via Coloraide):
  Hue:    0-360° (circular, from CAM16)
  Chroma: 0-145 (perceptual colorfulness, from CAM16)
  Tone:   0-100 (perceptual lightness, from CIELAB D65)

Output Formats:
  hex : #RRGGBB (e.g., #ff5733)
  hct : HUE,CHROMA,TONE (e.g., 245.3,42.1,78.5)

The HCT space provides perceptually uniform color differences,
resulting in more meaningful dominant color extraction than RGB clustering.
This implementation uses the proper HCT color space from Coloraide.
        """
    )

    parser.add_argument('-i', '--input', required=True,
                       help='Source image file path')
    parser.add_argument('-n', '--numbercolors', type=int, default=1,
                       help='Number of dominant colors to extract (default: 1)')
    parser.add_argument('-o', '--output',
                       help='Output file to save colors (one per line)')
    parser.add_argument('-f', '--output-format', choices=['hex', 'hct'], default='hex',
                       help='Output format: hex (#RRGGBB) or hct (HUE,CHROMA,TONE) (default: hex)')
    parser.add_argument('--cores', type=float, default=0.75,
                       help='Percentage of CPU cores to use for conversion (0.0-1.0, default: 0.75)')

    args = parser.parse_args()

    # Validate cores parameter
    if args.cores < 0 or args.cores > 1:
        print("\nError: --cores must be between 0.0 and 1.0\n", file=sys.stderr)
        sys.exit(1)

    # Validate number of colors
    if args.numbercolors < 1:
        print("\nError: Number of colors must be at least 1!\n", file=sys.stderr)
        sys.exit(1)

    # Check if input file exists
    if not os.path.exists(args.input):
        print(f"\nError: Input file '{args.input}' not found!\n", file=sys.stderr)
        sys.exit(1)

    print(f"\nLoading image: {args.input}")
    print(f"Using proper HCT color space from Coloraide (CAM16 + CIELAB)")

    try:
        # Load image and convert to RGB array
        img = Image.open(args.input).convert('RGB')
        
        # Get image dimensions
        width, height = img.size
        total_pixels = width * height
        print(f"Image size: {width}x{height} pixels")
        print(f"Output format: {args.output_format.upper()}")
        
        # Convert to numpy array
        img_array = np.array(img)
        
        # Sample pixels if image is very large
        max_pixels = 1000000  # 1M pixels is usually sufficient for color extraction
        if total_pixels > max_pixels:
            # Flatten and sample
            pixels_flat = img_array.reshape(-1, 3)
            sample_indices = np.random.choice(total_pixels, max_pixels, replace=False)
            pixels_rgb = pixels_flat[sample_indices]
            print(f"Sampling {max_pixels:,} pixels for processing (image too large)")
        else:
            pixels_rgb = img_array.reshape(-1, 3)
        
        print(f"Converting {len(pixels_rgb):,} pixels to HCT space using {args.cores*100:.0f}% of CPU cores...")
        
        start_time = time.time()
        
        # Calculate cores to use for parallel conversion
        cores_to_use = calculate_core_count(args.cores)
        
        # Split pixels into chunks for parallel conversion
        chunk_size = max(1000, len(pixels_rgb) // (cores_to_use * 4))  # Smaller chunks for better load balancing
        chunks = []
        for i in range(0, len(pixels_rgb), chunk_size):
            chunk = pixels_rgb[i:i+chunk_size]
            chunks.append(chunk)
        
        # Convert RGB to HCT in parallel
        all_hct = []
        with Pool(processes=cores_to_use) as pool:
            for i, result in enumerate(pool.imap(process_chunk_rgb_to_hct, chunks)):
                all_hct.append(result)
                # Simple progress indicator for conversion phase
                if (i + 1) % max(1, len(chunks) // 10) == 0:
                    pct = (i + 1) / len(chunks) * 100
                    print(f"  Conversion: {pct:.0f}% complete", end='\r')
        
        print()  # New line after progress
        
        # Combine all HCT values
        pixels_hct = np.vstack(all_hct)
        
        conversion_time = time.time() - start_time
        print(f"Conversion completed in {conversion_time:.2f} seconds")
        
        # Handle hue as a circular coordinate for clustering
        hue_rad = np.radians(pixels_hct[:, 0])
        hue_sin = np.sin(hue_rad)
        hue_cos = np.cos(hue_rad)
        
        # Create feature array for clustering
        # Weight the components appropriately:
        # - Hue sin/cos: full weight (circular)
        # - Chroma: weight 1.0 (normalized to 0-1)
        # - Tone: weight 1.0 (normalized to 0-1)
        # Chroma max is around 145 in HCT, but normalize to 0-1
        features = np.column_stack([
            hue_sin,
            hue_cos,
            pixels_hct[:, 1] / 145.0,  # Normalize chroma to 0-1
            pixels_hct[:, 2] / 100.0    # Normalize tone to 0-1
        ])
        
        print(f"Performing K-means clustering to find {args.numbercolors} dominant colors...")
        
        cluster_start = time.time()
        
        # Perform K-means clustering
        kmeans = KMeans(
            n_clusters=args.numbercolors,
            init='k-means++',
            n_init=10,
            max_iter=300,
            random_state=42,
            verbose=0
        )
        
        kmeans.fit(features)
        
        cluster_time = time.time() - cluster_start
        print(f"Clustering completed in {cluster_time:.2f} seconds")
        
        # Get cluster centers (in our feature space)
        centers_features = kmeans.cluster_centers_
        
        # Convert back to HCT coordinates
        centers_hct = np.zeros((len(centers_features), 3))
        
        # Reconstruct hue from sin/cos components
        hue_sin_center = centers_features[:, 0]
        hue_cos_center = centers_features[:, 1]
        centers_hct[:, 0] = np.degrees(np.arctan2(hue_sin_center, hue_cos_center)) % 360
        
        # Denormalize chroma and tone
        centers_hct[:, 1] = centers_features[:, 2] * 145.0  # Chroma
        centers_hct[:, 2] = centers_features[:, 3] * 100.0  # Tone
        
        # Clamp values to valid ranges
        centers_hct[:, 1] = np.clip(centers_hct[:, 1], 0, 145)
        centers_hct[:, 2] = np.clip(centers_hct[:, 2], 0, 100)
        
        # Prepare output based on format
        output_lines = []
        
        if args.output_format == 'hex':
            print("Converting dominant colors to sRGB for hex output...")
            
            # Convert HCT centers to RGB using Coloraide
            hex_colors = []
            for hct_center in centers_hct:
                h, c, t = hct_center
                color_hct = HCTColor('hct', [h, c, t])
                color_rgb = color_hct.convert('srgb')
                r, g, b = color_rgb.coords()
                
                # Convert to 8-bit and hex
                r_8bit = int(np.clip(r * 255, 0, 255))
                g_8bit = int(np.clip(g * 255, 0, 255))
                b_8bit = int(np.clip(b * 255, 0, 255))
                hex_colors.append(f"#{r_8bit:02x}{g_8bit:02x}{b_8bit:02x}")
            
            output_lines = hex_colors
            
            print(f"\nDominant color(s) in HEX format:\n")
            for i, (hex_color, hct) in enumerate(zip(output_lines, centers_hct)):
                print(f"  {i+1}. {hex_color}  (H:{hct[0]:.1f}°, C:{hct[1]:.1f}, T:{hct[2]:.1f})")
                
        else:  # hct format
            # Format HCT values with reasonable precision
            output_lines = [f"{hct[0]:.1f},{hct[1]:.1f},{hct[2]:.1f}" for hct in centers_hct]
            
            print(f"\nDominant color(s) in HCT format (HUE,CHROMA,TONE):\n")
            for i, hct_line in enumerate(output_lines):
                print(f"  {i+1}. {hct_line}")
        
        # Output to file if specified
        if args.output:
            try:
                with open(args.output, 'w') as f:
                    for line in output_lines:
                        f.write(f"{line}\n")
                print(f"\nResults saved to: {args.output}")
            except Exception as e:
                print(f"\nError saving to file: {e}", file=sys.stderr)
        
        # Always output to stdout as well
        print(f"\n{'HEX' if args.output_format == 'hex' else 'HCT'} output:")
        for line in output_lines:
            print(line)
        
        total_time = time.time() - start_time
        print(f"\nTotal processing time: {total_time:.2f} seconds")
        print("Done!\n")
        
    except Exception as e:
        print(f"\nError processing image: {e}\n", file=sys.stderr)
        sys.exit(1)