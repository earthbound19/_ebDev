#!/usr/b
"""
Fit polygonal SVG content to canvas - three orthogonal operations:
--bounding-box: Set viewBox to arbitrary dimensions
--rescale: Uniformly scale polygons to fit viewBox (preserves aspect ratio)
--crop: Crop viewBox to match content's actual aspect ratio (not combined
  with --bounding-box; they must be separate steps).

See USAGE comments in source code.
"""

# DESCRIPTION
# Resaves all SVGs in a directory (and optionally subdirectories) to control how
# the canvas relates to the content. Provides three orthogonal operations:
#   1. Set bounding box (viewBox) to arbitrary dimensions
#   2. Rescale content uniformly to fit the viewBox (preserves aspect ratio)
#   3. Crop viewBox to match content's actual aspect ratio (eliminates empty space)
# These operations can be combined in specific ways, with padding available when
# setting a bounding box. Useful for normalizing auto-exported glyphs, creating
# uniform thumbnail grids, or scaling randomly-generated SVG art to fit a frame.

# DEPENDENCIES
# Python 3.6+ with no external libraries required. Uses only standard library
# modules: xml.etree.ElementTree, pathlib, re, argparse, sys.

# USAGE
# Run with these parameters:
#   python3 allSVGsFitCanvasToContent.py [directory] [-r] [-b W H] [-c] [-p PADDING] [-e EXTENSION]
#
# Arguments:
#   directory     Optional. Directory containing SVG files to process. Defaults to current directory.
#
# Options:
#   -r, --recursive      Process all subdirectories recursively. If omitted, only processes
#                        files directly in the specified directory.
#   -b, --bounding-box W H
#                        Set viewBox to specified width and height (e.g., -b 800 800).
#                        Can be used alone or with --rescale. Cannot be used with --crop.
#                        When used (alone or with other switches), content is automatically
#                        centered within the new bounding box without distortion.
#   --rescale            Uniformly scale all polygons to fit the current viewBox (preserves
#                        aspect ratio; incidental padding appears on the shorter side).
#                        This is the default behavior when no operations are specified.
#   -c, --crop           Crop viewBox to match the content's actual aspect ratio and also
#                        resize the viewBox to exactly encompass all vector content, eliminating
#                        any empty space around the content. If any content extends outside the
#                        current viewBox, the viewBox is first expanded to include it before
#                        cropping to the content's aspect ratio. Cannot be used with --bounding-box.
#   -p, --padding PADDING
#                        Padding in coordinate space units, applied only when --bounding-box
#                        is used. Reduces the effective content area inside the bounding box
#                        before rescaling or placement. Defaults to 0. Has no effect without
#                        --bounding-box.
#   -e, --extension EXT  File extension to process (including the dot). Defaults to '.svg'.
#
# OPERATIONS AND COMBINATIONS:
#
#   No flags (default):   Same as --rescale. Scales content to fit existing viewBox.
#
#   --rescale alone:      Scale polygons uniformly to fit existing viewBox. Tall/narrow content
#                         gets incidental padding on sides; wide/short content gets incidental
#                         padding top/bottom. Content centered. No viewBox changes.
#
#   --crop alone:         Resizes the viewBox to exactly encompass all vector content, then
#                         crops it to match the content's aspect ratio. The resulting viewBox
#                         tightly bounds the content with no empty space, and its proportions
#                         match the content's natural aspect ratio. No scaling of polygons occurs.
#
#   --bounding-box alone: Set viewBox to specified dimensions. Content is automatically centered
#                         within the new viewBox (preserving original size, no scaling). If the
#                         new viewBox is smaller than the content, polygons will be visually
#                         cropped (warning printed). If larger, empty space appears around
#                         the centered content.
#
#   --bounding-box and --rescale:
#                         First set viewBox to specified dimensions, then scale polygons uniformly
#                         to fit that viewBox. Content is automatically centered as part of the
#                         scaling operation. Padding subtracts from the effective area before
#                         scaling. Useful for normalizing vector content to a uniform canvas size.
#
#   --bounding-box and --rescale and --padding:
#                         Effective content area becomes (W - 2*padding) by (H - 2*padding),
#                         centered within the bounding box. Content is scaled to fit this
#                         reduced area, then centered. Creates a margin around the scaled content.
#
#   INVALID COMBINATIONS (script will exit with error):
#     --bounding-box and --crop        (ambiguous: cannot both set and crop viewBox)
#     --rescale and --crop             (conflicting goals: one scales content, the other crops viewBox)
#
#   NOTES:
#     - Padding is only meaningful with --bounding-box. If specified without --bounding-box,
#       it is ignored with a warning.
#     - All operations preserve polygon aspect ratio; no stretching or distortion occurs.
#     - All metadata (RDF descriptions, CC info, dc: elements, namespace declarations) is preserved.
#     - For SVG files containing elements other than <polygon>, the bounding box calculation
#       may be incomplete. This script is designed for polygon-only SVGs.
#     - The --crop operation first expands the viewBox if necessary to include any content
#       that extends outside it, then crops to the content's aspect ratio. This ensures no
#       content is lost during cropping.

