# DESCRIPTION
# White room, platform-independent reimplementation of observable specs for Nicolas Robidoux 
# randomblob.sh (bash / imagemagick). Generates a binary image (black blob on white background) 
# from randomly distributed points connected by thick lines or splines, then Gaussian blurred 
# and thresholded. Features high-quality rendering via aggdraw library, parallel processing 
# support, and optional SVG output.

# DEPENDENCIES
# - Python 3.6+
# - Pillow (PIL) for image processing
# - aggdraw for high-quality vector rendering
# - tqdm (optional) for enhanced progress bars
# - multiprocessing (standard library) for parallel operations

# USAGE
# python randomBlob.py [options] [maskfile] outfile

# Basic image output
# python randomBlob.py -n 20 -l 15 -o 800 blob.png

# Save the cool scribble intermediate image
# python randomBlob.py -n 20 -l 15 --save-connected blob.png

# SVG output with custom spline parameters
# python randomBlob.py -n 30 -d spline -T 0.5 -C -0.2 -B 0.3 --typeoutput svg blob.svg

# Use 75% of available CPU cores
# python randomBlob.py -n 100 --cpu 75 complex_blob.png

# NOTES
# - This is a clean room reimplementation, dedicated to the Public Domain
# - All parameters match the original randomblob.sh switch names exactly
# - New features use long options only to avoid conflict with original switches
# - For large point counts or high resolution, processing may take several seconds
# - **SVG NOTE**: SVG output produces self-intersecting shapes that differ
#   from the raster blobs. This is due to fundamental differences between vector and
#   raster rendering (paths vs blurred/thresholded lines). The raster version gives
#   organic blobs; the SVG version gives interesting squiggle art. Both are valid
#   outputs for different use cases.
# - **Intermediate images**: The --save-connected flag saves the pre-blur "scribble" image,
#   which also can have its own artistic merit.

# Additions unique to this Python implementation ("V2") :
# - Parallel processing with percentage-based CPU allocation (--cpu)
# - SVG export with minimal, vendor-neutral paths (--typeoutput)
# - Progress bar with rich terminal output (--no-progress to disable)
# - aggdraw integration for professional rendering
# - Bezier splines for mathematical precision
# - Comprehensive validation with helpful error messages
# - Blob size validation to warn about potentially empty outputs
# - Separate --save-connected flag for intermediate scribble images

# V3 ENHANCEMENTS TO CONSIDER
# - GPU acceleration via CUDA/OpenCL
# - WebAssembly build for browser use
# - Interactive parameter tuning with live preview
# - Batch processing with parameter sweeps
# - Color gradients and multiple blobs
# - 3D extrusion of blobs
# - Machine learning training data generation
# - REST API service
# - **SVG Blob Simulation**: Add SVG filters (feGaussianBlur + threshold) to more closely
#   mimic the raster look in vector output


# CODE
"""
Current dev fix attempt notes:
The intermediate "scribble" images are the raw connected points before blur
and threshold. The fact that they look good but sometimes fail to become blobs
suggests the issue is in the blur/threshold pipeline - likely either:
- Blur sigma too high (dissipating the scribble)
- Threshold too aggressive (cutting out too much)
- Line width too thin for the blur to create a connected shape
- The validation will warn you when this happens. You might want to experiment
  with lower blur values or higher line widths for those edge cases.
"""

script_version = '2.48.15'

import sys
import os
import math
import random
import argparse
import warnings
import time
import multiprocessing as mp
from functools import partial
from PIL import Image, ImageFilter
import aggdraw

# Suppress DecompressionBombWarning for large images
warnings.simplefilter('ignore', Image.DecompressionBombWarning)

# Constants
MAX_POINT_ATTEMPTS = 1000
MAX_SPLINE_POINTS = 125000
PROGRESS_UPDATE_INTERVAL = 0.5  # seconds

