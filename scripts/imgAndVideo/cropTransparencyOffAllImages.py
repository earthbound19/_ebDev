# DESCRIPTION
# Analyzes and/or crops borders from images based on alpha (transparency), bright pixels, or dark pixels.
# Supports three cropping modes: alpha (transparency channel), bright (opaque bright pixels), or dark (dark/black pixels).
# Includes diagnostic mode to help determine optimal parameters, and auto mode to choose
# the best cropping method automatically.

# DEPENDENCIES
# Python 3.6+
# Required packages:
#   - Pillow (PIL) for image processing
#   - numpy for array operations
# Install with: pip install Pillow numpy

# USAGE
# Run from a directory containing images of a given type, with required and if you desire optional parameters.
#
# BASIC USAGE:
#   python cropTransparencyOffAllImages.py -t png --mode alpha --threshold 0.95
#   python cropTransparencyOffAllImages.py -t jpg --mode bright --threshold 0.90 -o
#   python cropTransparencyOffAllImages.py -t png --mode dark --threshold 0.95
#   python cropTransparencyOffAllImages.py -t png --auto --threshold 0.95
#   python cropTransparencyOffAllImages.py -t png --diagnose
#
# REQUIRED ARGUMENTS:
#   -t, --type        Image file type to process (e.g., png, jpg, jpeg, gif, tiff)
#                     Case insensitive - will match .PNG, .JPG, etc.
#
# CROP MODE ARGUMENTS (mutually exclusive - pick one):
#   -m, --mode        {alpha,bright,dark}  Explicitly choose cropping mode:
#                       alpha  - Crop based on transparency channel
#                                (removes transparent borders)
#                       bright - Crop based on pixel brightness
#                                (removes white or bright-colored borders)
#                       dark   - Crop based on pixel darkness
#                                (removes black or dark-colored borders)
#   
#   -a, --auto        Automatically choose best mode for each image
#                     Compares alpha, bright, and dark results and picks the one
#                     that removes more pixels (produces smaller image)
#
#   -d, --diagnose    Run in diagnostic mode (analyze only, no file changes)
#                     Shows detailed analysis of alpha, bright, and dark pixels,
#                     predicts crop results at various thresholds, and
#                     recommends optimal settings.
#
# THRESHOLD ARGUMENT:
#   --threshold       Decimal value 0.0-1.0 controlling how aggressive the cropping is.
#                     Default: 1.0 (crop only pure transparent, pure white, or pure black)
#                     
#                     In ALPHA mode:
#                       threshold = 0.95 means "crop off pixels that are 95% transparent or more"
#                       (internally: pixels with alpha <= (1-0.95)*255 = 12 are considered transparent)
#                       Lower threshold = more aggressive cropping (includes partially transparent pixels)
#                       Higher threshold = less aggressive (only fully transparent pixels)
#                     
#                     In BRIGHT mode:
#                       threshold = 0.95 means "crop off pixels that are 95% bright or more"
#                       (internally: pixels with each RGB channel >= 0.95*255 = 242 are considered bright)
#                       Lower threshold = more aggressive cropping (includes off-white, light colors)
#                       Higher threshold = less aggressive (only pure white #FFFFFF)
#
#                     In DARK mode:
#                       threshold = 0.95 means "crop off pixels that are 95% dark or more"
#                       (internally: pixels with each RGB channel <= (1-0.95)*255 = 12 are considered dark)
#                       Lower threshold = more aggressive cropping (includes dark grays, near-black colors)
#                       Higher threshold = less aggressive (only pure black #000000)
#
# OUTPUT CONTROL:
#   -o, --overwrite   Overwrite original files instead of creating new _cropped files
#                     Use with caution - original files cannot be recovered!
#                     When omitted, saves as filename_cropped.ext
#
# EXAMPLES:
#
# 1. BASIC CROPPING:
#    Crop all PNGs, removing transparent borders (alpha mode, default threshold 1.0):
#      python cropTransparencyOffAllImages.py -t png --mode alpha
#
#    Crop all JPGs, removing white borders with 90% threshold:
#      python cropTransparencyOffAllImages.py -t jpg --mode bright --threshold 0.90
#
#    Crop all JPGs, removing black borders with 95% threshold:
#      python cropTransparencyOffAllImages.py -t jpg --mode dark --threshold 0.95
#
#    Crop all PNGs, removing transparent borders, overwrite originals:
#      python cropTransparencyOffAllImages.py -t png --mode alpha -o
#
# 2. AUTO MODE:
#    Let the script decide alpha vs bright vs dark for each PNG (95% threshold):
#      python cropTransparencyOffAllImages.py -t png --auto --threshold 0.95
#
#    Auto mode with aggressive cropping (80% threshold) on JPGs:
#      python cropTransparencyOffAllImages.py -t jpg --auto --threshold 0.80 -o
#
# 3. DIAGNOSTIC MODE (no file changes):
#    Analyze all PNGs with default threshold:
#      python cropTransparencyOffAllImages.py -t png --diagnose
#
#    Analyze JPGs with specific threshold to see effects:
#      python cropTransparencyOffAllImages.py -t jpg --diagnose --threshold 0.95
#
#    Diagnose and get recommendations for optimal settings:
#      python cropTransparencyOffAllImages.py -t png --diagnose --threshold 0.95
#
# 4. WORKFLOW EXAMPLES:
#
#    Step 1 - Diagnose first to understand your images:
#      python cropTransparencyOffAllImages.py -t png --diagnose
#
#    Step 2 - Based on diagnosis, try a threshold:
#      python cropTransparencyOffAllImages.py -t png --mode alpha --threshold 0.95
#
#    Step 3 - If results are good, process all with auto mode:
#      python cropTransparencyOffAllImages.py -t png --auto --threshold 0.95 -o
#
# 5. ADVANCED EXAMPLES:
#
#    Process multiple file types (use wildcards with shell loop):
#      for ext in png jpg tiff; do
#        python cropTransparencyOffAllImages.py -t $ext --auto --threshold 0.95
#      done
#
#    Diagnose a mix of file types:
#      python cropTransparencyOffAllImages.py -t png --diagnose --threshold 0.90
#      python cropTransparencyOffAllImages.py -t jpg --diagnose --threshold 0.90
#
#    Aggressive bright cropping for scanned documents:
#      python cropTransparencyOffAllImages.py -t jpg --mode bright --threshold 0.85 -o
#
#    Aggressive dark cropping for product photos on black background:
#      python cropTransparencyOffAllImages.py -t png --mode dark --threshold 0.85 -o
#
#    Conservative alpha cropping for UI assets:
#      python cropTransparencyOffAllImages.py -t png --mode alpha --threshold 0.99
#
# NOTES ON THRESHOLD SELECTION:
#   - Start with --diagnose to see pixel distribution
#   - For alpha mode: Look at the "Alpha thresholds" section
#     * If most pixels are at 0% transparent, use threshold 1.0
#     * If edges are semi-transparent, lower threshold (0.95-0.98)
#   
#   - For bright mode: Look at the "Bright thresholds" section
#     * If borders are pure white (#FFFFFF), use threshold 1.0
#     * If borders are off-white or have anti-aliasing, lower threshold (0.90-0.95)
#   
#   - For dark mode: Look at the "Dark thresholds" section
#     * If borders are pure black (#000000), use threshold 1.0
#     * If borders are dark gray or have anti-aliasing, lower threshold (0.90-0.95)
#   
#   - In auto mode: Script picks the more aggressive crop at your threshold
#   
#   - Recommended starting points:
#     * Screenshots with white backgrounds: --mode bright --threshold 0.95
#     * Product photos on black backgrounds: --mode dark --threshold 0.95
#     * PNG graphics with transparency: --mode alpha --threshold 0.98
#     * Mixed content: --auto --threshold 0.95
#     * Unknown images: --diagnose first!


