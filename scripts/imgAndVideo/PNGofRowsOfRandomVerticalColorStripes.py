#!/usr/bin/env python3
"""
DESCRIPTION
Generates PNG images composed of rows of random vertical color stripes using colors from a palette file (.hexplt).
Can process a single palette, a random palette, or all palettes in the current directory.
All rendering is done in-memory with NumPy and PIL for efficiency.

DEPENDENCIES
- Python 3.7+
- Pillow (PIL)
- NumPy

Install dependencies with:
    pip install pillow numpy

USAGE
Run with these parameters, all of them optional:
    [-h|--help] - Print usage help and exit.
    [-s|--source-palette] PALETTE - Palette filename (.hexplt). If "ALL", process all .hexplt files in current directory.
                                     If omitted, choose random palette from EB_PALETTES_ROOT_DIR.
    [-m|--min-stripes] MIN - Minimum number of vertical stripes per row (default: 3).
    [-n|--max-stripes] MAX - Maximum number of vertical stripes per row (default: 22).
    [-r|--rows] ROWS - Number of rows in main batch (default: 26).
    [-x|--width] WIDTH - Image width in pixels (default: 1920).
    [-y|--height] HEIGHT - Image height in pixels (default: 1080).
    [-o|--variant-min-stripes] VAR_MIN - Minimum stripes per row for variant batch.
    [-p|--variant-max-stripes] VAR_MAX - Maximum stripes per row for variant batch.
    [-v|--variant-rows] VAR_ROWS - Number of rows in variant batch.
    [-d|--palettes-dir] DIR - Override EB_PALETTES_ROOT_DIR with this path.
    [-S|--seed] SEED - Random seed (integer). If omitted, generate random seed and report it.
    [--random-variant-interleave] - Randomly interleave variant rows with main rows.

ENVIRONMENT VARIABLES
    EB_PALETTES_ROOT_DIR - Path to directory containing .hexplt palette files.
                           Required unless --palettes-dir is provided.

EXAMPLES
    # Generate image with random palette and default settings
    python PNGofRowsOfRandomVerticalColorStripes.py

    # Generate image using specific palette
    python PNGofRowsOfRandomVerticalColorStripes.py -s The_Mystic.hexplt

    # Custom stripe counts and dimensions
    python PNGofRowsOfRandomVerticalColorStripes.py -s The_Mystic.hexplt -m 4 -n 12 -r 20 -x 640 -y 480

    # Add variant batch (after main rows)
    python PNGofRowsOfRandomVerticalColorStripes.py -s The_Mystic.hexplt -v 10 -o 8 -p 16

    # Interleave variant rows randomly
    python PNGofRowsOfRandomVerticalColorStripes.py -s The_Mystic.hexplt -v 10 --random-variant-interleave

    # Use specific seed for reproducibility
    python PNGofRowsOfRandomVerticalColorStripes.py -s The_Mystic.hexplt -S 12345

OUTPUT
    Filename format: {timestamp}_{palette_name}_r{rows}_{min}_{max}_w{width}_h{height}_s{seed}_RORVCS.png
"""

import os
import sys
import re
import random
import secrets
import argparse
from pathlib import Path
from datetime import datetime

import numpy as np
from PIL import Image


# ============================================================================
# Palette Loading
# ============================================================================

def load_palette(palette_path: str) -> list[tuple[int, int, int]]:
    """
    Parse .hexplt file into list of RGB tuples.
    
    Args:
        palette_path: Path to .hexplt file
        
    Returns:
        List of (R, G, B) tuples where each component is 0-255
        
    Raises:
        FileNotFoundError: If palette file doesn't exist
        ValueError: If no valid hex colors found in file
    """
    hex_pattern = re.compile(r'#[a-fA-F0-9]{6}')
    colors = []
    
    with open(palette_path, 'r') as f:
        for line in f:
            match = hex_pattern.search(line)
            if match:
                hex_color = match.group(0).lstrip('#')
                r = int(hex_color[0:2], 16)
                g = int(hex_color[2:4], 16)
                b = int(hex_color[4:6], 16)
                colors.append((r, g, b))
    
    if not colors:
        raise ValueError(f"No valid hex color codes found in {palette_path}")
    
    return colors


