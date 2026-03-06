# DESCRIPTION
# Takes a list of hex color codes, one per line, and renders a PNG image composed of tiles of those colors (a palette image). Extracts all #RRGGBB color codes from the input file (which may contain other text/comments) and arranges them in a grid. Empty tiles (if the grid has more cells than colors) are filled with a configurable gray color (default #919191).
# WRITTEN BY a large language model with user guidance and modeling after the now legacy script renderHexPalette.sh, which is now deprecated as this is many times faster.

# DEPENDENCIES
# - Python 3.6 or higher
# - Pillow (Python Imaging Library fork). Install with: pip install Pillow
# - Optionally, an environment variable export of EB_PALETTES_ROOT_DIR set in `~/.bashrc` (in your home folder) which contains one line, set with a Unix-style path to the folder where you keep hex palette (`.hexplt`) files (for example /some_path/_ebPalettes/palettes). If this environment variable is set, the script can look for a palette file name in that directory tree and render from it.

# USAGE
# Run this script with the following parameters:
#   palette_file              A palette file in `.hexplt` format, which contains RGB colors expressed as hexadecimal (hex color codes) prefixed with #. If this file is in the directory you run this script from, it will be used. If the file is not in the current directory, it may be anywhere in a directory tree in a path given in the environment variable EB_PALETTES_ROOT_DIR, and the script will find the palette in that directory tree and render from it.
# 
# Optional arguments:
#   -t, --tile-size EDGE_LEN  Edge length of each square tile in final image. (Image width will be this X columns; image height will be this X rows.) Default: 250
#   -s, --shuffle             If provided, the script will randomly shuffle the hex color codes before compositing them to one image.
#   -c, --columns COLS        Number of columns. Overrides any columns specified in the source hexplt file.
#   -r, --rows ROWS           Number of rows. Overrides any rows specified in the source hexplt file.
#   -o, --output OUTPUT_FILE  Output PNG file path. Default: based on input filename with .png extension.
#   --empty-color COLOR_HEX   Color for empty tiles (hex format, e.g. #919191). Default: #919191
#
# EXAMPLE COMMAND; create a palette image from the hex color list RGB_combos_of_255_127_and_0_repetition_allowed.hexplt, where each tile is a square 250px wide, the palette is 5 columns wide and 6 rows down, and tiles in the palette are rendered in random order:
#    python renderHexPalette.py RGB_combos_of_255_127_and_0_repetition_allowed.hexplt -t 250 -s -c 5 -r 6
#
# ANOTHER EXAMPLE COMMAND; create a palette image from tigerDogRabbit_many_shades.hexplt, with each tile 300 pixels wide, no shuffling, the script deciding how many across and down to make the tiles:
#    python renderHexPalette.py tigerDogRabbit_many_shades.hexplt -t 300
#
# ANOTHER EXAMPLE COMMAND; use the same palette and let the script use all defaults, including any number of tiles (columns) across and down specified in the source hexplt:
#    python renderHexPalette.py tigerDogRabbit_many_shades.hexplt

# NOTES
# - This script will work with many kinds of other information present in a .hexplt source file other than RGB hex codes. You can probably have any other arbitrary text, anywhere in the file, including on the same line as RGB hex codes, and it will extract and use only the RGB hex code information. However, no kinds of comments (like # or // at the start of lines) are supported.
# - Source hexplt files may contain syntax to define the desired number of columns and rows to render them with. The syntax is to write the word "columns" followed by a number on any line of the file, and optionally also the word "rows" followed by a number on any line of the file, like this:
#    columns 7 rows 8
# -- or like this:
#    #D29B7D columns 7, rows 8
# All that matters is that the word 'columns' appears followed by a number. You can specify columns only, and this script will figure out the needed number of rows. You can also specify rows (in which case the syntax is the keyword 'rows' followed by a number), and the script will use that number of rows, with the same conditions as for the number of tiles (rows) down parameters to this script.
# - I RECOMMEND that you specify the columns and rows as a comment after the first color in the palette, on the same line. This way, the `allRGBhexColorSort`~ scripts may be able to sort colors in palettes (it may not work if the columns and rows are specified on their own line).
# - If in a source hexplt file you specify (for example) "rows 4" but don't specify any columns, the script will interpret rows as the number of columns, and it may cut off tiles (not all color tiles will render). You must specify columns in the source hexplt file if you specify rows.


# CODE
import re
import sys
import math
import argparse
import random
from pathlib import Path
from PIL import Image, ImageDraw
import os

def find_palette_file(palette_name, search_root=None):
    """Find a .hexplt file in current dir or EB_PALETTES_ROOT_DIR"""
    # Try current directory first
    current = Path.cwd() / palette_name
    if current.exists():
        return current
    
    # Try with .hexplt extension if not present
    if not palette_name.endswith('.hexplt'):
        current_hex = Path.cwd() / f"{palette_name}.hexplt"
        if current_hex.exists():
            return current_hex
    
    # Search in EB_PALETTES_ROOT_DIR if set
    if search_root:
        root = Path(search_root)
        if root.exists():
            # Recursive search (limited depth to avoid huge scans)
            for ext in ['', '.hexplt']:
                name = palette_name if not ext else f"{palette_name}{ext}"
                for p in root.rglob(name):
                    return p
    return None

