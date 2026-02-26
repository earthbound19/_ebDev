# DESCRIPTION
# image_adjust_coloraide.py tester script
# Generates random shifts for every channel in each supported color space and applies
# them to switches passed to script in subject, to make many random channel-shifted
# images. Results are descriptive filenames and debug logs.

# Written nearly entirely by a Large Language Model, deepseek, with human guidance in
# features and fixes.

# DEPENDENCIES
# pip install Pillow numpy coloraide, and image_adjust_coloraide.py, which is
# another script that is tested by this script.
#
# Required versions:
# - Pillow>=9.0.0
# - numpy>=1.21.0
# - coloraide>=2.2.0

# USAGE
# python image_adjust_coloraide_test_runner.py --image INPUT_IMAGE [--output-dir DIRECTORY] [--num-tests PER_SPACE]
#                            [--seed RANDOM_SEED] [--cores PERCENT]
#
# Examples:
#   # Basic usage - one random test per color space
#   python image_adjust_coloraide_test_runner.py -i photo.jpg
#
#   # Generate 3 random variations per color space
#   python image_adjust_coloraide_test_runner.py -i petals.jpg -n 3
#
#   # Save to specific directory with reproducible random seed
#   python image_adjust_coloraide_test_runner.py -i photo.jpg -o test_results --seed 42
#
#   # Use 50% of CPU cores
#   python image_adjust_coloraide_test_runner.py -i photo.jpg --cores 0.5

# CODE
import argparse
import sys
import os
import numpy as np
import random
from PIL import Image
from multiprocessing import Pool, cpu_count
import time
import subprocess
import glob
from datetime import datetime

# Get the directory where this test runner script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TARGET_SCRIPT = os.path.join(SCRIPT_DIR, 'image_adjust_coloraide.py')

# Import Coloraide for validation
try:
    from coloraide import Color
    from coloraide.everything import ColorAll
    HAS_COLORAIDE = True
except ImportError:
    HAS_COLORAIDE = False
    print("Error: Coloraide is required but not installed.", file=sys.stderr)
    print("Please install: pip install coloraide", file=sys.stderr)
    sys.exit(1)

# Define color spaces and their channel ranges
COLORSPACES = {
    'hct': {
        'name': 'HCT',
        'channels': [
            {'name': 'hue', 'range': (-180, 180), 'format': '{:+.1f}'},
            {'name': 'chroma', 'range': (-50, 50), 'format': '{:+.1f}'},
            {'name': 'tone', 'range': (-30, 30), 'format': '{:+.1f}'}
        ],
        'cmd_args': ['--hue', '--chroma', '--tone']
    },
    'okhsl': {
        'name': 'OkHSL',
        'channels': [
            {'name': 'hue', 'range': (-180, 180), 'format': '{:+.1f}'},
            {'name': 'sat', 'range': (-0.5, 0.5), 'format': '{:+.2f}'},
            {'name': 'lig', 'range': (-0.3, 0.3), 'format': '{:+.2f}'}
        ],
        'cmd_args': ['--hue', '--sat', '--lig']
    },
    'okhsv': {
        'name': 'OkHSV',
        'channels': [
            {'name': 'hue', 'range': (-180, 180), 'format': '{:+.1f}'},
            {'name': 'sat', 'range': (-0.5, 0.5), 'format': '{:+.2f}'},
            {'name': 'val', 'range': (-0.3, 0.3), 'format': '{:+.2f}'}
        ],
        'cmd_args': ['--hue', '--sat', '--val']
    },
    'oklch': {
        'name': 'Oklch',
        'channels': [
            {'name': 'hue', 'range': (-180, 180), 'format': '{:+.1f}'},
            {'name': 'chroma', 'range': (-0.2, 0.2), 'format': '{:+.3f}'},
            {'name': 'lig', 'range': (-0.3, 0.3), 'format': '{:+.2f}'}
        ],
        'cmd_args': ['--hue', '--chroma', '--lig']
    }
}

def generate_random_shifts(color_space, num_tests=1, seed=None):
    """Generate random shift values for a given color space."""
    if seed is not None:
        random.seed(f"{seed}_{color_space}")
    
    tests = []
    config = COLORSPACES[color_space]
    
    for _ in range(num_tests):
        shifts = {}
        for i, channel in enumerate(config['channels']):
            min_val, max_val = channel['range']
            value = random.uniform(min_val, max_val)
            if '2f' in channel['format']:
                value = round(value, 2)
            elif '1f' in channel['format']:
                value = round(value, 1)
            elif '3f' in channel['format']:
                value = round(value, 3)
            shifts[channel['name']] = value
        
        tests.append(shifts)
    
    return tests

def build_command(source_image, output_file, color_space, shifts, cores):
    """Build the image_adjust_coloraide.py command with appropriate arguments."""
    cmd = ['python', TARGET_SCRIPT, '-i', source_image, '-d', output_file,
           '--colorspace', color_space, '--cores', str(cores)]
    
    config = COLORSPACES[color_space]
    for i, channel in enumerate(config['channels']):
        arg_name = config['cmd_args'][i]
        value = shifts[channel['name']]
        if value != 0:
            cmd.extend([arg_name, str(value)])
    
    return cmd