#------------------------------------------------------------------------------
# Progress Bar (with tqdm fallback)
#------------------------------------------------------------------------------
class ProgressTracker:
    """Simple progress tracker with bar display."""
    def __init__(self, total_stages=7, disable=False):
        self.stages = total_stages
        self.current_stage = 0
        self.disable = disable
        self.last_update = 0
        self.has_tqdm = False
        
        # Try to import tqdm for better progress bars
        try:
            from tqdm import tqdm
            self.tqdm = tqdm
            self.has_tqdm = True
        except ImportError:
            pass
    
    def next_stage(self, stage_name):
        """Advance to next major stage."""
        self.current_stage += 1
        if not self.disable and not self.has_tqdm:
            sys.stderr.write(f"\n{stage_name}...\n")
            sys.stderr.flush()
    
    def update(self, stage_name, current, total):
        """Update progress within current stage."""
        if self.disable:
            return
        
        current_time = time.time()
        if current_time - self.last_update < PROGRESS_UPDATE_INTERVAL and current < total:
            return
        
        self.last_update = current_time
        
        if self.has_tqdm:
            # Let tqdm handle the display
            return
        
        # Simple ASCII progress bar
        overall_progress = (self.current_stage + current/total) / self.stages
        bar_length = 30
        filled = int(bar_length * overall_progress)
        bar = '█' * filled + '░' * (bar_length - filled)
        
        sys.stderr.write(f'\r{stage_name:20} [{bar}] {overall_progress*100:3.0f}% '
                        f'({current}/{total})')
        sys.stderr.flush()
    
    def finish(self):
        """Clean up progress display."""
        if not self.disable and not self.has_tqdm:
            sys.stderr.write('\n')


#------------------------------------------------------------------------------
# Blob Validation
#------------------------------------------------------------------------------
def validate_blob_size(canvas, min_dark_pixels=100, debug=False):
    """
    Check if the blob has enough dark pixels to be visible.
    Returns True if blob seems valid, False otherwise.
    """
    # Count dark pixels (assuming image is still grayscale before threshold)
    # We'll check after blur but before threshold to see if there's any content
    try:
        import numpy as np
        # Convert to numpy array for faster counting
        img_array = np.array(canvas)
        # Count pixels darker than mid-gray (potential blob content)
        dark_pixels = np.sum(img_array < 128)
        
        if dark_pixels < min_dark_pixels:
            if debug:
                print(f"WARNING: Very few dark pixels ({dark_pixels}) detected. "
                      f"Blob may be nearly invisible after threshold.", file=sys.stderr)
            return False
        return True
    except ImportError:
        # No numpy, skip validation
        if debug:
            print("Note: numpy not installed, skipping blob size validation", file=sys.stderr)
        return True


#------------------------------------------------------------------------------
# Parameter Validation
#------------------------------------------------------------------------------
def validate_parameters(args, output_width, output_height):
    """Validate all parameters against constraints."""
    min_dim = min(output_width, output_height)
    
    # Line width limit (15% of smallest dimension)
    if args.l > min_dim * 0.15:
        raise ValueError(
            f"Line width {args.l} exceeds 15% of smallest dimension {min_dim}.\n"
            f"Maximum allowed: {int(min_dim * 0.15)}"
        )
    
    # Inner size must fit in output
    if args.i > min_dim:
        raise ValueError(
            f"Inner region size {args.i} exceeds output dimension {min_dim}.\n"
            f"Inner region must fit within output image."
        )
    
    # Blur sigma minimum
    if args.b < 0.5:
        args.b = 0.5
        print(f"Warning: Blur sigma too small, set to minimum 0.5", file=sys.stderr)
    elif args.b < 1.0:
        print(f"Warning: Blur sigma {args.b} is very small. "
              f"Consider using >= 1.0 for visible smoothing.", file=sys.stderr)
    
    # Threshold warnings
    if args.t < 5 or args.t > 95:
        print(f"Warning: Extreme threshold value {args.t}. "
              f"This may produce nearly empty or nearly solid images.", file=sys.stderr)
    
    # Spline parameter warnings
    for param, name in [(args.T, 'tension'), (args.C, 'continuity'), (args.B, 'bias')]:
        if param < -1 or param > 1:
            print(f"Warning: {name} value {param} outside typical range [-1,1]. "
                  f"Extreme values may produce unexpected shapes.", file=sys.stderr)
    
    # Validate output types
    valid_types = ['image', 'svg', 'both']
    if args.typeoutput not in valid_types:
        raise ValueError(f"Output type must be one of: {', '.join(valid_types)}")
    
    # Validate CPU percentage
    if args.cpu < 1 or args.cpu > 100:
        raise ValueError("CPU percentage must be between 1 and 100")


