# DESCRIPTION
# Generates perceptually-ordered color palettes by reversing the distance weighting
# formula from the sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py.
#
# Instead of sorting existing colors, this script CREATES new colors that have
# specific perceptual distance scores, using random sampling of HCT space.
#
# THEORY:
# This script implements the reverse of the perceptual distance model:
#
# Forward model (from palette splitter):
#   distance_score = 0.4*H_score + 0.35*C_score + 0.25*T_score
#   where:
#     H_score: 1.0 at 106° (yellow), 0.0 at 107° (furthest), linear in between
#     C_score: chroma/140 (higher = nearer)
#     T_score: complex function of tone and chroma (see code)
#
# Reverse generation:
#   Given a target distance score (0-1), randomly sample HCT space
#   and accept colors whose actual score is within tolerance.
#   This creates colors that share the same perceptual "distance feel"
#   while exploring diverse hues, chromas, and tones.
#
# Each generated palette contains colors with along a perceptual distance,
# creating a gradient from "furthest" (palette 0) to "nearest" (palette N-1).

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
#   --stdin                 Output environment variable assignments for sourcing
#
# ENVIRONMENT VARIABLE CONTRACT (for script integration):
#   When called with --stdin, this script outputs three export statements:
#     export GENERATED_PALETTE='/absolute/path/to/first_palette_file.hexplt'
#     export GENERATED_PALETTE_COUNT=5
#     export GENERATED_PALETTE_COLORS=50
#
#   These can be captured using:
#     source <(python perceptual_distance_HCT_palette_generator.py --stdin [options])
#
#   The test script (perceptual_distance_HCT_palette_generator_test.py) uses this
#   contract to automatically discover and verify generated palettes.
#
# PATH HANDLING:
#   - Output paths are resolved relative to where the script is CALLED from
#   - Environment variables contain ABSOLUTE paths for cross-script communication
#   - The script can be called from any directory; all paths are handled robustly
#
# EXAMPLES:
#   # Generate 5 palettes with 10 colors each
#   python perceptual_distance_HCT_palette_generator.py -n 5 -c 10
#
#   # Generate with specific seed and tolerance
#   python perceptual_distance_HCT_palette_generator.py -n 3 -c 8 -t 0.03 -s 42
#
#   # For integration with test script (sets GENERATED_PALETTE env var)
#   source <(python perceptual_distance_HCT_palette_generator.py --stdin -n 4 -c 12)

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

# Path handling - script knows its own location, but respects calling directory
SCRIPT_DIR = Path(__file__).parent.absolute()
WORKING_DIR = Path.cwd()

# ============================================================================
# Perceptual distance scoring functions (mirroring the palette splitter)
# ============================================================================

def hue_distance_score(hue):
    """
    Calculate nearness score based on explicit ordering.
    
    Experimental theory: Yellow (106°) feels nearest. Perceived distance increases
    as hue moves away in a single direction around the circle:
    106° (NEAREST) → 105° → 104° → ... → 0° → 359° → 358° → ... → 107° (FURTHEST)
    
    Score = 1.0 at hue 106° (nearest)
    Score decreases linearly along the sequence
    Score = 0.0 at hue 107° (furthest)
    """
    # Handle the wrap: treat hues >= 107 as being on the "far side" of the sequence
    if hue >= 107:
        # For hues 107-359, they come after the wrap
        # Position = (106 - 0) + (360 - hue) = 106 + (360 - hue)
        position = 106 + (360 - hue)
    else:
        # For hues 0-106, position is simply (106 - hue)
        position = 106 - hue
    
    # Total length of sequence: from 106 down to 0 (106 steps) + from 359 down to 107 (253 steps)
    # = 106 + 253 = 359 total positions (0-358)
    max_position = 359.0
    
    # Convert to 0-1 score where 1 = nearest (position 0), 0 = furthest (position 359)
    score = 1.0 - (position / max_position)
    
    return score

def chroma_distance_score(chroma):
    """
    Calculate chroma contribution to distance perception.
    
    Experimental theory: Lower chroma (desaturated) = more distant (atmospheric haze)
    Higher chroma (saturated) = nearer (pulls attention forward)
    """
    # HCT chroma maximum is around 145, but can vary
    # Normalize with a soft cap at 140
    max_chroma = 140.0
    chroma_norm = min(chroma / max_chroma, 1.0)
    
    # Simple linear: higher chroma = nearer
    return chroma_norm