def get_palette_files(palette_spec: str, palettes_dir: str, current_dir: str) -> list[Path]:
    """
    Get list of palette file paths based on specification.
    
    Args:
        palette_spec: None (random), "ALL", or specific filename
        palettes_dir: Directory to search for palettes (EB_PALETTES_ROOT_DIR)
        current_dir: Current working directory
        
    Returns:
        List of Path objects to palette files
        
    Raises:
        FileNotFoundError: If no palettes found or specific palette not found
    """
    if palette_spec == "ALL":
        # Get all .hexplt files in current directory
        palettes = list(Path(current_dir).glob("*.hexplt"))
        if not palettes:
            raise FileNotFoundError(f"No .hexplt files found in current directory: {current_dir}")
        return palettes
    
    elif palette_spec is None:
        # Choose random palette from EB_PALETTES_ROOT_DIR
        palettes_dir_path = Path(palettes_dir)
        if not palettes_dir_path.exists():
            raise FileNotFoundError(f"Palettes directory does not exist: {palettes_dir}")
        
        palettes = list(palettes_dir_path.glob("*.hexplt"))
        if not palettes:
            raise FileNotFoundError(f"No .hexplt files found in {palettes_dir}")
        
        # Return single random palette
        return [random.choice(palettes)]
    
    else:
        # Specific palette - search in palettes_dir and current directory
        palette_path = Path(palettes_dir) / palette_spec
        if palette_path.exists():
            return [palette_path]
        
        palette_path = Path(current_dir) / palette_spec
        if palette_path.exists():
            return [palette_path]
        
        raise FileNotFoundError(f"Palette not found: {palette_spec}")


# ============================================================================
# Stripe Generation
# ============================================================================

def generate_row_stripes(width: int, min_stripes: int, max_stripes: int, 
                         palette: list) -> tuple[list[int], list[tuple]]:
    """
    Generate random stripe widths and colors for a single row.
    
    Args:
        width: Total width in pixels
        min_stripes: Minimum number of stripes
        max_stripes: Maximum number of stripes
        palette: List of RGB color tuples
        
    Returns:
        (stripe_widths, stripe_colors) where:
        - stripe_widths: list of pixel widths summing to width
        - stripe_colors: list of RGB tuples for each stripe
    """
    num_stripes = random.randint(min_stripes, max_stripes)
    
    # Generate random widths
    # Start with random split points, then convert to widths
    split_points = sorted(random.randint(1, width - 1) for _ in range(num_stripes - 1))
    split_points = [0] + split_points + [width]
    widths = [split_points[i+1] - split_points[i] for i in range(len(split_points) - 1)]
    
    # Assign random colors from palette
    colors = [random.choice(palette) for _ in range(num_stripes)]
    
    return widths, colors


def render_row_to_array(width: int, height: int, stripe_widths: list, 
                        stripe_colors: list) -> np.ndarray:
    """
    Render a single row as a NumPy array.
    
    Args:
        width: Row width in pixels
        height: Row height in pixels
        stripe_widths: List of stripe pixel widths
        stripe_colors: List of RGB tuples for each stripe
        
    Returns:
        NumPy array of shape (height, width, 3) with dtype uint8
    """
    row_array = np.zeros((height, width, 3), dtype=np.uint8)
    x_offset = 0
    
    for stripe_width, color in zip(stripe_widths, stripe_colors):
        row_array[:, x_offset:x_offset + stripe_width, :] = color
        x_offset += stripe_width
    
    return row_array


def validate_stripe_constraints(width: int, min_stripes: int) -> None:
    """
    Validate that stripe constraints allow minimum 2px per stripe.
    
    Args:
        width: Image width in pixels
        min_stripes: Minimum number of stripes per row
        
    Raises:
        ValueError: If minimum stripe width would be < 2px
    """
    min_stripe_width = width / min_stripes
    if min_stripe_width < 2:
        raise ValueError(
            f"Image width ({width}px) too small for minimum {min_stripes} stripes. "
            f"Minimum stripe width would be {min_stripe_width:.1f}px (<2px). "
            f"Reduce --min-stripes or increase --width."
        )