# CODE
import argparse
import os
import numpy as np
from PIL import Image

parser = argparse.ArgumentParser(
    description='Analyze and/or crop borders from images based on alpha (transparency), bright pixels, or dark pixels.'
)
parser.add_argument(
    '-t', '--type',
    required=True,
    help='Image file type to process (e.g., png, jpg, jpeg)'
)
parser.add_argument(
    '-m', '--mode',
    choices=['alpha', 'bright', 'dark'],
    help='Crop mode: "alpha" (transparency), "bright" (bright pixels), or "dark" (dark pixels). Not needed if using --auto.'
)
parser.add_argument(
    '--threshold',
    type=float,
    default=1.0,
    help='Threshold as decimal 0.0-1.0. In alpha mode: pixels with alpha <= (1-threshold) are transparent. In bright mode: pixels with each RGB channel >= (255 * threshold) are considered bright. In dark mode: pixels with each RGB channel <= (255 * (1-threshold)) are considered dark. (default: 1.0)'
)
parser.add_argument(
    '-a', '--auto',
    action='store_true',
    help='Automatically choose best mode (alpha, bright, or dark) based on which produces larger crop'
)
parser.add_argument(
    '-d', '--diagnose',
    action='store_true',
    help='Run in diagnostic mode (analyze only, no file changes)'
)
parser.add_argument(
    '-o', '--overwrite',
    action='store_true',
    help='Overwrite original files instead of creating new _cropped files (crop mode only)'
)