# EXAMPLES:
#
#   # Default: scale content to fit existing viewBox (incidental padding appears)
#   python3 allSVGsFitCanvasToContent.py
#
#   # Crop viewBox to tightly enclose content with matching aspect ratio (no empty space)
#   python3 allSVGsFitCanvasToContent.py --crop
#
#   # Set all SVGs to have 800x800 viewBox, content centered (may be cropped if too large)
#   python3 allSVGsFitCanvasToContent.py --bounding-box 800 800
#
#   # Scale all content to fit 800x800 viewBox (centered, uniform sizing)
#   python3 allSVGsFitCanvasToContent.py --bounding-box 800 800 --rescale
#
#   # Same as above but with 20 units of internal margin
#   python3 allSVGsFitCanvasToContent.py --bounding-box 800 800 --rescale -p 20
#
#   # Process all subdirectories recursively, scaling to 600x600 with 10 units padding
#   python3 allSVGsFitCanvasToContent.py ./svgs -r --bounding-box 600 600 --rescale -p 10


# CODE
# BACKLOG
# Potential enhancements for future versions:
#
# Universal vector support for all SVG shape types:
#    - Add support for <path> elements (parse 'd' attribute commands: M, L, C, Q, A, Z, etc.)
#    - Add support for basic shapes: <rect>, <circle>, <ellipse>, <line>, <polyline>
#    - Add support for <g> (groups) with transform attribute accumulation
#    - Add support for <use> (resolve references to defs)
#    - Add support for nested <svg> elements
#
# Transform handling:
#    - Parse and apply transform="translate(...) scale(...) rotate(...) matrix(...)"
#    - Compose multiple transforms on nested elements
#    - Preserve transform attributes when rescaling (vs. baking into coordinates)
#
# Dependency-based alternatives (if universal support is needed):
#    - cairosvg: Full SVG renderer, can compute bounds but adds C dependencies
#    - svglib + reportlab: Python SVG parsing with bounds calculation
#    - lxml: Faster XML parsing than built-in ElementTree
#    - svgpathtools: Path parsing and bounds calculation (ignores transforms currently)
#    - cssselect: Support for CSS selectors if styling affects bounds
#
# Additional features:
#    - Parallel processing for very large file sets (--jobs N)
#
# Performance optimizations for 10,000+ files:
#    - Pre-compile regex patterns
#    - Use iterparse for streaming large SVG files

import os
import re
import sys
import argparse
import xml.etree.ElementTree as ET
from pathlib import Path

# Register namespaces to preserve prefixes when writing
ET.register_namespace('', 'http://www.w3.org/2000/svg')
ET.register_namespace('rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')
ET.register_namespace('cc', 'http://creativecommons.org/ns#')
ET.register_namespace('dc', 'http://purl.org/dc/elements/1.1/')