def extract_colors(filepath):
    """Extract all #RRGGBB color codes from file"""
    colors = []
    with open(filepath, 'r') as f:
        content = f.read()
        # Find all # followed by 6 hex digits, case insensitive
        matches = re.findall(r'#([0-9A-Fa-f]{6})', content)
        colors.extend(matches)
    return colors

def extract_layout_params(filepath):
    """Extract columns and rows from file if specified"""
    columns = None
    rows = None
    
    with open(filepath, 'r') as f:
        content = f.read()
        
        # Look for columns specification
        col_match = re.search(r'columns[^\d]*(\d+)', content, re.IGNORECASE)
        if col_match:
            columns = int(col_match.group(1))
        
        # Look for rows specification
        row_match = re.search(r'rows[^\d]*(\d+)(?!\s*:)', content, re.IGNORECASE)
        if row_match:
            rows = int(row_match.group(1))
    
    return columns, rows

def calculate_dimensions(num_colors, columns=None, rows=None):
    """Calculate optimal columns and rows for the palette"""
    if columns and rows:
        # Both specified, use as-is
        pass
    elif columns:
        # Only columns specified, calculate rows needed
        rows = math.ceil(num_colors / columns)
    elif rows:
        # Only rows specified, calculate columns needed
        columns = math.ceil(num_colors / rows)
    else:
        # Auto-calculate for ~2:1 aspect ratio
        if num_colors <= 12:
            columns = num_colors
            rows = 1
        else:
            sqrt_n = math.isqrt(num_colors)
            columns = sqrt_n * 2
            rows = math.ceil(num_colors / columns)
    
    return columns, rows

def render_palette(colors, columns, rows, tile_size, output_path, empty_color="#919191"):
    """Render the color palette as PNG"""
    width = columns * tile_size
    height = rows * tile_size
    
    # Convert empty_color hex to RGB
    empty_color = empty_color.lstrip('#')
    empty_rgb = tuple(int(empty_color[i:i+2], 16) for i in (0, 2, 4))
    
    # Create new image with gray background
    img = Image.new('RGB', (width, height), color=empty_rgb)
    draw = ImageDraw.Draw(img)
    
    # Fill in color tiles
    for i, color_hex in enumerate(colors):
        if i >= columns * rows:
            break
            
        row = i // columns
        col = i % columns
        
        x1 = col * tile_size
        y1 = row * tile_size
        x2 = x1 + tile_size
        y2 = y1 + tile_size
        
        # Convert hex to RGB tuple
        rgb = tuple(int(color_hex[j:j+2], 16) for j in (0, 2, 4))
        
        # Draw rectangle
        draw.rectangle([x1, y1, x2, y2], fill=rgb)
    
    # Optimize PNG
    img.save(output_path, 'PNG', optimize=True)
    return output_path

def main():
    parser = argparse.ArgumentParser(description='Render hex color palette to PNG')
    parser.add_argument('palette_file', help='Path to .hexplt file or palette name')
    parser.add_argument('-t', '--tile-size', type=int, default=250, 
                       help='Tile edge length in pixels (default: 250)')
    parser.add_argument('-s', '--shuffle', action='store_true',
                       help='Shuffle colors before rendering')
    parser.add_argument('-c', '--columns', type=int, 
                       help='Number of columns (overrides file)')
    parser.add_argument('-r', '--rows', type=int,
                       help='Number of rows (overrides file)')
    parser.add_argument('-o', '--output', 
                       help='Output PNG file path (default: based on input name)')
    parser.add_argument('--empty-color', default='#919191',
                       help='Color for empty tiles (default: #919191)')
    
    args = parser.parse_args()
    
    # Find palette file
    eb_root = os.environ.get('EB_PALETTES_ROOT_DIR')
    palette_path = find_palette_file(args.palette_file, eb_root)
    
    if not palette_path:
        print(f"Error: Could not find palette file '{args.palette_file}'")
        sys.exit(1)
    
    print(f"Found palette: {palette_path}")
    
    # Determine output path
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = palette_path.with_suffix('.png')
    
    # Skip if output already exists
    if output_path.exists():
        print(f"Output file {output_path} already exists, skipping.")
        sys.exit(0)
    
    # Extract colors
    colors = extract_colors(palette_path)
    if not colors:
        print("Error: No valid hex colors found in file")
        sys.exit(1)
    
    print(f"Found {len(colors)} colors")
    
    # Extract layout from file
    file_cols, file_rows = extract_layout_params(palette_path)
    
    # Determine columns/rows (CLI args override file)
    columns = args.columns if args.columns is not None else file_cols
    rows = args.rows if args.rows is not None else file_rows
    
    # Calculate final dimensions
    columns, rows = calculate_dimensions(len(colors), columns, rows)
    print(f"Rendering {columns} columns x {rows} rows")
    
    # Shuffle if requested
    if args.shuffle:
        random.shuffle(colors)
        print("Colors shuffled")
    
    # Render
    render_palette(colors, columns, rows, args.tile_size, output_path, args.empty_color)
    
    # Calculate final image dimensions
    final_width = columns * args.tile_size
    final_height = rows * args.tile_size
    print(f"Created {output_path} ({final_width}x{final_height})")

if __name__ == "__main__":
    main()