args = parser.parse_args()

# Validate arguments
if not args.diagnose and not args.auto and args.mode is None:
    parser.error("Either --mode or --auto must be specified when not in diagnose mode")
if args.auto and args.mode is not None:
    parser.error("Cannot specify both --mode and --auto")
if args.threshold < 0.0 or args.threshold > 1.0:
    parser.error("Threshold must be between 0.0 and 1.0")

def threshold_to_alpha_cutoff(threshold):
    """
    Convert user-friendly threshold (0.0-1.0) to alpha cutoff value.
    threshold=0.95 means "95% transparent" -> alpha <= (1-0.95)*255 = 12.75
    """
    return int((1.0 - threshold) * 255)

def threshold_to_bright_cutoff(threshold):
    """
    Convert user-friendly threshold (0.0-1.0) to bright cutoff value.
    threshold=0.95 means "95% bright" -> each channel >= 0.95*255 = 242.25
    """
    return int(threshold * 255)

def threshold_to_dark_cutoff(threshold):
    """
    Convert user-friendly threshold (0.0-1.0) to dark cutoff value.
    threshold=0.95 means "95% dark" -> each channel <= (1-0.95)*255 = 12.75
    """
    return int((1.0 - threshold) * 255)

def diagnose_image(filepath, threshold):
    """Run diagnostic analysis on a single image."""
    print(f"\n{'='*60}")
    print(f"Diagnosing: {filepath}")
    print('='*60)
    
    try:
        img = Image.open(filepath)
        
        # Basic info
        print(f"\nBASIC INFO:")
        print(f"  Mode: {img.mode}")
        print(f"  Size: {img.size[0]} x {img.size[1]}")
        print(f"  Format: {img.format}")
        
        # Alpha (transparency) analysis
        print(f"\nALPHA (TRANSPARENCY) ANALYSIS:")
        has_alpha = img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info)
        print(f"  Has alpha channel: {'Yes' if has_alpha else 'No'}")
        
        if has_alpha:
            # Convert to RGBA for consistent analysis
            if img.mode != 'RGBA':
                rgba = img.convert('RGBA')
            else:
                rgba = img
            
            alpha = np.array(rgba)[:, :, 3]
            
            # Alpha statistics
            print(f"  Alpha min: {alpha.min()}")
            print(f"  Alpha max: {alpha.max()}")
            print(f"  Alpha mean: {alpha.mean():.2f}")
            
            # Alpha at different thresholds (as percentages)
            print(f"\n  Alpha thresholds (as transparency %):")
            for pct in [0.90, 0.95, 0.98, 0.99, 1.0]:
                cutoff = threshold_to_alpha_cutoff(pct)
                transparent = np.sum(alpha <= cutoff)
                total = alpha.size
                trans_pct = transparent/total*100
                print(f"    {pct*100:3.0f}% transparent (alpha <= {cutoff:3d}): {transparent:6d} pixels ({trans_pct:5.2f}%)")
        
        # Bright content analysis
        print(f"\nBRIGHT PIXEL ANALYSIS:")
        # Convert to RGB for analysis
        rgb_img = img.convert('RGB')
        rgb_array = np.array(rgb_img)
        
        if len(rgb_array.shape) == 3:
            r, g, b = rgb_array[:, :, 0], rgb_array[:, :, 1], rgb_array[:, :, 2]
            
            # Bright at different thresholds (as percentages)
            print(f"\n  Bright thresholds (as brightness %):")
            for pct in [0.90, 0.95, 0.98, 0.99, 1.0]:
                cutoff = threshold_to_bright_cutoff(pct)
                bright_pixels = (r >= cutoff) & (g >= cutoff) & (b >= cutoff)
                bright_count = np.sum(bright_pixels)
                total = bright_count + np.sum(~bright_pixels)
                bright_pct = bright_count/total*100
                print(f"    {pct*100:3.0f}% bright (each channel >= {cutoff:3d}): {bright_count:6d} pixels ({bright_pct:5.2f}%)")
            
            # Dark content analysis
            print(f"\nDARK PIXEL ANALYSIS:")
            print(f"\n  Dark thresholds (as darkness %):")
            for pct in [0.90, 0.95, 0.98, 0.99, 1.0]:
                cutoff = threshold_to_dark_cutoff(pct)
                dark_pixels = (r <= cutoff) & (g <= cutoff) & (b <= cutoff)
                dark_count = np.sum(dark_pixels)
                total = dark_count + np.sum(~dark_pixels)
                dark_pct = dark_count/total*100
                print(f"    {pct*100:3.0f}% dark (each channel <= {cutoff:3d}): {dark_count:6d} pixels ({dark_pct:5.2f}%)")
            
            # Find a sample non-bright pixel if exists
            non_bright = (r < 250) | (g < 250) | (b < 250)
            if np.any(non_bright):
                y, x = np.argwhere(non_bright)[0]
                print(f"\n  Sample non-bright pixel at ({x},{y}): RGB({r[y,x]},{g[y,x]},{b[y,x]})")
            
            # Find a sample non-dark pixel if exists
            non_dark = (r > 10) | (g > 10) | (b > 10)
            if np.any(non_dark):
                y, x = np.argwhere(non_dark)[0]
                print(f"  Sample non-dark pixel at ({x},{y}): RGB({r[y,x]},{g[y,x]},{b[y,x]})")
        
        # Calculate what the crop would be for ALL modes
        print(f"\nPREDICTED CROP RESULTS FOR ALL MODES:")
        
        # Store results for comparison
        alpha_results = {}
        bright_results = {}
        dark_results = {}
        
        # Alpha-based crop predictions at various thresholds
        if has_alpha:
            # Get RGBA for cropping
            if img.mode != 'RGBA':
                rgba = img.convert('RGBA')
            else:
                rgba = img
            
            alpha = np.array(rgba)[:, :, 3]
            
            print(f"\n  ALPHA MODE PREDICTIONS:")
            for pct in [0.90, 0.95, 0.98, 0.99, 1.0]:
                cutoff = threshold_to_alpha_cutoff(pct)
                non_trans = alpha > cutoff
                if np.any(non_trans):
                    coords = np.argwhere(non_trans)
                    y0, x0 = coords.min(axis=0)
                    y1, x1 = coords.max(axis=0)
                    crop_box = (x0, y0, x1+1, y1+1)
                    crop_size = (x1+1-x0) * (y1+1-y0)
                    original_size = img.size[0] * img.size[1]
                    reduction_pct = (1 - crop_size/original_size) * 100
                    crop_indicator = " (CROP)" if reduction_pct > 0.1 else " (NO CROP)"
                    print(f"    {pct*100:3.0f}% transparent: ({x0}, {y0}, {x1+1}, {y1+1})  Size: {x1+1-x0} x {y1+1-y0}  Reduction: {reduction_pct:.1f}%{crop_indicator}")
                    alpha_results[pct] = {'box': crop_box, 'size': crop_size, 'reduction': reduction_pct}
                else:
                    print(f"    {pct*100:3.0f}% transparent: No non-transparent pixels found! (NO CROP)")
                    alpha_results[pct] = None
        
        # Bright-based crop predictions at various thresholds
        print(f"\n  BRIGHT MODE PREDICTIONS:")
        for pct in [0.90, 0.95, 0.98, 0.99, 1.0]:
            cutoff = threshold_to_bright_cutoff(pct)
            non_bright = (r < cutoff) | (g < cutoff) | (b < cutoff)
            if np.any(non_bright):
                coords = np.argwhere(non_bright)
                y0, x0 = coords.min(axis=0)
                y1, x1 = coords.max(axis=0)
                crop_box = (x0, y0, x1+1, y1+1)
                crop_size = (x1+1-x0) * (y1+1-y0)
                original_size = img.size[0] * img.size[1]
                reduction_pct = (1 - crop_size/original_size) * 100
                crop_indicator = " (CROP)" if reduction_pct > 0.1 else " (NO CROP)"
                print(f"    {pct*100:3.0f}% bright: ({x0}, {y0}, {x1+1}, {y1+1})  Size: {x1+1-x0} x {y1+1-y0}  Reduction: {reduction_pct:.1f}%{crop_indicator}")
                bright_results[pct] = {'box': crop_box, 'size': crop_size, 'reduction': reduction_pct}
            else:
                print(f"    {pct*100:3.0f}% bright: No non-bright pixels found! (NO CROP)")
                bright_results[pct] = None
        
        # Dark-based crop predictions at various thresholds
        print(f"\n  DARK MODE PREDICTIONS:")
        for pct in [0.90, 0.95, 0.98, 0.99, 1.0]:
            cutoff = threshold_to_dark_cutoff(pct)
            non_dark = (r > cutoff) | (g > cutoff) | (b > cutoff)
            if np.any(non_dark):
                coords = np.argwhere(non_dark)
                y0, x0 = coords.min(axis=0)
                y1, x1 = coords.max(axis=0)
                crop_box = (x0, y0, x1+1, y1+1)
                crop_size = (x1+1-x0) * (y1+1-y0)
                original_size = img.size[0] * img.size[1]
                reduction_pct = (1 - crop_size/original_size) * 100
                crop_indicator = " (CROP)" if reduction_pct > 0.1 else " (NO CROP)"
                print(f"    {pct*100:3.0f}% dark: ({x0}, {y0}, {x1+1}, {y1+1})  Size: {x1+1-x0} x {y1+1-y0}  Reduction: {reduction_pct:.1f}%{crop_indicator}")
                dark_results[pct] = {'box': crop_box, 'size': crop_size, 'reduction': reduction_pct}
            else:
                print(f"    {pct*100:3.0f}% dark: No non-dark pixels found! (NO CROP)")
                dark_results[pct] = None
        
        # Direct comparison at the user's specified threshold
        print(f"\n  DIRECT COMPARISON AT {threshold*100:.0f}% THRESHOLD:")
        user_pct = threshold
        
        alpha_result = alpha_results.get(user_pct, None) if has_alpha else None
        bright_result = bright_results.get(user_pct, None)
        dark_result = dark_results.get(user_pct, None)
        
        # Collect available results
        available_results = []
        if alpha_result is not None:
            available_results.append(('ALPHA', alpha_result['reduction']))
        if bright_result is not None:
            available_results.append(('BRIGHT', bright_result['reduction']))
        if dark_result is not None:
            available_results.append(('DARK', dark_result['reduction']))
        
        if not available_results:
            print(f"    All modes: No content pixels found - no crop possible")
        else:
            # Print each mode's reduction
            if alpha_result is not None:
                print(f"    Alpha mode: {alpha_result['reduction']:.1f}% reduction")
            else:
                print(f"    Alpha mode: No crop possible")
            
            if bright_result is not None:
                print(f"    Bright mode: {bright_result['reduction']:.1f}% reduction")
            else:
                print(f"    Bright mode: No crop possible")
            
            if dark_result is not None:
                print(f"    Dark mode: {dark_result['reduction']:.1f}% reduction")
            else:
                print(f"    Dark mode: No crop possible")
            
            # Find winner
            if len(available_results) > 1:
                winner, winner_reduction = max(available_results, key=lambda x: x[1])
                print(f"    {winner} WINS with {winner_reduction:.1f}% reduction")
            elif len(available_results) == 1:
                winner, winner_reduction = available_results[0]
                print(f"    Only {winner} mode produces a crop ({winner_reduction:.1f}% reduction)")
        
        # Recommendation based on which removes more
        print(f"\n  RECOMMENDATION:")
        recommendations = []
        
        if alpha_result is not None:
            recommendations.append(('alpha', alpha_result['reduction']))
        if bright_result is not None:
            recommendations.append(('bright', bright_result['reduction']))
        if dark_result is not None:
            recommendations.append(('dark', dark_result['reduction']))
        
        if recommendations:
            best_mode, best_reduction = max(recommendations, key=lambda x: x[1])
            print(f"    Use --mode {best_mode} for maximum crop ({best_reduction:.1f}% reduction)")
            
            # Show alternative if close
            if len(recommendations) > 1:
                second_best = sorted(recommendations, key=lambda x: x[1], reverse=True)[1]
                if second_best[1] > best_reduction * 0.95:  # Within 5% of best
                    print(f"    Alternative: --mode {second_best[0]} also works well ({second_best[1]:.1f}% reduction)")
        else:
            print(f"    No crop possible at {threshold*100:.0f}% threshold - try lowering the threshold")
        
    except Exception as e:
        print(f"Error diagnosing {filepath}: {e}")