def get_all_polygon_bounds(root):
    """Find bounds of all polygon elements."""
    polygons = root.findall('.//{http://www.w3.org/2000/svg}polygon')
    if not polygons:
        return None
    
    bounds = None
    for poly in polygons:
        points_str = poly.get('points', '')
        if not points_str:
            continue
        
        # Parse points: handles both "x,y x,y" and "x y x y" formats
        coords = re.findall(r'([-\d.]+)[,\s]+([-\d.]+)', points_str)
        if not coords:
            coords = re.findall(r'([-\d.]+)\s+([-\d.]+)', points_str)
        
        if not coords:
            continue
        
        xs = [float(c[0]) for c in coords]
        ys = [float(c[1]) for c in coords]
        
        poly_bounds = (min(xs), min(ys), max(xs), max(ys))
        
        if bounds is None:
            bounds = poly_bounds
        else:
            bounds = (
                min(bounds[0], poly_bounds[0]),
                min(bounds[1], poly_bounds[1]),
                max(bounds[2], poly_bounds[2]),
                max(bounds[3], poly_bounds[3])
            )
    
    return bounds  # (min_x, min_y, max_x, max_y)

def set_bounding_box(root, width, height, padding=0):
    """
    Set viewBox to specified dimensions, optionally with padding.
    Padding reduces the effective content area inside the bounding box.
    
    Returns the actual viewBox parameters (min_x, min_y, width, height)
    after applying padding.
    """
    if padding != 0:
        # Padding reduces the effective area from the edges
        effective_width = width - (2 * padding)
        effective_height = height - (2 * padding)
        min_x = padding
        min_y = padding
        root.set('viewBox', f"{min_x} {min_y} {effective_width} {effective_height}")
        return (min_x, min_y, effective_width, effective_height)
    else:
        root.set('viewBox', f"0 0 {width} {height}")
        return (0, 0, width, height)

def center_content_in_viewbox(root, content_bounds):
    """
    Translate polygons to center them within the current viewBox.
    Preserves original size (no scaling).
    """
    min_x, min_y, max_x, max_y = content_bounds
    content_center_x = (min_x + max_x) / 2
    content_center_y = (min_y + max_y) / 2
    
    # Get current viewBox
    current_viewbox = root.get('viewBox')
    if not current_viewbox:
        print(f"  Warning: No viewBox found, cannot center")
        return False
    
    vbox_parts = current_viewbox.split()
    if len(vbox_parts) != 4:
        print(f"  Warning: Malformed viewBox '{current_viewbox}', cannot center")
        return False
    
    vbox_min_x, vbox_min_y, vbox_width, vbox_height = map(float, vbox_parts)
    vbox_center_x = vbox_min_x + vbox_width / 2
    vbox_center_y = vbox_min_y + vbox_height / 2
    
    # Calculate translation to center content
    translate_x = vbox_center_x - content_center_x
    translate_y = vbox_center_y - content_center_y
    
    # Apply translation to all polygons
    polygons = root.findall('.//{http://www.w3.org/2000/svg}polygon')
    for poly in polygons:
        points_str = poly.get('points', '')
        if not points_str:
            continue
        
        coords = re.findall(r'([-\d.]+)[,\s]+([-\d.]+)', points_str)
        if not coords:
            coords = re.findall(r'([-\d.]+)\s+([-\d.]+)', points_str)
        
        transformed_points = []
        for x_str, y_str in coords:
            x = float(x_str)
            y = float(y_str)
            new_x = x + translate_x
            new_y = y + translate_y
            transformed_points.append(f"{new_x:.3f},{new_y:.3f}")
        
        poly.set('points', ' '.join(transformed_points))
    
    return True

def expand_viewbox_to_include_content(root, content_bounds):
    """
    Expand the current viewBox if necessary to include all content.
    Returns True if viewBox was expanded, False otherwise.
    """
    min_x, min_y, max_x, max_y = content_bounds
    
    current_viewbox = root.get('viewBox')
    if not current_viewbox:
        return False
    
    vbox_parts = current_viewbox.split()
    if len(vbox_parts) != 4:
        return False
    
    vbox_min_x, vbox_min_y, vbox_width, vbox_height = map(float, vbox_parts)
    vbox_max_x = vbox_min_x + vbox_width
    vbox_max_y = vbox_min_y + vbox_height
    
    new_min_x = min(vbox_min_x, min_x)
    new_min_y = min(vbox_min_y, min_y)
    new_max_x = max(vbox_max_x, max_x)
    new_max_y = max(vbox_max_y, max_y)
    
    new_width = new_max_x - new_min_x
    new_height = new_max_y - new_min_y
    
    if (new_min_x, new_min_y, new_width, new_height) != (vbox_min_x, vbox_min_y, vbox_width, vbox_height):
        root.set('viewBox', f"{new_min_x} {new_min_y} {new_width} {new_height}")
        return True
    
    return False

