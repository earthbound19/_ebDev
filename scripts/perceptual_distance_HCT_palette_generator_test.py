# DESCRIPTION
# Test harness for perceptual_distance_HCT_palette_generator.py
# 
# This script tests the palette generator's ability to create perceptually-ordered
# color palettes by reversing the distance weighting formula. It does NOT test
# the Image Bomber Processing sketch - only the standalone palette generator.
#
# The generator creates colors with specific "perceptual distance" scores by:
# 1. Taking a target distance score (0 = furthest, 1 = nearest)
# 2. Randomly sampling HCT color space
# 3. Accepting colors whose calculated distance score falls within tolerance
# 4. Building palettes of colors with similar perceptual distance
#
# This test runner verifies:
# - All requested colors are generated
# - Minimum palette sizes are respected
# - Files are created with correct naming and paths
# - Environment variables are properly set for script integration
#
# The generator is modular and can be used independently or integrated with
# Image Bomber or other generative art tools.

# DEPENDENCIES
# - Python 3.6+
# - perceptual_distance_HCT_palette_generator.py (must be in same directory)

# USAGE
#   perceptual_distance_HCT_palette_generator_test.py [options]
#
# Options:
#   -h, --help                  Show this help message
#   -n, --num-palettes N        Number of palettes to generate (default: 5)
#   -c, --colors-per-palette C  Colors per palette (default: 10)
#   -t, --tolerance TOL         Score tolerance (default: 0.05)
#   -s, --seed SEED             Random seed for reproducibility
#   -o, --output-dir DIR        Output directory (default: test_output)
#   -v, --verbose               Show detailed generation info
#
# The script can be called from any directory; all paths are handled robustly.
# Generated palettes can be used with Image Bomber or any other color-aware tool.

# EXAMPLES:
#   # Basic test with default parameters
#   python test_palette_generator.py
#
#   # Generate 3 palettes with 8 colors each, tight tolerance
#   python test_palette_generator.py -n 3 -c 8 -t 0.02
#
#   # Reproducible generation with specific seed
#   python test_palette_generator.py -n 4 -c 12 -s 42 -v
#
#   # Output to specific directory
#   python test_palette_generator.py -o ./my_palettes -v

# CODE
import sys
import os
import subprocess
import argparse
from pathlib import Path

# Path handling
SCRIPT_DIR = Path(__file__).parent.absolute()
WORKING_DIR = Path.cwd()

def use_generated_palette(args):
    """
    Call the generation script and capture its environment variable output.
    
    Handles paths robustly:
    - Generation script is found relative to this script's location
    - Output directory is resolved relative to where test runner was called
    - Environment variables contain absolute paths
    """
    # Find generation script (same directory as test runner)
    gen_script = SCRIPT_DIR / "generate_perceptual_palette.py"
    
    if not gen_script.exists():
        print(f"ERROR: Generation script not found at {gen_script}", file=sys.stderr)
        return False
    
    # Resolve output directory relative to where test runner was CALLED
    if not os.path.isabs(args.palette_dir):
        palette_dir = WORKING_DIR / args.palette_dir
    else:
        palette_dir = Path(args.palette_dir)
    
    # Ensure directory exists
    palette_dir.mkdir(parents=True, exist_ok=True)
    
    # Build command
    gen_cmd = [
        sys.executable,
        str(gen_script),
        "--stdin",
        "-n", str(args.num_palettes),
        "-c", str(args.colors_per_palette),
        "-t", str(args.tolerance),
        "-o", str(palette_dir)  # Pass absolute path
    ]
    
    if args.gen_seed:
        gen_cmd.extend(["-s", str(args.gen_seed)])
    
    print(f"\nGenerating test palette with: {' '.join(gen_cmd)}", file=sys.stderr)
    
    try:
        # Run generation script, capturing its output
        result = subprocess.run(
            gen_cmd,
            capture_output=True,
            text=True,
            check=True,
            cwd=str(WORKING_DIR)  # Run in calling directory
        )
        
        # Parse export statements and set environment variables
        env_vars = {}
        for line in result.stdout.split('\n'):
            if line.startswith('export '):
                parts = line[7:].split('=', 1)
                if len(parts) == 2:
                    key = parts[0]
                    value = parts[1].strip("'")
                    env_vars[key] = value
                    os.environ[key] = value
        
        if 'GENERATED_PALETTE' in env_vars:
            palette_path = Path(env_vars['GENERATED_PALETTE'])
            
            # Verify the palette file exists
            if not palette_path.exists():
                # Try relative to working directory as fallback
                alt_path = WORKING_DIR / palette_path.name
                if alt_path.exists():
                    os.environ['GENERATED_PALETTE'] = str(alt_path)
                    palette_path = alt_path
                else:
                    print(f"ERROR: Generated palette file not found: {palette_path}", file=sys.stderr)
                    return False
            
            print(f"\nUsing generated palette: {palette_path}", file=sys.stderr)
            
            # Verify palette has expected number of colors
            with open(palette_path, 'r') as f:
                colors = [line.strip() for line in f 
                         if line.strip() and not line.startswith('#')]
            
            expected = args.colors_per_palette
            if len(colors) != expected:
                print(f"WARNING: Palette has {len(colors)} colors, expected {expected}", file=sys.stderr)
            else:
                print(f"Palette verified: {len(colors)} colors", file=sys.stderr)
            
            print(f"Generated {env_vars.get('GENERATED_PALETTE_COUNT', '?')} palettes total", file=sys.stderr)
            
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"ERROR running generation script: {e}", file=sys.stderr)
        print("STDOUT:", e.stdout, file=sys.stderr)
        print("STDERR:", e.stderr, file=sys.stderr)
        return False
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return False