def format_shift_string(shifts, color_space):
    """Create a readable string of shifts for filename."""
    config = COLORSPACES[color_space]
    parts = []
    for i, channel in enumerate(config['channels']):
        value = shifts[channel['name']]
        if value != 0:
            parts.append(f"{channel['name'][:3].upper()}{channel['format'].format(value)}")
    
    if not parts:
        parts = ["NO-SHIFT"]
    
    return '-'.join(parts)

def format_shift_human(shifts, color_space):
    """Create a human-readable string of shifts for report."""
    config = COLORSPACES[color_space]
    parts = []
    for i, channel in enumerate(config['channels']):
        value = shifts[channel['name']]
        if value != 0:
            sign = "+" if value > 0 else ""
            parts.append(f"{channel['name']}={sign}{value}")
        else:
            parts.append(f"{channel['name']}=0")
    
    return ', '.join(parts)

def run_test(args):
    """Run a single test (for parallel processing) and save debug output."""
    source_image, output_dir, color_space, shifts, test_id, cores = args
    
    shift_str = format_shift_string(shifts, color_space)
    filename = f"{color_space}_{test_id:03d}_{shift_str}.png"
    output_file = os.path.join(output_dir, filename)
    
    # Create a debug log file for this test
    debug_file = os.path.join(output_dir, f"{color_space}_{test_id:03d}_debug.txt")
    
    cmd = build_command(source_image, output_file, color_space, shifts, cores)
    
    try:
        # Run the command and capture all output
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        # Write debug information to file
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write("=" * 60 + "\n")
            f.write(f"TEST DEBUG LOG - {color_space} test {test_id:03d}\n")
            f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("=" * 60 + "\n\n")
            
            f.write("COMMAND:\n")
            f.write(' '.join(cmd) + "\n\n")
            
            f.write("SHIFT VALUES:\n")
            for k, v in shifts.items():
                f.write(f"  {k}: {v}\n")
            f.write("\n")
            
            f.write("RETURN CODE:\n")
            f.write(f"{result.returncode}\n\n")
            
            f.write("STDOUT:\n")
            f.write(result.stdout if result.stdout else "(no stdout)\n")
            f.write("\n")
            
            f.write("STDERR:\n")
            f.write(result.stderr if result.stderr else "(no stderr)\n")
            f.write("\n")
        
        if result.returncode == 0:
            return {
                'success': True,
                'color_space': color_space,
                'output_file': output_file,
                'test_id': test_id,
                'shifts': shifts,
                'shift_str': shift_str,
                'debug_file': debug_file
            }
        else:
            error_msg = result.stderr[:200] if result.stderr else "Unknown error"
            return {
                'success': False,
                'color_space': color_space,
                'test_id': test_id,
                'shifts': shifts,
                'error': error_msg,
                'debug_file': debug_file
            }
    except Exception as e:
        # If there's an exception, still try to write debug info
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write("=" * 60 + "\n")
            f.write(f"TEST DEBUG LOG - {color_space} test {test_id:03d} (EXCEPTION)\n")
            f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("=" * 60 + "\n\n")
            f.write(f"EXCEPTION: {str(e)}\n")
        
        return {
            'success': False,
            'color_space': color_space,
            'test_id': test_id,
            'shifts': shifts,
            'error': str(e),
            'debug_file': debug_file
        }

def print_progress(percentage):
    """Display a simple ASCII progress bar (no Unicode)."""
    bar_length = 40
    filled = int(bar_length * percentage / 100)
    bar = '=' * filled + '-' * (bar_length - filled)
    print(f'\rProgress: [{bar}] {percentage:.1f}%', end='', flush=True)