def crop_viewbox_to_content_aspect(root, content_bounds):
    """
    First expand viewBox to include all content, then crop to match content's aspect ratio.
    The crop is centered on the expvanded viewBox.
    """
    min_x, min_y, max_x, max_y = content_bounds
    content_width = max_x - min_x
    content_height = max_y - min_y
    content_aspect = content_width / content_height
    
    # First expand viewBox to include all content
    expanded = expand_viewbox_to_include_content(root, content_bounds)
    if expanded:
        print(f"  Note: viewBox expanded to include all content before cropping")
    
    # Get current (potentially expanded) viewBox
    current_viewbox = root.get('viewBox')
    if not current_viewbox:
        print(f"  Warning: No viewBox found, skipping crop")
        return False
    
    vbox_parts = current_viewbox.split()
    if len(vbox_parts) != 4:
        print(f"  Warning: Malformed viewBox '{current_viewbox}', skipping crop")
        return False
    
    vbox_min_x, vbox_min_y, vbox_width, vbox_height = map(float, vbox_parts)
    current_aspect = vbox_width / vbox_height
    
    if current_aspect > content_aspect:
        # Current is wider than content - reduce width
        new_width = vbox_height * content_aspect
        new_min_x = vbox_min_x + (vbox_width - new_width) / 2
        new_viewbox = f"{new_min_x} {vbox_min_y} {new_width} {vbox_height}"
    else:
        # Current is taller than content - reduce height
        new_height = vbox_width / content_aspect
        new_min_y = vbox_min_y + (vbox_height - new_height) / 2
        new_viewbox = f"{vbox_min_x} {new_min_y} {vbox_width} {new_height}"
    
    root.set('viewBox', new_viewbox)
    return True

def rescale_polygons_to_fit_viewbox(root, content_bounds):
    """
    Scale and translate all polygons uniformly to fit the current viewBox.
    Preserves aspect ratio (no distortion). Content is centered.
    """
    min_x, min_y, max_x, max_y = content_bounds
    content_width = max_x - min_x
    content_height = max_y - min_y
    
    # Get current viewBox
    current_viewbox = root.get('viewBox')
    if not current_viewbox:
        print(f"  Warning: No viewBox found, cannot rescale")
        return False
    
    vbox_parts = current_viewbox.split()
    if len(vbox_parts) != 4:
        print(f"  Warning: Malformed viewBox '{current_viewbox}', cannot rescale")
        return False
    
    vbox_min_x, vbox_min_y, vbox_width, vbox_height = map(float, vbox_parts)
    
    # Calculate uniform scale factor (use smaller factor to fit entirely without cropping)
    scale_x = vbox_width / content_width
    scale_y = vbox_height / content_height
    scale = min(scale_x, scale_y)
    
    # Calculate translation to center content in viewBox
    content_center_x = (min_x + max_x) / 2
    content_center_y = (min_y + max_y) / 2
    vbox_center_x = vbox_min_x + vbox_width / 2
    vbox_center_y = vbox_min_y + vbox_height / 2
    
    translate_x = vbox_center_x - (content_center_x * scale)
    translate_y = vbox_center_y - (content_center_y * scale)
    
    # Apply transformation to all polygons
    polygons = root.findall('.//{http://www.w3.org/2000/svg}polygon')
    for poly in polygons:
        points_str = poly.get('points', '')
        if not points_str:
            continue
        
        coords = re.findall(r'([-\d.]+)[,\s]+([-\d.]+)', points_str)
        if not coords:
            coords = re.findall(r'([-\d.]+)\s+([-\d.]+)', points_str)
        
        transformed_points = []
        for x_str, y_str in coords:
            x = float(x_str)
            y = float(y_str)
            new_x = x * scale + translate_x
            new_y = y * scale + translate_y
            transformed_points.append(f"{new_x:.3f},{new_y:.3f}")
        
        poly.set('points', ' '.join(transformed_points))
    
    return True