def bbox_by_alpha(im, threshold):
    """
    Calculate bounding box that contains all non-transparent pixels based on alpha channel.
    threshold is user-friendly decimal where higher = more aggressive cropping of transparent areas.
    """
    alpha_cutoff = threshold_to_alpha_cutoff(threshold)
    
    # Convert to RGBA if necessary to ensure alpha channel
    if im.mode != 'RGBA':
        if im.mode == 'P' and 'transparency' in im.info:
            im = im.convert('RGBA')
        elif im.mode in ('RGB', 'L', 'LA'):
            im = im.convert('RGBA')
        else:
            # If no alpha channel, return full image bounds
            print(f"  Note: Image has no alpha channel, returning full bounds")
            return (0, 0, im.width, im.height)
    
    # Get alpha channel
    a = np.array(im)[:, :, 3]
    
    # Find pixels with alpha > cutoff (non-transparent)
    non_transparent = a > alpha_cutoff
    
    if not np.any(non_transparent):
        return None
    
    coords = np.argwhere(non_transparent)
    y0, x0 = coords.min(axis=0)
    y1, x1 = coords.max(axis=0)
    
    return (x0, y0, x1 + 1, y1 + 1)

def bbox_by_bright(im, threshold):
    """
    Calculate bounding box that contains all non-bright pixels.
    threshold is user-friendly decimal where higher = more aggressive cropping of bright areas.
    """
    bright_cutoff = threshold_to_bright_cutoff(threshold)
    
    # Convert to RGB for consistent processing
    if im.mode != 'RGB':
        im_rgb = im.convert('RGB')
    else:
        im_rgb = im
    
    # Get RGB array
    rgb_array = np.array(im_rgb)
    
    # Create a mask for non-bright pixels
    # For each pixel, check if it's NOT bright within threshold
    if len(rgb_array.shape) == 3 and rgb_array.shape[2] >= 3:
        r, g, b = rgb_array[:, :, 0], rgb_array[:, :, 1], rgb_array[:, :, 2]
        
        # Check if any channel is below the bright cutoff
        non_bright = (r < bright_cutoff) | (g < bright_cutoff) | (b < bright_cutoff)
    else:
        # Grayscale image
        non_bright = rgb_array < bright_cutoff
    
    if not np.any(non_bright):
        return None
    
    coords = np.argwhere(non_bright)
    y0, x0 = coords.min(axis=0)
    y1, x1 = coords.max(axis=0)
    
    return (x0, y0, x1 + 1, y1 + 1)

