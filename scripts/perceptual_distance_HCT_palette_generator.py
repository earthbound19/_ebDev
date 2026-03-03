# DESCRIPTION
# Generates perceptually-ordered color palettes by reversing the distance weighting
# formula from the sRGBpalette2palettesByPerceivedDistance script.
#
# Instead of sorting existing colors, this script CREATES new colors that have
# specific perceptual distance scores, using random sampling of HCT space.

# DEPENDENCIES
# - coloraide (pip install coloraide)
# - Python 3.6+

# USAGE
#   perceptual_distance_HCT_palette_generator.py [options]
#
# Options:
#   -h, --help              Show this help message
#   -n, --num-palettes N    Number of output palettes (default: 5)
#   -c, --colors-per-palette C   Colors per palette (default: 10)
#   -o, --output-dir DIR    Output directory (default: current directory)
#   -p, --prefix PREFIX     Output file prefix (default: perceptual_gradient)
#   -t, --tolerance TOL     Score tolerance for acceptance (default: 0.05)
#   -s, --seed SEED         Random seed for reproducibility
#   -f, --format FORMAT     Output format: 'hct' or 'raw' (default: raw)
#                           hct = color(hct [h, c, t]) notation
#                           raw = #RRGGBB hex codes
#   --stdin                 Output environment variable assignments for sourcing
#
# EXAMPLES:
#   # Generate 5 palettes with 10 colors each in raw hex
#   python perceptual_distance_HCT_palette_generator.py -n 5 -c 10
#
#   # Generate with HCT notation for Processing
#   python perceptual_distance_HCT_palette_generator.py -n 3 -c 8 -f hct
#
#   # Generate with specific seed and tolerance
#   python perceptual_distance_HCT_palette_generator.py -n 3 -c 8 -t 0.03 -s 42 -f raw

# POSSIBLE IMPROVEMENTS
# - allow different tolerances per palette (wider for extremes)
# - or implement directed search instead of pure random
# - or ensure minimum colors per palette like the splitter does (this tends to
#   produce empty palettes toward the end)

# CODE
import sys
import argparse
import os
import random
import string
from pathlib import Path
from coloraide import Color
from coloraide.spaces.hct import HCT

# Register HCT color space
Color.register(HCT())

# Path handling
WORKING_DIR = Path.cwd()

def hue_distance_score(hue):
    if hue >= 107:
        position = 106 + (360 - hue)
    else:
        position = 106 - hue
    return 1.0 - (position / 359.0)

def chroma_distance_score(chroma):
    return min(chroma / 140.0, 1.0)

def tone_distance_score(tone, chroma):
    tone_norm = tone / 100.0
    if chroma > 50:
        if tone_norm < 0.3 or tone_norm > 0.7:
            return 0.9
        else:
            return 0.7
    else:
        return 1.0 - tone_norm

def calculate_unified_distance_score(hct_dict):
    weights = {'hue': 0.4, 'chroma': 0.35, 'tone': 0.25}
    return (weights['hue'] * hue_distance_score(hct_dict['hue']) +
            weights['chroma'] * chroma_distance_score(hct_dict['chroma']) +
            weights['tone'] * tone_distance_score(hct_dict['tone'], hct_dict['chroma']))

def random_alphanumeric(length=6):
    return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(length))

def format_color(color, output_format='raw'):
    """Format color according to specified format."""
    if output_format == 'hct':
        # Convert to HCT and output as color(hct [h, c, t])
        hct = color.convert('hct')
        return f"color(hct [{hct['h']:.1f}, {hct['c']:.1f}, {hct['t']:.1f}])"
    else:  # raw hex
        return color.to_string(hex=True).upper()

def generate_colors_at_distance(target_score, n_colors=10, tolerance=0.05, max_attempts=5000, output_format='raw'):
    colors = []
    attempts = 0
    max_total = max_attempts * n_colors
    
    while len(colors) < n_colors and attempts < max_total:
        attempts += 1
        hue = random.uniform(0, 360)
        chroma = min(random.uniform(0, 140) ** 0.8, 140)
        tone = max(0, min(100, random.uniform(20, 90) + random.uniform(-15, 15)))
        
        try:
            c = Color('hct', [hue, chroma, tone])
            c.fit('srgb', method='hct-chroma', jnd=0.02)
            
            # Calculate score to check against target
            fitted = c.convert('hct')
            score = calculate_unified_distance_score({
                'hue': fitted['h'],
                'chroma': fitted['c'],
                'tone': fitted['t']
            })
            
            if abs(score - target_score) <= tolerance:
                if output_format == 'raw':
                    # Convert to sRGB hex
                    srgb = c.convert('srgb')
                    r = int(max(0, min(255, srgb['r'] * 255)))
                    g = int(max(0, min(255, srgb['g'] * 255)))
                    b = int(max(0, min(255, srgb['b'] * 255)))
                    colors.append(f"#{r:02X}{g:02X}{b:02X}")
                else:  # hct
                    hct = c.convert('hct')
                    colors.append(f"color(hct [{hct['h']:.1f}, {hct['c']:.1f}, {hct['t']:.1f}])")
                
                if len(colors) % 5 == 0:
                    print(f"  Found {len(colors)}/{n_colors} colors (score: {score:.3f})", file=sys.stderr)
        except:
            continue
    
    if len(colors) < n_colors:
        print(f"  Warning: Only generated {len(colors)}/{n_colors} colors", file=sys.stderr)
    
    return colors