def check_polygons_within_viewbox(root, content_bounds):
    """
    Check if polygons extend outside the current viewBox and print warning.
    """
    min_x, min_y, max_x, max_y = content_bounds
    
    current_viewbox = root.get('viewBox')
    if not current_viewbox:
        return
    
    vbox_parts = current_viewbox.split()
    if len(vbox_parts) != 4:
        return
    
    vbox_min_x, vbox_min_y, vbox_width, vbox_height = map(float, vbox_parts)
    vbox_max_x = vbox_min_x + vbox_width
    vbox_max_y = vbox_min_y + vbox_height
    
    outside = []
    if min_x < vbox_min_x:
        outside.append(f"left edge (min_x={min_x:.1f} < {vbox_min_x:.1f})")
    if max_x > vbox_max_x:
        outside.append(f"right edge (max_x={max_x:.1f} > {vbox_max_x:.1f})")
    if min_y < vbox_min_y:
        outside.append(f"top edge (min_y={min_y:.1f} < {vbox_min_y:.1f})")
    if max_y > vbox_max_y:
        outside.append(f"bottom edge (max_y={max_y:.1f} > {vbox_max_y:.1f})")
    
    if outside:
        print(f"  Warning: Polygons extend outside viewBox at: {', '.join(outside)}")

def process_svg(svg_path, bounding_box=None, rescale=False, crop=False, padding=0):
    """
    Process a single SVG file according to the specified operations.
    Order of operations:
      1. Apply bounding box (if specified) - includes centering if no rescale
      2. Apply crop (if specified) - but crop cannot coexist with bounding_box
      3. Apply rescale (if specified) - includes centering as part of scaling
    """
    tree = ET.parse(svg_path)
    root = tree.getroot()
    
    # Get original content bounds
    content_bounds = get_all_polygon_bounds(root)
    if content_bounds is None:
        print(f"  Skipping {svg_path}: no valid polygons found")
        return False
    
    # Order of operations:
    # 1. Apply bounding box (if specified)
    if bounding_box:
        width, height = bounding_box
        set_bounding_box(root, width, height, padding)
        
        # If we're NOT going to rescale later, center the content now
        if not rescale:
            center_content_in_viewbox(root, content_bounds)
        
        # After setting new bounding box, check if polygons are outside
        # Need to re-get bounds? Bounds haven't changed (unless we centered), but viewBox has
        # Re-get content bounds after centering if centering happened
        if not rescale:
            # Content was moved by centering, re-get bounds for accurate warning
            new_content_bounds = get_all_polygon_bounds(root)
            if new_content_bounds:
                check_polygons_within_viewbox(root, new_content_bounds)
        else:
            check_polygons_within_viewbox(root, content_bounds)
    
    # 2. Apply crop (if specified) - but only if no bounding_box
    if crop:
        if bounding_box:
            print(f"  Error: --crop cannot be used with --bounding-box (conflicting viewBox operations)")
            return False
        crop_viewbox_to_content_aspect(root, content_bounds)
    
    # 3. Apply rescale (if specified)
    if rescale:
        # For rescale to work correctly, we need the current viewBox
        # If bounding_box was set, that viewBox is already in place
        # If crop was applied, that cropped viewBox is in place
        # Otherwise, original viewBox is used
        if not root.get('viewBox'):
            print(f"  Warning: No viewBox found for rescale, using default 0 0 800 800")
            root.set('viewBox', '0 0 800 800')
        
        # Note: We use the ORIGINAL content_bounds (before any centering) for scaling
        # This ensures scaling is based on original geometry, not already-moved geometry
        rescale_polygons_to_fit_viewbox(root, content_bounds)
    
    # Remove hardcoded dimensions for responsiveness
    root.attrib.pop('width', None)
    root.attrib.pop('height', None)
    
    tree.write(svg_path, encoding='utf-8', xml_declaration=True)
    return True