def bbox_by_dark(im, threshold):
    """
    Calculate bounding box that contains all non-dark pixels.
    threshold is user-friendly decimal where higher = more aggressive cropping of dark areas.
    """
    dark_cutoff = threshold_to_dark_cutoff(threshold)
    
    # Convert to RGB for consistent processing
    if im.mode != 'RGB':
        im_rgb = im.convert('RGB')
    else:
        im_rgb = im
    
    # Get RGB array
    rgb_array = np.array(im_rgb)
    
    # Create a mask for non-dark pixels
    # For each pixel, check if it's NOT dark within threshold
    if len(rgb_array.shape) == 3 and rgb_array.shape[2] >= 3:
        r, g, b = rgb_array[:, :, 0], rgb_array[:, :, 1], rgb_array[:, :, 2]
        
        # Check if any channel is above the dark cutoff (non-dark means it has some color/brightness)
        non_dark = (r > dark_cutoff) | (g > dark_cutoff) | (b > dark_cutoff)
    else:
        # Grayscale image
        non_dark = rgb_array > dark_cutoff
    
    if not np.any(non_dark):
        return None
    
    coords = np.argwhere(non_dark)
    y0, x0 = coords.min(axis=0)
    y1, x1 = coords.max(axis=0)
    
    return (x0, y0, x1 + 1, y1 + 1)