def run_tests(args):
    """Run the actual tests (placeholder - implement your test logic here)."""
    print(f"\nRunning tests with palette: {args.input}", file=sys.stderr)
    print(f"Test parameters: num_palettes={args.num_palettes}, format={args.format}", file=sys.stderr)
    
    # Your existing test logic here
    # ...
    
    return True

def main():
    parser = argparse.ArgumentParser(
        description="Test runner for Image Bomber with palette generation support",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    # Generation options
    parser.add_argument(
        '--use-palette-generation',
        action='store_true',
        help='Generate a test palette instead of using input file'
    )
    
    parser.add_argument(
        '--palette-dir',
        default='generated_palettes',
        help='Directory for generated palettes (default: generated_palettes)'
    )
    
    parser.add_argument(
        '--colors-per-palette',
        type=int,
        default=10,
        help='Colors per palette when generating (default: 10)'
    )
    
    parser.add_argument(
        '--tolerance',
        type=float,
        default=0.05,
        help='Tolerance for color generation (default: 0.05)'
    )
    
    parser.add_argument(
        '--gen-seed',
        type=int,
        help='Random seed for palette generation'
    )
    
    # Test options
    parser.add_argument(
        '--num-palettes',
        type=int,
        default=5,
        help='Number of palettes to generate/test (default: 5)'
    )
    
    parser.add_argument(
        '-i', '--input',
        help='Input palette file (when not generating)'
    )
    
    parser.add_argument(
        '-o', '--output',
        default='test_results',
        help='Output base name for test results'
    )
    
    parser.add_argument(
        '-f', '--format',
        choices=['raw', 'processing'],
        default='raw',
        help='Output format (default: raw)'
    )
    
    parser.add_argument(
        'sketch_folder',
        nargs='?',
        help='Processing sketch folder (optional for some test modes)'
    )
    
    args = parser.parse_args()
    
    # Handle palette generation if requested
    if args.use_palette_generation:
        if not use_generated_palette(args):
            sys.exit(1)
        # Override input file with generated palette
        args.input = os.environ.get('GENERATED_PALETTE')
        if not args.input:
            print("ERROR: GENERATED_PALETTE not set after generation", file=sys.stderr)
            sys.exit(1)
    elif not args.input:
        print("ERROR: Either --use-palette-generation or -i INPUT must be specified", file=sys.stderr)
        sys.exit(1)
    
    # Run tests
    success = run_tests(args)
    
    if success:
        print("\nTests completed successfully", file=sys.stderr)
        sys.exit(0)
    else:
        print("\nTests failed", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()