# ============================================================================
# Main Image Generation
# ============================================================================

def generate_image(width: int, height: int, palette: list,
                   min_stripes: int, max_stripes: int, rows: int,
                   variant_rows: int = 0, variant_min: int = None, 
                   variant_max: int = None, interleave: bool = False) -> Image.Image:
    """
    Generate complete image with rows of vertical stripes.
    
    Args:
        width: Image width in pixels
        height: Image height in pixels
        palette: List of RGB color tuples
        min_stripes: Minimum stripes per row (main batch)
        max_stripes: Maximum stripes per row (main batch)
        rows: Number of main rows
        variant_rows: Number of variant rows (0 = none)
        variant_min: Minimum stripes for variant batch (None = use min_stripes)
        variant_max: Maximum stripes for variant batch (None = use max_stripes)
        interleave: If True, randomly shuffle all rows together
        
    Returns:
        PIL Image object
    """
    # Calculate row heights
    total_rows = rows + variant_rows
    base_row_height = height // total_rows
    remainder_pixels = height % total_rows
    
    # Prepare row configurations
    all_rows = []
    
    # Main rows
    for _ in range(rows):
        stripe_count = random.randint(min_stripes, max_stripes)
        widths, colors = generate_row_stripes(width, stripe_count, stripe_count, palette)
        all_rows.append({'widths': widths, 'colors': colors})
    
    # Variant rows (if any)
    if variant_rows > 0:
        v_min = variant_min if variant_min is not None else min_stripes
        v_max = variant_max if variant_max is not None else max_stripes
        
        for _ in range(variant_rows):
            stripe_count = random.randint(v_min, v_max)
            widths, colors = generate_row_stripes(width, stripe_count, stripe_count, palette)
            all_rows.append({'widths': widths, 'colors': colors})
    
    # Optional interleaving
    if interleave:
        random.shuffle(all_rows)
    
    # Build image array
    image_array = np.zeros((height, width, 3), dtype=np.uint8)
    y_offset = 0
    
    for i, row_config in enumerate(all_rows):
        current_row_height = base_row_height + (1 if i < remainder_pixels else 0)
        row_array = render_row_to_array(
            width, current_row_height, 
            row_config['widths'], 
            row_config['colors']
        )
        image_array[y_offset:y_offset + current_row_height, :, :] = row_array
        y_offset += current_row_height
    
    return Image.fromarray(image_array, 'RGB')