def choose_best_mode(im, threshold):
    """
    Determine which mode (alpha, bright, or dark) produces the larger crop.
    Returns (mode_name, crop_box) tuple.
    """
    # Try alpha mode if image has alpha
    alpha_box = None
    has_alpha = im.mode in ('RGBA', 'LA') or (im.mode == 'P' and 'transparency' in im.info)
    if has_alpha:
        alpha_box = bbox_by_alpha(im, threshold)
    
    # Try bright mode
    bright_box = bbox_by_bright(im, threshold)
    
    # Try dark mode
    dark_box = bbox_by_dark(im, threshold)
    
    # Calculate areas
    alpha_area = float('inf')
    if alpha_box is not None:
        alpha_area = (alpha_box[2] - alpha_box[0]) * (alpha_box[3] - alpha_box[1])
    
    bright_area = float('inf')
    if bright_box is not None:
        bright_area = (bright_box[2] - bright_box[0]) * (bright_box[3] - bright_box[1])
    
    dark_area = float('inf')
    if dark_box is not None:
        dark_area = (dark_box[2] - dark_box[0]) * (dark_box[3] - dark_box[1])
    
    # Collect available modes
    available_modes = []
    if alpha_box is not None:
        available_modes.append(('alpha', alpha_box, alpha_area))
    if bright_box is not None:
        available_modes.append(('bright', bright_box, bright_area))
    if dark_box is not None:
        available_modes.append(('dark', dark_box, dark_area))
    
    if not available_modes:
        return None, None
    
    # Choose mode with smallest crop area (most aggressive cropping)
    best_mode, best_box, best_area = min(available_modes, key=lambda x: x[2])
    
    return best_mode, best_box