def debug_print(debug, *args, **kwargs):
    """Print debug messages to stderr if debug is enabled."""
    if debug:
        print(*args, file=sys.stderr, **kwargs)


def parse_size(size_str):
    """Parse size string which can be WxH or single integer."""
    if 'x' in size_str.lower():
        parts = size_str.lower().split('x')
        return int(parts[0]), int(parts[1])
    else:
        s = int(size_str)
        return s, s


#------------------------------------------------------------------------------
# Point Loading and Generation
#------------------------------------------------------------------------------
def load_points_from_file(filename, count, start_index=0):
    """Load points from file, returning list of (x,y) tuples in range [0,1)."""
    points = []
    try:
        with open(filename, 'r') as f:
            for line_num, line in enumerate(f):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                # Handle comma or whitespace separation
                import re
                parts = re.split(r'[,\s]+', line)
                if len(parts) >= 2:
                    try:
                        x = float(parts[0])
                        y = float(parts[1])
                        if 0 <= x < 1 and 0 <= y < 1:
                            points.append((x, y))
                    except ValueError:
                        raise ValueError(f"Invalid number format at line {line_num+1}: {line}")
    except FileNotFoundError:
        raise FileNotFoundError(f"Points file not found: {filename}")
    except IOError as e:
        raise IOError(f"Error reading points file: {e}")
    
    if len(points) < count:
        raise ValueError(f"Points file has {len(points)} points, need {count}")
    
    # Return last N points available if start_index would exceed bounds
    if start_index + count > len(points):
        print(f"Warning: Requested points beyond end of file. Using last {count} points.",
              file=sys.stderr)
        return points[-count:]
    
    return points[start_index:start_index + count]


def generate_uniform_points(count, inner_size, output_size, shape, constrain_to_mask=None, 
                           progress=None, debug=False):
    """Generate uniformly distributed points using proper Box-Muller."""
    points = []
    width, height = output_size
    half_inner = inner_size / 2.0
    
    # Center of output image
    center_x = (width - 1) / 2.0
    center_y = (height - 1) / 2.0
    
    attempts = 0
    
    while len(points) < count and attempts < MAX_POINT_ATTEMPTS:
        attempts += 1
        
        # Generate p1, p2 using standard Box-Muller (avoid ln(0))
        while True:
            p1 = random.random()
            if p1 > 0:  # Avoid ln(0)
                break
        p2 = random.random()  # Now truly uniform
        
        if shape == 'disk':
            # Distance from center: sqrt(p1) * half_inner
            r = math.sqrt(p1) * half_inner
            theta = 2 * math.pi * p2
            x = r * math.cos(theta) + center_x
            y = r * math.sin(theta) + center_y
        else:  # square
            x = inner_size * (p1 - 0.5) + center_x
            y = inner_size * (p2 - 0.5) + center_y
        
        # Check constraints
        valid = True
        if constrain_to_mask is not None:
            # Check if point is in white region of mask
            ix, iy = int(round(x)), int(round(y))
            if 0 <= ix < width and 0 <= iy < height:
                if constrain_to_mask.getpixel((ix, iy)) == 0:
                    valid = False
            else:
                valid = False
        
        if valid:
            points.append((x, y))
            if progress:
                progress.update("Generating points", len(points), count)
    
    if len(points) < count:
        raise RuntimeError(
            f"Could not generate {count} points after {MAX_POINT_ATTEMPTS} attempts.\n"
            f"This usually indicates that constraints are too restrictive:\n"
            f"- Mask has very small white region\n"
            f"- Inner region ({inner_size}) is too small\n"
            f"- Constrain=yes with tight parameters\n"
            f"- Current parameters: shape={shape}, output_size={output_size}\n\n"
            f"Suggestions:\n"
            f"• Increase inner_size (currently {inner_size})\n"
            f"• Use a larger or less restrictive mask\n"
            f"• Increase minimum points or line width\n"
            f"• Set constrain=no if appropriate\n"
            f"• Check that your random seed isn't producing degenerate configurations"
        )
    
    return points