# ============================================================================
# Main Entry Point
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Generate PNG images of rows of random vertical color stripes",
        add_help=False
    )
    
    # Help
    parser.add_argument('-h', '--help', action='help', help="Show this help message and exit")
    
    # Palette selection
    parser.add_argument('-s', '--source-palette', dest='palette_spec', default=None,
                        help='Palette filename, or "ALL" for all .hexplt in current directory')
    parser.add_argument('-d', '--palettes-dir', dest='palettes_dir', default=None,
                        help='Override EB_PALETTES_ROOT_DIR with this path')
    
    # Dimensions and counts
    parser.add_argument('-m', '--min-stripes', dest='min_stripes', type=int, default=3,
                        help='Minimum stripes per row (default: 3)')
    parser.add_argument('-n', '--max-stripes', dest='max_stripes', type=int, default=22,
                        help='Maximum stripes per row (default: 22)')
    parser.add_argument('-r', '--rows', dest='rows', type=int, default=26,
                        help='Number of main rows (default: 26)')
    parser.add_argument('-x', '--width', dest='width', type=int, default=1920,
                        help='Image width in pixels (default: 1920)')
    parser.add_argument('-y', '--height', dest='height', type=int, default=1080,
                        help='Image height in pixels (default: 1080)')
    
    # Variant batch
    parser.add_argument('-o', '--variant-min-stripes', dest='variant_min', type=int, default=None,
                        help='Minimum stripes for variant batch')
    parser.add_argument('-p', '--variant-max-stripes', dest='variant_max', type=int, default=None,
                        help='Maximum stripes for variant batch')
    parser.add_argument('-v', '--variant-rows', dest='variant_rows', type=int, default=0,
                        help='Number of variant rows')
    parser.add_argument('--random-variant-interleave', dest='interleave', action='store_true',
                        help='Randomly interleave variant rows with main rows')
    
    # Random seed
    parser.add_argument('-S', '--seed', dest='seed', type=int, default=None,
                        help='Random seed (if omitted, generate random)')
    
    args = parser.parse_args()
    
    # Validate variant parameters
    if (args.variant_min is not None or args.variant_max is not None) and args.variant_rows == 0:
        print("WARNING: --variant-min-stripes/--variant-max-stripes provided without --variant-rows. Ignoring variant parameters.")
        args.variant_min = None
        args.variant_max = None
    
    if args.variant_rows > 0 and args.variant_min is None and args.variant_max is None:
        args.variant_min = args.min_stripes
        args.variant_max = args.max_stripes
    
    # Validate stripe constraints
    validate_stripe_constraints(args.width, args.min_stripes)
    if args.variant_min is not None:
        validate_stripe_constraints(args.width, args.variant_min)
    
    # Set up random seed
    if args.seed is None:
        args.seed = secrets.randbits(32)
    random.seed(args.seed)
    print(f"Using random seed: {args.seed}")
    
    # Get palettes directory
    palettes_dir = args.palettes_dir
    if palettes_dir is None:
        palettes_dir = os.environ.get('EB_PALETTES_ROOT_DIR')
    
    if palettes_dir is None:
        print("ERROR: EB_PALETTES_ROOT_DIR environment variable not set and --palettes-dir not provided.")
        print("Set EB_PALETTES_ROOT_DIR to the directory containing your .hexplt palette files, or use -d/--palettes-dir.")
        sys.exit(1)
    
    palettes_dir = str(Path(palettes_dir).expanduser().resolve())
    current_dir = os.getcwd()
    
    # Get list of palettes to process
    try:
        palette_paths = get_palette_files(args.palette_spec, palettes_dir, current_dir)
    except FileNotFoundError as e:
        print(f"ERROR: {e}")
        sys.exit(1)
    
    # Process each palette
    for palette_path in palette_paths:
        print(f"\nProcessing: {palette_path.name}")
        
        # Load palette
        try:
            palette = load_palette(str(palette_path))
            print(f"  Loaded {len(palette)} colors")
        except (FileNotFoundError, ValueError) as e:
            print(f"  ERROR: {e}")
            continue
        
        # Generate image
        try:
            timestamp = datetime.now().strftime("%Y_%m_%d__%H_%M_%S")
            palette_name = palette_path.stem
            
            # Create output filename
            output_filename = (
                f"{timestamp}_{palette_name}_r{args.rows}_"
                f"{args.min_stripes}_{args.max_stripes}_"
                f"w{args.width}_h{args.height}_s{args.seed}_RORVCS.png"
            )
            
            print(f"  Generating {args.width}x{args.height} image with {args.rows} rows...")
            if args.variant_rows > 0:
                print(f"  + {args.variant_rows} variant rows (min={args.variant_min}, max={args.variant_max})")
            if args.interleave:
                print("  + Random interleaving enabled")
            
            image = generate_image(
                width=args.width,
                height=args.height,
                palette=palette,
                min_stripes=args.min_stripes,
                max_stripes=args.max_stripes,
                rows=args.rows,
                variant_rows=args.variant_rows,
                variant_min=args.variant_min,
                variant_max=args.variant_max,
                interleave=args.interleave
            )
            
            image.save(output_filename, "PNG")
            print(f"  Saved: {output_filename}")
            
        except ValueError as e:
            print(f"  ERROR generating image: {e}")
            continue
    
    print("\nDone.")


if __name__ == "__main__":
    main()