def tone_distance_score(tone, chroma):
    """
    Calculate tone contribution to distance perception.
    
    Experimental theory: 
    - For desaturated colors (low chroma): darker = nearer, lighter = more distant (haze)
    - For saturated colors (high chroma): both very dark and very light can feel near
      (high contrast draws attention regardless of lightness)
    """
    tone_norm = tone / 100.0
    
    if chroma > 50:
        # High chroma: both ends feel near
        if tone_norm < 0.3:
            # Very dark: near
            return 0.9
        elif tone_norm > 0.7:
            # Very light: near
            return 0.9
        else:
            # Mid tones: slightly less near
            return 0.7
    else:
        # Low chroma: darker = nearer, lighter = more distant
        return 1.0 - tone_norm

def calculate_unified_distance_score(hct_dict):
    """
    Combine all three HCT channels into a single "nearness" score.
    Higher score = appears nearer, Lower score = appears further.
    
    Weights (experimental, adjustable):
    - Hue: 40% - Based on artistic warm/cool perception
    - Chroma: 35% - Atmospheric haze effect
    - Tone: 25% - Lightness/darkness cues
    """
    h = hct_dict['hue']
    c = hct_dict['chroma']
    t = hct_dict['tone']
    
    # Calculate component scores
    hue_score = hue_distance_score(h)
    chroma_score = chroma_distance_score(c)
    tone_score = tone_distance_score(t, c)
    
    # Weight the components
    weights = {'hue': 0.4, 'chroma': 0.35, 'tone': 0.25}
    
    total_score = (
        weights['hue'] * hue_score +
        weights['chroma'] * chroma_score +
        weights['tone'] * tone_score
    )
    
    return total_score

# ============================================================================
# Color generation functions
# ============================================================================

def random_alphanumeric(length=6):
    """Generate random alphanumeric string for unique filenames."""
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(length))

def generate_colors_at_distance(target_score, n_colors=10, tolerance=0.05, max_attempts=5000):
    """
    Generate n_colors that approximately achieve the target perceptual distance score.
    
    This reverses the weighting formula by randomly sampling HCT space
    and accepting colors that land near the target score.
    
    Args:
        target_score: 0-1 where 0 = furthest, 1 = nearest
        n_colors: How many colors to generate
        tolerance: Accept colors with score within ±tolerance of target
        max_attempts: Maximum attempts per color before giving up
    
    Returns:
        List of hex color strings
    """
    colors = []
    attempts = 0
    max_total_attempts = max_attempts * n_colors
    
    while len(colors) < n_colors and attempts < max_total_attempts:
        attempts += 1
        
        # Randomly sample HCT space with biases toward valid colors
        hue = random.uniform(0, 360)
        # Bias chroma toward lower values (more common in nature)
        chroma = random.uniform(0, 140) ** 0.8  # Sqrt bias toward lower chroma
        chroma = min(chroma, 140)
        # Bias tone toward middle range
        tone = random.uniform(20, 90) + random.uniform(-15, 15)
        tone = max(0, min(100, tone))
        
        try:
            # Create color and fit to sRGB gamut
            c = Color('hct', [hue, chroma, tone])
            c.fit('srgb', method='hct-chroma', jnd=0.02)
            
            # Get fitted HCT values
            fitted = c.convert('hct')
            hct_dict = {
                'hue': fitted['h'],
                'chroma': fitted['c'],
                'tone': fitted['t']
            }
            
            # Calculate its actual distance score
            score = calculate_unified_distance_score(hct_dict)
            
            # Accept if close to target
            if abs(score - target_score) <= tolerance:
                colors.append(c.to_string(hex=True).upper())
                if len(colors) % 5 == 0:
                    print(f"  Found {len(colors)}/{n_colors} colors (score: {score:.3f})", file=sys.stderr)
                
        except Exception:
            # Skip colors that can't be fitted
            continue
    
    if len(colors) < n_colors:
        print(f"  Warning: Only generated {len(colors)}/{n_colors} colors", file=sys.stderr)
    
    return colors

def generate_perceptual_gradient(num_palettes=5, colors_per_palette=10, tolerance=0.05, seed=None):
    """
    Generate a gradient of palettes from furthest to nearest.
    Each palette contains colors with similar perceptual distance.
    
    Returns:
        List of palettes, where each palette is a list of hex color strings,
        and a unique file identifier
    """
    if seed is not None:
        random.seed(seed)
    
    gradient = []
    filename_id = random_alphanumeric(6)
    
    for i in range(num_palettes):
        # Target score from 0 (furthest) to 1 (nearest)
        target = i / (num_palettes - 1) if num_palettes > 1 else 0.5
        
        print(f"\nGenerating palette {i} (target score: {target:.2f})", file=sys.stderr)
        
        palette = generate_colors_at_distance(target, colors_per_palette, tolerance)
        gradient.append(palette)
    
    return gradient, filename_id