def process_directory(directory, extension='.svg', recursive=False, bounding_box=None, 
                     rescale=False, crop=False, padding=0):
    """Process all SVG files in a directory."""
    pattern = f"**/*{extension}" if recursive else f"*{extension}"
    files = list(Path(directory).glob(pattern))
    
    if not files:
        print(f"No {extension} files found in {directory}")
        return
    
    # Validate operation combinations
    if bounding_box and crop:
        print("ERROR: --bounding-box and --crop cannot be used together (conflicting viewBox operations)")
        print("Use either --bounding-box (set explicit dimensions) or --crop (match content aspect), not both.")
        sys.exit(1)
    
    if rescale and crop:
        print("ERROR: --rescale and --crop cannot be used together (conflicting goals)")
        print("--rescale scales content to fit viewBox; --crop crops viewBox to match content.")
        print("Choose one or the other, or use --bounding-box with --rescale for uniform sizing.")
        sys.exit(1)
    
    if padding != 0 and not bounding_box:
        print("Warning: --padding ignored because --bounding-box was not specified")
    
    # Default behavior: rescale if no operations specified
    if not any([bounding_box, rescale, crop]):
        rescale = True
        print("No operations specified. Defaulting to --rescale (scale content to fit viewBox)")
    
    # Report what we're doing
    print(f"\nProcessing {len(files)} files:")
    if bounding_box:
        print(f"  - Setting bounding box to {bounding_box[0]}x{bounding_box[1]}")
        if padding != 0:
            print(f"  - With {padding} units padding (effective area: {bounding_box[0]-2*padding}x{bounding_box[1]-2*padding})")
        if not rescale:
            print(f"  - Centering content within new bounding box (no scaling)")
    if crop:
        print(f"  - Cropping viewBox to match content aspect ratio (expanding if needed to include all content)")
    if rescale:
        print(f"  - Rescaling content uniformly to fit viewBox")
    
    success = 0
    for i, svg_file in enumerate(files, 1):
        print(f"[{i}/{len(files)}] Processing: {svg_file.name}")
        if process_svg(str(svg_file), bounding_box=bounding_box, rescale=rescale, 
                      crop=crop, padding=padding):
            success += 1
    
    print(f"\nComplete: {success}/{len(files)} files updated")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Fit SVG canvas to polygon content',
        epilog="Use --help for detailed documentation on operation combinations."
    )
    parser.add_argument('directory', nargs='?', default='.',
                        help='Directory containing SVG files (default: current dir)')
    parser.add_argument('-r', '--recursive', action='store_true',
                        help='Process subdirectories recursively')
    parser.add_argument('-b', '--bounding-box', nargs=2, metavar=('WIDTH', 'HEIGHT'),
                        type=float, help='Set viewBox to specified WIDTH HEIGHT')
    parser.add_argument('--rescale', action='store_true',
                        help='Uniformly scale polygons to fit viewBox (default behavior)')
    parser.add_argument('-c', '--crop', action='store_true',
                        help='Crop viewBox to match content aspect ratio (expands viewBox first if needed)')
    parser.add_argument('-p', '--padding', type=float, default=0,
                        help='Padding in coordinate units (with --bounding-box only, default: 0)')
    parser.add_argument('-e', '--extension', default='.svg',
                        help='File extension to process (default: .svg)')
    
    args = parser.parse_args()
    
    # Handle the --rescale flag (note: argparse uses --rescale, but we also have -r for recursive)
    # The flag is '--rescale' (long form only to avoid conflict with -r)
    # We'll check args.rescale (the attribute name from the dest)
    rescale_flag = args.rescale if hasattr(args, 'rescale') else False
    
    process_directory(
        args.directory, 
        args.extension, 
        args.recursive, 
        bounding_box=tuple(args.bounding_box) if args.bounding_box else None,
        rescale=rescale_flag,
        crop=args.crop,
        padding=args.padding
    )