def analyze_content(im, mode, threshold):
    """
    Analyze image to help diagnose issues during crop mode.
    """
    print(f"\n  Content Analysis:")
    
    if mode == 'alpha':
        alpha_cutoff = threshold_to_alpha_cutoff(threshold)
        # Check for alpha channel
        if im.mode in ('RGBA', 'LA') or (im.mode == 'P' and 'transparency' in im.info):
            # Convert to RGBA for analysis
            if im.mode != 'RGBA':
                im_analyze = im.convert('RGBA')
            else:
                im_analyze = im
            
            a = np.array(im_analyze)[:, :, 3]
            transparent = np.sum(a <= alpha_cutoff)
            opaque = np.sum(a > alpha_cutoff)
            total = a.size
            
            print(f"    Transparent pixels (alpha <= {alpha_cutoff} / {threshold*100:.0f}% transparent): {transparent} ({transparent/total*100:.2f}%)")
            print(f"    Opaque pixels: {opaque} ({opaque/total*100:.2f}%)")
            
            if opaque == 0:
                print("    WARNING: No opaque pixels found!")
        else:
            print(f"    Image has no alpha channel (mode: {im.mode})")
            print(f"    All pixels will be considered 'content' in alpha mode")
    
    elif mode == 'bright':
        bright_cutoff = threshold_to_bright_cutoff(threshold)
        # Convert to RGB for analysis
        im_rgb = im.convert('RGB')
        rgb_array = np.array(im_rgb)
        
        if len(rgb_array.shape) == 3:
            r, g, b = rgb_array[:, :, 0], rgb_array[:, :, 1], rgb_array[:, :, 2]
            
            # Calculate brightness
            bright_pixels = (r >= bright_cutoff) & (g >= bright_cutoff) & (b >= bright_cutoff)
            non_bright = ~bright_pixels
            
            bright_count = np.sum(bright_pixels)
            non_bright_count = np.sum(non_bright)
            total = bright_count + non_bright_count
            
            print(f"    Bright pixels (each channel >= {bright_cutoff} / {threshold*100:.0f}% bright): {bright_count} ({bright_count/total*100:.2f}%)")
            print(f"    Non-bright pixels: {non_bright_count} ({non_bright_count/total*100:.2f}%)")
            
            # Show sample of pixel values if there are non-bright pixels
            if non_bright_count > 0:
                sample_coords = np.argwhere(non_bright)[0]
                sample_y, sample_x = sample_coords
                sample_r, sample_g, sample_b = r[sample_y, sample_x], g[sample_y, sample_x], b[sample_y, sample_x]
                print(f"    Sample non-bright pixel at ({sample_x},{sample_y}): RGB({sample_r},{sample_g},{sample_b})")
    
    elif mode == 'dark':
        dark_cutoff = threshold_to_dark_cutoff(threshold)
        # Convert to RGB for analysis
        im_rgb = im.convert('RGB')
        rgb_array = np.array(im_rgb)
        
        if len(rgb_array.shape) == 3:
            r, g, b = rgb_array[:, :, 0], rgb_array[:, :, 1], rgb_array[:, :, 2]
            
            # Calculate darkness
            dark_pixels = (r <= dark_cutoff) & (g <= dark_cutoff) & (b <= dark_cutoff)
            non_dark = ~dark_pixels
            
            dark_count = np.sum(dark_pixels)
            non_dark_count = np.sum(non_dark)
            total = dark_count + non_dark_count
            
            print(f"    Dark pixels (each channel <= {dark_cutoff} / {threshold*100:.0f}% dark): {dark_count} ({dark_count/total*100:.2f}%)")
            print(f"    Non-dark pixels: {non_dark_count} ({non_dark_count/total*100:.2f}%)")
            
            # Show sample of pixel values if there are non-dark pixels
            if non_dark_count > 0:
                sample_coords = np.argwhere(non_dark)[0]
                sample_y, sample_x = sample_coords
                sample_r, sample_g, sample_b = r[sample_y, sample_x], g[sample_y, sample_x], b[sample_y, sample_x]
                print(f"    Sample non-dark pixel at ({sample_x},{sample_y}): RGB({sample_r},{sample_g},{sample_b})")