def calculate_core_count(percent):
    """Calculate number of cores to use based on percentage."""
    total_cores = cpu_count()
    if percent <= 0:
        return 1
    elif percent >= 1:
        return total_cores
    return max(1, int(round(total_cores * percent)))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Generate random shifts for all color spaces and apply to an image',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -i photo.jpg
  %(prog)s -i petals.jpg -n 3 -o test_results
  %(prog)s -i photo.jpg --seed 42 --cores 0.5
        """
    )

    parser.add_argument('-i', '--image', required=True,
                       help='Source image file path')
    parser.add_argument('-o', '--output-dir', default='color_test_results',
                       help='Output directory for test images (default: color_test_results)')
    parser.add_argument('-n', '--num-tests', type=int, default=1,
                       help='Number of random tests per color space (default: 1)')
    parser.add_argument('--seed', type=int,
                       help='Random seed for reproducible results')
    parser.add_argument('--cores', '-p', type=float, default=0.75,
                       help='Percentage of CPU cores to use (0.0-1.0, default: 0.75)')

    args = parser.parse_args()

    # Validate cores parameter
    if args.cores < 0 or args.cores > 1:
        print("\nError: --cores must be between 0.0 and 1.0\n", file=sys.stderr)
        sys.exit(1)

    # Check if source image exists
    if not os.path.exists(args.image):
        print(f"\nError: Image file '{args.image}' not found!\n", file=sys.stderr)
        sys.exit(1)

    # Debug info
    print(f"\nTest runner script location: {SCRIPT_DIR}")
    print(f"Looking for target script: {TARGET_SCRIPT}")
    
    # Check if the target script exists
    if not os.path.exists(TARGET_SCRIPT):
        print(f"\nError: {TARGET_SCRIPT} not found!", file=sys.stderr)
        print(f"Please ensure image_adjust_coloraide.py is in the same directory as this test runner.\n", file=sys.stderr)
        sys.exit(1)

    # Create output directory
    output_dir = os.path.join(SCRIPT_DIR, args.output_dir)
    os.makedirs(output_dir, exist_ok=True)
    print(f"Output directory: {output_dir}")

    # Calculate cores to use
    total_cores = cpu_count()
    cores_to_use = calculate_core_count(args.cores)
    print(f"Using {cores_to_use} of {total_cores} CPU cores ({args.cores*100:.0f}%)")

    # Generate all tests
    all_tests = []
    test_count = 0
    
    print("\nGenerating random shifts...")
    for color_space in COLORSPACES.keys():
        tests = generate_random_shifts(color_space, args.num_tests, args.seed)
        for shifts in tests:
            all_tests.append((args.image, output_dir, color_space, shifts, test_count, args.cores))
            test_count += 1
    
    total_tests = len(all_tests)
    print(f"Total tests to run: {total_tests}")
    
    # Run tests in parallel
    print("\nRunning tests...")
    start_time = time.time()
    
    results = []
    with Pool(processes=cores_to_use) as pool:
        for i, result in enumerate(pool.imap(run_test, all_tests)):
            results.append(result)
            print_progress((i + 1) / total_tests * 100)
    
    print()  # New line after progress bar
    
    # Process results
    successful = [r for r in results if r['success']]
    failed = [r for r in results if not r['success']]
    
    elapsed = time.time() - start_time
    
    # Generate plain text report
    report_file = os.path.join(output_dir, f"test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt")
    
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write("COLOR SPACE TEST RUNNER REPORT\n")
        f.write("=" * 50 + "\n\n")
        
        f.write(f"Test run: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Source image: {args.image}\n")
        f.write(f"Random seed: {args.seed if args.seed else 'None'}\n")
        f.write(f"Tests per space: {args.num_tests}\n")
        f.write(f"CPU cores used: {cores_to_use}/{total_cores}\n")
        f.write(f"Total tests: {total_tests}\n")
        f.write(f"Successful: {len(successful)}\n")
        f.write(f"Failed: {len(failed)}\n")
        f.write(f"Processing time: {elapsed:.2f} seconds\n\n")
        
        if successful:
            f.write("SUCCESSFUL TESTS\n")
            f.write("-" * 50 + "\n")
            for r in sorted(successful, key=lambda x: (x['color_space'], x['test_id'])):
                human_shifts = format_shift_human(r['shifts'], r['color_space'])
                f.write(f"{r['color_space']} test {r['test_id']:03d}:\n")
                f.write(f"  File: {os.path.basename(r['output_file'])}\n")
                f.write(f"  Shifts: {human_shifts}\n")
                if 'debug_file' in r:
                    f.write(f"  Debug: {os.path.basename(r['debug_file'])}\n")
                f.write("\n")
        
        if failed:
            f.write("\nFAILED TESTS\n")
            f.write("-" * 50 + "\n")
            for r in sorted(failed, key=lambda x: (x['color_space'], x['test_id'])):
                human_shifts = format_shift_human(r['shifts'], r['color_space'])
                f.write(f"{r['color_space']} test {r['test_id']:03d}:\n")
                f.write(f"  Shifts: {human_shifts}\n")
                f.write(f"  Error: {r.get('error', 'Unknown')}\n")
                if 'debug_file' in r:
                    f.write(f"  Debug: {os.path.basename(r['debug_file'])}\n")
                f.write("\n")
        
        f.write("=" * 50 + "\n")
        f.write("END OF REPORT\n")
    
    # Console output
    print(f"\nTests completed in {elapsed:.2f} seconds")
    print(f"Successful: {len(successful)}/{total_tests}")
    
    if failed:
        print(f"Failed: {len(failed)}")
        print("\nFirst few failures:")
        for f in failed[:3]:
            print(f"  {f['color_space']} test {f['test_id']}: {f.get('error', 'Unknown')[:100]}")
    
    print("\nGenerated images:")
    for r in successful[:10]:  # Show first 10
        print(f"  {os.path.basename(r['output_file'])}")
    
    if len(successful) > 10:
        print(f"  ... and {len(successful) - 10} more")
    
    print(f"\nDebug logs saved for each test in: {output_dir}")
    print(f"Detailed report saved to: {report_file}")
    print("\nDone!")