def generate_gaussian_points(count, sigma, output_size, constrain, constrain_to_mask=None,
                            progress=None, debug=False):
    """Generate points with Gaussian distribution using proper Box-Muller."""
    points = []
    width, height = output_size
    center_x = (width - 1) / 2.0
    center_y = (height - 1) / 2.0
    
    attempts = 0
    
    while len(points) < count and attempts < MAX_POINT_ATTEMPTS:
        attempts += 1
        
        # Box-Muller transform with proper uniform generation
        while True:
            p1 = random.random()
            if p1 > 0:  # Avoid ln(0)
                break
        p2 = random.random()
        
        r = math.sqrt(-2 * math.log(p1))
        theta = 2 * math.pi * p2
        
        x = sigma * r * math.cos(theta) + center_x
        y = sigma * r * math.sin(theta) + center_y
        
        # Check constraints
        valid = True
        if constrain == 'yes':
            if constrain_to_mask is not None:
                ix, iy = int(round(x)), int(round(y))
                if 0 <= ix < width and 0 <= iy < height:
                    if constrain_to_mask.getpixel((ix, iy)) == 0:
                        valid = False
                else:
                    valid = False
        
        if valid:
            points.append((x, y))
            if progress:
                progress.update("Generating points", len(points), count)
    
    if len(points) < count:
        raise RuntimeError(
            f"Could not generate {count} points after {MAX_POINT_ATTEMPTS} attempts.\n"
            f"This usually indicates that constraints are too restrictive:\n"
            f"- Mask has very small white region\n"
            f"- Gaussian sigma ({sigma}) too large for inner region\n"
            f"- Constrain=yes with tight parameters\n"
            f"- Current parameters: constrain={constrain}, output_size={output_size}\n\n"
            f"Suggestions:\n"
            f"• Decrease Gaussian sigma (currently {sigma})\n"
            f"• Increase inner_size\n"
            f"• Use a larger or less restrictive mask\n"
            f"• Set constrain=no if appropriate\n"
            f"• Check that your random seed isn't producing degenerate configurations"
        )
    
    return points


#------------------------------------------------------------------------------
# Kochanek-Bartels Spline to Bezier Conversion
#------------------------------------------------------------------------------
def segment_to_bezier(args):
    """Convert a single Kochanek-Bartels segment to Bezier control points."""
    K0, K1, K2, K3, tension, continuity, bias = args
    
    # Calculate tangents
    term1_x = (K2[0] - K1[0]) / 2
    term1_y = (K2[1] - K1[1]) / 2
    term2_x = (K1[0] - K0[0]) / 2
    term2_y = (K1[1] - K0[1]) / 2
    term3_x = (K3[0] - K2[0]) / 2
    term3_y = (K3[1] - K2[1]) / 2
    term4_x = (K2[0] - K1[0]) / 2
    term4_y = (K2[1] - K1[1]) / 2
    
    t_factor = 1 - tension
    b_factor1 = 1 - bias
    b_factor2 = 1 + bias
    c_factor1 = 1 - continuity
    c_factor2 = 1 + continuity
    
    T1_x = t_factor * (b_factor1 * c_factor1 * term1_x + b_factor2 * c_factor2 * term2_x)
    T1_y = t_factor * (b_factor1 * c_factor1 * term1_y + b_factor2 * c_factor2 * term2_y)
    
    T2_x = t_factor * (b_factor1 * c_factor2 * term3_x + b_factor2 * c_factor1 * term4_x)
    T2_y = t_factor * (b_factor1 * c_factor2 * term3_y + b_factor2 * c_factor1 * term4_y)
    
    # Convert to Bezier control points
    P0 = K1
    P3 = K2
    P1 = (K1[0] + T1_x/3, K1[1] + T1_y/3)
    P2 = (K2[0] - T2_x/3, K2[1] - T2_y/3)
    
    return (P0, P1, P2, P3)