def crop_images(file_type, mode=None, threshold=1.0, auto=False, overwrite=False):
    """Crop all images of specified type."""
    # Get all files with the specified extension in current directory
    files = [f for f in os.listdir('.') if f.lower().endswith(f'.{file_type.lower()}')]
    
    if not files:
        print(f"No .{file_type} files found in current directory.")
        return
    
    if auto:
        print(f"\nFound {len(files)} .{file_type} file(s) to process.")
        print(f"Mode: AUTO - will choose best method for each image (alpha/bright/dark)")
        print(f"Threshold: {threshold*100:.0f}% (alpha: >={threshold*100:.0f}% transparent, bright: >={threshold*100:.0f}% bright, dark: >={threshold*100:.0f}% dark)")
        print(f"Overwrite: {'YES' if overwrite else 'NO'}")
    else:
        mode_desc = {
            'alpha': f"crop transparent pixels (>={threshold*100:.0f}% transparent)",
            'bright': f"crop bright pixels (>={threshold*100:.0f}% bright)",
            'dark': f"crop dark pixels (>={threshold*100:.0f}% dark)"
        }
        print(f"\nFound {len(files)} .{file_type} file(s) to process.")
        print(f"Mode: {mode} - {mode_desc[mode]}")
        print(f"Overwrite: {'YES' if overwrite else 'NO'}")
    
    processed = 0
    skipped = 0
    errors = 0
    
    for file_name in files:
        try:
            print(f"\n{'='*60}")
            print(f"Processing: {file_name}")
            
            # Open image
            im = Image.open(file_name)
            original_mode = im.mode
            original_size = im.size
            
            print(f"  Original mode: {original_mode}")
            print(f"  Original size: {original_size[0]}x{original_size[1]}")
            
            # Determine which mode to use
            if auto:
                chosen_mode, crop_box = choose_best_mode(im, threshold)
                if chosen_mode is None:
                    print(f"  WARNING: No content pixels found with any mode! File will not be cropped.")
                    skipped += 1
                    continue
                print(f"  Auto mode chose: {chosen_mode}")
                # Analyze content for the chosen mode
                analyze_content(im, chosen_mode, threshold)
            else:
                # Use specified mode
                analyze_content(im, mode, threshold)
                if mode == 'alpha':
                    crop_box = bbox_by_alpha(im, threshold)
                elif mode == 'bright':
                    crop_box = bbox_by_bright(im, threshold)
                else:  # dark mode
                    crop_box = bbox_by_dark(im, threshold)
            
            if crop_box is None:
                print(f"  WARNING: No content pixels found! File will not be cropped.")
                skipped += 1
                continue
            
            # Crop image
            im_cropped = im.crop(crop_box)
            
            # Try to preserve original mode
            if im_cropped.mode != original_mode:
                try:
                    im_cropped = im_cropped.convert(original_mode)
                except:
                    pass  # Keep as is if conversion fails
            
            # Determine output filename
            if overwrite:
                output_name = file_name
            else:
                base, ext = os.path.splitext(file_name)
                output_name = f"{base}_cropped{ext}"
            
            # Save
            im_cropped.save(output_name)
            
            # Report results
            new_size = im_cropped.size
            original_area = original_size[0] * original_size[1]
            new_area = new_size[0] * new_size[1]
            reduction_pct = (1 - new_area/original_area) * 100
            
            print(f"\n  Crop box: {crop_box}")
            print(f"  New size: {new_size[0]}x{new_size[1]}")
            print(f"  Reduction: {original_area - new_area} pixels ({reduction_pct:.1f}%)")
            print(f"  Saved as: {output_name}")
            
            processed += 1
            
        except Exception as e:
            print(f"  ERROR processing {file_name}: {e}")
            errors += 1
    
    print(f"\n{'='*60}")
    print(f"SUMMARY: {processed} processed, {skipped} skipped, {errors} errors")

def diagnose_images(file_type, threshold):
    """Run diagnostic mode on all images."""
    files = [f for f in os.listdir('.') if f.lower().endswith(f'.{file_type.lower()}')]
    
    if not files:
        print(f"No .{file_type} files found in current directory.")
        return
    
    print(f"\nFound {len(files)} .{file_type} file(s) to diagnose.")
    print(f"Diagnostic mode: ANALYZE ONLY - no files will be modified")
    print(f"Threshold: {threshold*100:.0f}% (reference value for analysis)")
    
    for file_name in files:
        diagnose_image(file_name, threshold)

# Main execution
if args.diagnose:
    diagnose_images(args.type, args.threshold)
elif args.auto:
    crop_images(args.type, threshold=args.threshold, auto=True, overwrite=args.overwrite)
else:
    crop_images(args.type, mode=args.mode, threshold=args.threshold, overwrite=args.overwrite)