def generate_perceptual_gradient(num_palettes=5, colors_per_palette=10, tolerance=0.05, seed=None, output_format='raw'):
    if seed:
        random.seed(seed)
    gradient = []
    file_id = random_alphanumeric(6)
    
    for i in range(num_palettes):
        target = i / (num_palettes - 1) if num_palettes > 1 else 0.5
        print(f"\nGenerating palette {i} (target: {target:.2f})", file=sys.stderr)
        gradient.append(generate_colors_at_distance(target, colors_per_palette, tolerance, output_format=output_format))
    
    return gradient, file_id

def write_palette_files(palettes, output_dir, prefix, file_id, output_format):
    out = Path(output_dir) if os.path.isabs(output_dir) else WORKING_DIR / output_dir
    out.mkdir(parents=True, exist_ok=True)
    base = f"{prefix}_{file_id}"
    first = None
    
    format_desc = "HCT notation" if output_format == 'hct' else "raw hex"
    
    for i, p in enumerate(palettes):
        path = out / f"{base}_{i+1:02d}.hexplt"
        if i == 0:
            first = str(path)
        with open(path, 'w') as f:
            f.write(f"# Palette {i}" + (" - MOST DISTANT" if i == 0 else " - NEAREST" if i == len(palettes)-1 else "") + f" ({format_desc})\n")
            for color_str in p:
                f.write(f"{color_str}\n")
        print(f"  Wrote {len(p)} colors to {path}", file=sys.stderr)
    
    return first

def main():
    parser = argparse.ArgumentParser(
        description="Generate perceptually-ordered color palettes by reversing distance weighting"
    )
    
    parser.add_argument('-n', '--num-palettes', type=int, default=5,
                       help='Number of output palettes (default: 5)')
    parser.add_argument('-c', '--colors-per-palette', type=int, default=10,
                       help='Colors per palette (default: 10)')
    parser.add_argument('-o', '--output-dir', default='.',
                       help='Output directory (default: current directory)')
    parser.add_argument('-p', '--prefix', default='perceptual_gradient',
                       help='Output file prefix (default: perceptual_gradient)')
    parser.add_argument('-t', '--tolerance', type=float, default=0.05,
                       help='Score tolerance for acceptance (default: 0.05)')
    parser.add_argument('-s', '--seed', type=int,
                       help='Random seed for reproducibility')
    parser.add_argument('-f', '--format', choices=['raw', 'hct'], default='raw',
                       help='Output format: raw (#RRGGBB) or hct (color(hct [h,c,t]) notation)')
    parser.add_argument('--stdin', action='store_true',
                       help='Output environment variable assignments for sourcing')
    
    args = parser.parse_args()
    
    if args.num_palettes < 1:
        print("ERROR: num-palettes must be at least 1", file=sys.stderr)
        sys.exit(1)
    
    if args.colors_per_palette < 1:
        print("ERROR: colors-per-palette must be at least 1", file=sys.stderr)
        sys.exit(1)
    
    if args.tolerance <= 0 or args.tolerance > 0.5:
        print("ERROR: tolerance must be between 0 and 0.5", file=sys.stderr)
        sys.exit(1)
    
    palettes, file_id = generate_perceptual_gradient(
        args.num_palettes, args.colors_per_palette, args.tolerance, args.seed, args.format)
    
    first = write_palette_files(palettes, args.output_dir, args.prefix, file_id, args.format)
    
    if args.stdin:
        print(f"export GENERATED_PALETTE='{first}'")
        print(f"export GENERATED_PALETTE_COUNT={len(palettes)}")
        print(f"export GENERATED_PALETTE_COLORS={sum(len(p) for p in palettes)}")
    else:
        print(f"\nGenerated {len(palettes)} palettes in {args.format} format", file=sys.stderr)
        print(f"First palette: {first}", file=sys.stderr)

if __name__ == "__main__":
    main()