def write_palette_files(palettes, output_dir, prefix, filename_id):
    """
    Write palettes to numbered files.
    output_dir can be relative or absolute - resolved against WORKING_DIR.
    
    Returns:
        Absolute path to the first palette file
    """
    # Resolve output directory relative to where script was CALLED from
    if not os.path.isabs(output_dir):
        output_dir = WORKING_DIR / output_dir
    else:
        output_dir = Path(output_dir)
    
    # Create directory if needed
    output_dir.mkdir(parents=True, exist_ok=True)
    
    base_name = f"{prefix}_{filename_id}"
    first_file = None
    
    for i, palette in enumerate(palettes):
        # Create numbered filename: prefix_id_01.hexplt, prefix_id_02.hexplt, etc.
        padded_num = f"{i+1:02d}"
        filename = f"{base_name}_{padded_num}.hexplt"
        filepath = output_dir / filename
        
        if i == 0:
            first_file = str(filepath)  # Store absolute path
        
        # Write in raw format with header
        with open(filepath, 'w') as f:
            if i == 0:
                f.write(f"# Palette {i} - MOST DISTANT (background layers)\n")
            elif i == len(palettes) - 1:
                f.write(f"# Palette {i} - NEAREST (foreground layers)\n")
            else:
                f.write(f"# Palette {i}\n")
            
            for hex_color in palette:
                f.write(f"{hex_color}\n")
        
        print(f"  Wrote {len(palette)} colors to {filepath}", file=sys.stderr)
    
    return first_file

# ============================================================================
# Main entry point
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Generate perceptually-ordered color palettes by reversing distance weighting",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        '-n', '--num-palettes',
        type=int,
        default=5,
        help='Number of output palettes (default: 5)'
    )
    
    parser.add_argument(
        '-c', '--colors-per-palette',
        type=int,
        default=10,
        help='Colors per palette (default: 10)'
    )
    
    parser.add_argument(
        '-o', '--output-dir',
        default='.',
        help='Output directory (default: current directory)'
    )
    
    parser.add_argument(
        '-p', '--prefix',
        default='perceptual_gradient',
        help='Output file prefix (default: perceptual_gradient)'
    )
    
    parser.add_argument(
        '-t', '--tolerance',
        type=float,
        default=0.05,
        help='Score tolerance for acceptance (default: 0.05)'
    )
    
    parser.add_argument(
        '-s', '--seed',
        type=int,
        help='Random seed for reproducibility'
    )
    
    parser.add_argument(
        '--stdin',
        action='store_true',
        help='Output environment variable assignments for sourcing (sets GENERATED_PALETTE, GENERATED_PALETTE_COUNT, GENERATED_PALETTE_COLORS)'
    )
    
    args = parser.parse_args()
    
    # Validate arguments
    if args.num_palettes < 1:
        print("ERROR: num-palettes must be at least 1", file=sys.stderr)
        sys.exit(1)
    
    if args.colors_per_palette < 1:
        print("ERROR: colors-per-palette must be at least 1", file=sys.stderr)
        sys.exit(1)
    
    if args.tolerance <= 0 or args.tolerance > 0.5:
        print("ERROR: tolerance must be between 0 and 0.5", file=sys.stderr)
        sys.exit(1)
    
    # Generate gradient
    try:
        palettes, file_id = generate_perceptual_gradient(
            num_palettes=args.num_palettes,
            colors_per_palette=args.colors_per_palette,
            tolerance=args.tolerance,
            seed=args.seed
        )
    except Exception as e:
        print(f"ERROR during generation: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Write files
    first_file = write_palette_files(palettes, args.output_dir, args.prefix, file_id)
    
    # For script integration: output environment variable assignment
    if args.stdin:
        # Output in format for 'source' command - paths are absolute
        print(f"export GENERATED_PALETTE='{first_file}'")
        print(f"export GENERATED_PALETTE_COUNT={len(palettes)}")
        print(f"export GENERATED_PALETTE_COLORS={sum(len(p) for p in palettes)}")
    else:
        print(f"\nGenerated {len(palettes)} palettes with {args.colors_per_palette} colors each", file=sys.stderr)
        print(f"First palette: {first_file}", file=sys.stderr)

if __name__ == "__main__":
    main()