def kochanek_bartels_to_beziers(points, tension=0, continuity=0, bias=0, 
                                parallel=True, cpu_percent=100, progress=None, debug=False):
    """
    Convert Kochanek-Bartels spline control points to Bezier curves.
    Returns list of (P0, P1, P2, P3) Bezier control point tuples.
    """
    if len(points) < 3:
        # Fallback to linear for insufficient points
        if len(points) == 1:
            return [(points[0], points[0], points[0], points[0])]  # Single point
        elif len(points) == 2:
            return [(points[0], points[0], points[1], points[1])]  # Line
        return []
    
    # Close the loop by wrapping points
    wrapped = [points[-1]] + points + [points[0], points[1]]
    
    # Prepare segments for parallel processing
    num_segments = len(points)
    segments = []
    for i in range(num_segments):
        segments.append((
            wrapped[i], wrapped[i+1], wrapped[i+2], wrapped[i+3],
            tension, continuity, bias
        ))
    
    if progress:
        progress.update("Spline conversion", 0, num_segments)
    
    # Process segments (parallel or serial)
    if parallel and num_segments > 10:  # Only parallelize for enough segments
        cpu_count = mp.cpu_count()
        target_cpus = max(1, int(cpu_count * cpu_percent / 100))
        
        if debug:
            debug_print(debug, f"Parallel processing with {target_cpus} CPUs")
        
        with mp.Pool(processes=target_cpus) as pool:
            beziers = []
            for i, result in enumerate(pool.imap(segment_to_bezier, segments)):
                beziers.append(result)
                if progress:
                    progress.update("Spline conversion", i + 1, num_segments)
    else:
        # Serial processing
        beziers = []
        for i, seg in enumerate(segments):
            beziers.append(segment_to_bezier(seg))
            if progress:
                progress.update("Spline conversion", i + 1, num_segments)
    
    return beziers


#------------------------------------------------------------------------------
# Drawing Functions (aggdraw)
#------------------------------------------------------------------------------
def draw_polygon_aggdraw(canvas, points, linewidth, debug=False):
    """Draw closed polygon using aggdraw with round joins."""
    draw = aggdraw.Draw(canvas)
    pen = aggdraw.Pen('black', linewidth)
    
    path = aggdraw.Path()
    for i, point in enumerate(points):
        if i == 0:
            path.moveto(point[0], point[1])
        else:
            path.lineto(point[0], point[1])
    path.close()
    
    draw.path(path, pen)
    draw.flush()
    return canvas


def draw_spline_beziers(canvas, beziers, linewidth, progress=None, debug=False):
    """Draw spline using aggdraw Bezier curves."""
    draw = aggdraw.Draw(canvas)
    pen = aggdraw.Pen('black', linewidth)
    
    path = aggdraw.Path()
    
    for i, (P0, P1, P2, P3) in enumerate(beziers):
        if i == 0:
            path.moveto(P0[0], P0[1])
        
        # Add cubic Bezier curve
        path.curveto(P1[0], P1[1], P2[0], P2[1], P3[0], P3[1])
        
        if progress:
            progress.update("Rendering", i + 1, len(beziers))
    
    # Close the path
    path.close()
    
    draw.path(path, pen)
    draw.flush()
    return canvas


def draw_circle_fallback(canvas, point, radius, linewidth):
    """Fallback for single point - draw a filled circle."""
    from PIL import ImageDraw
    
    # Use PIL's ellipse for fallback
    draw = ImageDraw.Draw(canvas)
    bbox = (
        point[0] - radius,
        point[1] - radius,
        point[0] + radius,
        point[1] + radius
    )
    draw.ellipse(bbox, fill=0)
    return canvas


#------------------------------------------------------------------------------
# SVG Output
#------------------------------------------------------------------------------
def generate_svg_path_data(points, beziers=None, drawtype='line'):
    """Generate SVG path data string for a FILLED blob shape."""
    if drawtype == 'line' or beziers is None:
        # Simple polygon - closed shape
        path_data = f"M {points[0][0]},{points[0][1]}"
        for point in points[1:]:
            path_data += f" L {point[0]},{point[1]}"
        path_data += " Z"  # Close the path
    else:
        # Bezier spline - closed shape
        path_data = f"M {beziers[0][0][0]},{beziers[0][0][1]}"
        for P0, P1, P2, P3 in beziers:
            path_data += f" C {P1[0]},{P1[1]} {P2[0]},{P2[1]} {P3[0]},{P3[1]}"
        path_data += " Z"  # Close the path
    
    return path_data


def save_svg(path_data, output_file, width, height, linewidth):
    """Save SVG file with FILLED blob shape (no outline)."""
    svg_template = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" 
     width="{width}" height="{height}" 
     viewBox="0 0 {width} {height}">
  <path d="{path_data}" 
        fill="black" 
        stroke="none"/>
</svg>'''
    
    with open(output_file, 'w') as f:
        f.write(svg_template)


#------------------------------------------------------------------------------
# Main Function
#------------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description='Generate random blob images')
    
    # Core Parameters (match original randomblob.sh interface)
    parser.add_argument('-n', type=int, default=12, help='Number of random points')
    parser.add_argument('-l', type=int, default=13, help='Width of connecting lines')
    parser.add_argument('-i', type=int, default=400, help='Inner region size (diameter)')
    parser.add_argument('-o', type=str, default='512', help='Output image size (WxH or single)')
    parser.add_argument('-s', type=str, default='disk', choices=['square', 'disk', 's', 'd'], 
                       help='Inner region shape')
    parser.add_argument('-b', type=float, default=33, help='Gaussian blur sigma')
    parser.add_argument('-t', type=int, default=25, help='Threshold percentage (1-99)')
    parser.add_argument('-k', type=str, default='uniform', choices=['uniform', 'gaussian', 'u', 'g'],
                       help='Point distribution')
    parser.add_argument('-g', type=float, default=67, help='Gaussian distribution sigma')
    parser.add_argument('-c', type=str, default='yes', choices=['yes', 'no', 'y', 'n'],
                       help='Constrain to inner region')
    parser.add_argument('-d', type=str, default='spline', choices=['line', 'spline', 'l', 's'],
                       help='Connection method')
    
    # Spline Parameters (match original randomblob.sh interface)
    parser.add_argument('-T', type=float, default=0, help='Spline tension')
    parser.add_argument('-C', type=float, default=0, help='Spline continuity')
    parser.add_argument('-B', type=float, default=0, help='Spline bias')
    
    # File Input Parameters (match original randomblob.sh interface)
    parser.add_argument('-f', type=str, help='Point pairs file (exact count)')
    parser.add_argument('-F', type=str, help='Point pairs file (indexed)')
    
    # Original randomblob.sh features (preserved for compatibility)
    parser.add_argument('-S', type=int, help='Random seed (if not provided, random)')
    parser.add_argument('-p', type=int, default=2, help='Spline interpolation increment (pixels)')
    parser.add_argument('--debug', action='store_true', help='Print debug information')
    parser.add_argument('--save', action='store_true', help='Save intermediate connected image (deprecated, use --save-connected)')
    parser.add_argument('--save-connected', action='store_true', help='Save the connected points image before blurring')
    
    # New Python-only features (long options only to avoid conflicts)
    parser.add_argument('--typeoutput', type=str, default='image', 
                       choices=['image', 'svg', 'both'], help='Output type(s)')
    parser.add_argument('--cpu', type=int, default=100, 
                       help='CPU utilization percentage (1-100)')
    parser.add_argument('--no-progress', action='store_true', help='Disable progress bar')
    
    # Positional arguments
    parser.add_argument('maskfile', nargs='?', help='Optional mask image file')
    parser.add_argument('outfile', help='Output file path (without extension for "both")')
    
    args = parser.parse_args()
    
    # Validate numeric parameters
    if args.n <= 0:
        raise ValueError("Number of points must be > 0")
    if args.l <= 0:
        raise ValueError("Line width must be > 0")
    if args.i <= 0:
        raise ValueError("Inner size must be > 0")
    if args.b <= 0:
        raise ValueError("Blur sigma must be > 0")
    if not 1 <= args.t <= 99:
        raise ValueError("Threshold must be between 1 and 99")
    if args.g <= 0:
        raise ValueError("Gaussian sigma must be > 0")
    if args.p <= 0:
        raise ValueError("Pixel increment must be > 0")
    
    # Parse output size
    output_width, output_height = parse_size(args.o)
    if output_width <= 0 or output_height <= 0:
        raise ValueError("Output dimensions must be > 0")
    
    # Validate all parameters
    validate_parameters(args, output_width, output_height)
    
    # Normalize choices
    shape = 'disk' if args.s in ['disk', 'd'] else 'square'
    kind = 'gaussian' if args.k in ['gaussian', 'g'] else 'uniform'
    constrain = 'yes' if args.c in ['yes', 'y'] else 'no'
    drawtype = 'spline' if args.d in ['spline', 's'] else 'line'
    
    # Initialize progress tracker
    progress = ProgressTracker(total_stages=7, disable=args.no_progress)
    
    debug_print(args.debug, f"Parameters: n={args.n}, l={args.l}, i={args.i}, o={output_width}x{output_height}")
    debug_print(args.debug, f"Shape={shape}, blur={args.b}, threshold={args.t}, kind={kind}")
    debug_print(args.debug, f"Constrain={constrain}, drawtype={drawtype}")
    
    # Set random seed - use provided or generate random
    if args.S is None:
        # Generate a random seed in the acceptable range (1 to 2^32-1)
        args.S = random.randint(1, 2**32 - 1)
        print(f"Generated random seed: {args.S} (use -S {args.S} to reproduce this blob)", file=sys.stderr)
        debug_print(args.debug, f"No seed provided, using randomly generated seed: {args.S}")
    else:
        debug_print(args.debug, f"Using provided seed: {args.S}")
    
    # Now set the random seed
    random.seed(args.S)
    
    progress.next_stage("Loading/Validating")
    
    # Load mask if provided
    mask_image = None
    constrain_mask = None
    if args.maskfile:
        try:
            mask_image = Image.open(args.maskfile).convert('L')
            debug_print(args.debug, f"Loaded mask: {mask_image.size}")
            
            # Validate mask size
            if mask_image.width > output_width or mask_image.height > output_height:
                raise ValueError(
                    f"Mask image ({mask_image.width}x{mask_image.height}) exceeds "
                    f"output dimensions ({output_width}x{output_height}).\n"
                    f"Please resize mask or increase output size."
                )
            
            # Create output-sized mask with black background
            constrain_mask = Image.new('L', (output_width, output_height), 0)
            
            # Center the mask
            x_offset = (output_width - mask_image.width) // 2
            y_offset = (output_height - mask_image.height) // 2
            
            constrain_mask.paste(mask_image, (x_offset, y_offset))
            
            # Override inner region parameters
            args.i = max(mask_image.width, mask_image.height)
            debug_print(args.debug, f"Adjusted inner size to {args.i} based on mask")
        except Exception as e:
            raise IOError(f"Error loading mask file: {e}")
    
    progress.next_stage("Point Generation")
    
    # Generate or load points
    points_pixels = []
    
    if args.f or args.F:
        # Load from file
        filename = args.f if args.f else args.F
        start_idx = 0 if args.f else args.S
        points_norm = load_points_from_file(filename, args.n, start_idx)
        
        # Convert normalized coordinates to pixel coordinates
        for x_norm, y_norm in points_norm:
            x = x_norm * (output_width - 1)
            y = y_norm * (output_height - 1)
            points_pixels.append((x, y))
        
        if progress:
            progress.update("Point Generation", args.n, args.n)
    else:
        # Generate random points
        if kind == 'uniform':
            points_pixels = generate_uniform_points(
                args.n, args.i, (output_width, output_height), 
                shape, constrain_mask, progress, args.debug
            )
        else:  # gaussian
            points_pixels = generate_gaussian_points(
                args.n, args.g, (output_width, output_height),
                constrain, constrain_mask, progress, args.debug
            )
    
    debug_print(args.debug, f"Generated {len(points_pixels)} points")
    
    progress.next_stage("Spline/Bezier Conversion")
    
    # Handle special case: single point
    if len(points_pixels) == 1:
        print("Warning: Only one point generated. Drawing filled circle.", file=sys.stderr)
        # For SVG, we'll handle differently
        beziers = None
    elif len(points_pixels) == 2 and drawtype == 'spline':
        print("Warning: Only two points for spline. Using line fallback.", file=sys.stderr)
        drawtype = 'line'
        beziers = None
    else:
        # Convert to Beziers if using spline
        beziers = None
        if drawtype == 'spline':
            beziers = kochanek_bartels_to_beziers(
                points_pixels, args.T, args.C, args.B,
                parallel=True, cpu_percent=args.cpu,
                progress=progress, debug=args.debug
            )
    
    progress.next_stage("Rendering")
    
    # Create white canvas for image output
    if args.typeoutput in ['image', 'both']:
        canvas = Image.new('L', (output_width, output_height), 255)
        
        # Draw based on type and point count
        if len(points_pixels) == 1:
            # Single point - draw filled circle
            radius = args.l / 2
            canvas = draw_circle_fallback(canvas, points_pixels[0], radius, args.l)
        elif drawtype == 'line':
            canvas = draw_polygon_aggdraw(canvas, points_pixels, args.l, args.debug)
        else:  # spline
            canvas = draw_spline_beziers(canvas, beziers, args.l, progress, args.debug)
        
        # Save intermediate image if requested (either old or new flag)
        if args.save or args.save_connected:
            base = os.path.splitext(args.outfile)[0]
            intermediate_file = f"{base}_connected.png"
            canvas.save(intermediate_file)
            debug_print(args.debug, f"Saved intermediate image: {intermediate_file}")
        
        progress.next_stage("Gaussian Blur")
        
        # Apply Gaussian blur
        if args.b > 0.5:  # Only blur if meaningful
            canvas = canvas.filter(ImageFilter.GaussianBlur(radius=args.b))
        
        # Validate blob size (only if not in SVG-only mode)
        if args.typeoutput in ['image', 'both']:
            validate_blob_size(canvas, min_dark_pixels=100, debug=args.debug)
        
        progress.next_stage("Thresholding")
        
        # Threshold (keep pixels darker than threshold%)
        threshold_value = (100 - args.t) * 255 / 100
        canvas = canvas.point(lambda x: 0 if x < threshold_value else 255)
    
    progress.next_stage("Saving Output")
    
    # Generate SVG if requested
    if args.typeoutput in ['svg', 'both']:
        # Determine output filename for SVG
        if args.typeoutput == 'both':
            svg_file = os.path.splitext(args.outfile)[0] + '.svg'
        else:
            svg_file = args.outfile
        
        # Generate path data
        if len(points_pixels) == 1:
            # For single point, draw a filled circle
            radius = args.l / 2
            center = points_pixels[0]
            path_data = f"M {center[0]-radius},{center[1]} "
            path_data += f"A {radius},{radius} 0 1,1 {center[0]+radius},{center[1]} "
            path_data += f"A {radius},{radius} 0 1,1 {center[0]-radius},{center[1]} Z"
        else:
            path_data = generate_svg_path_data(points_pixels, beziers, drawtype)
        
        # Save as filled blob (no stroke)
        save_svg(path_data, svg_file, output_width, output_height, args.l)
        
        debug_print(args.debug, f"Saved SVG blob: {svg_file}")
    
    # Save image if requested
    if args.typeoutput in ['image', 'both']:
        if args.typeoutput == 'both':
            image_file = os.path.splitext(args.outfile)[0] + '.png'
        else:
            image_file = args.outfile
        
        canvas.save(image_file)
        debug_print(args.debug, f"Saved image: {image_file}")
    
    progress.next_stage("Complete")
    progress.finish()
    
    print(f"\nSuccessfully generated blob with {len(points_pixels)} points", file=sys.stderr)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted by user", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)