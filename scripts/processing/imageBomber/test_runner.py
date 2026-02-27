#!/usr/bin/env python3
"""
Test runner for Image Bomber Processing sketch.
Directly patches JSON config with globals from CSV of test configs, runs sketch,
automatically verifies output files, logs results with notes, and repeats for every config.
"""

import csv
import json
import os
import subprocess
import sys
import re
import shutil
import glob
import argparse
import random
from typing import Dict, List, Any, Optional, Tuple
from datetime import datetime
from PIL import Image

# Configuration
DEFAULT_TEST_CSV_PATH = "test_cases.csv"
DEFAULT_BASE_JSON_PATH = "image_bomber_configs/test.json"
DEFAULT_RESULTS_LOG_PATH = "test_results.csv"
PROCESSING_CMD = r'"C:\Program Files\Processing\processing.exe"'

# Patterns for files/folders to delete before each test
PATTERNS_TO_DELETE = [
    r'_imageBomber__v.*__seed_.*\.png$',           # PNG files with __seed_ in name
    r'_imageBomber__layers__v.*',   # folders starting with layers_
    r'_imageBomber__anim_run__.*'   # folders starting with _imageBomber__anim_run__
]

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Test runner for Image Bomber Processing sketch",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python test_runner.py -s /path/to/sketch
  python test_runner.py --scriptpath /path/to/sketch --configfile my_config.json
  python test_runner.py -s /path/to/sketch -t 15
  python test_runner.py -s /path/to/sketch -c custom_config.json -t 25
        """
    )

    parser.add_argument(
        '-s', '--scriptpath',
        required=True,
        help='Path to the Processing script folder'
    )

    parser.add_argument(
        '-c', '--configfilepath',
        default=DEFAULT_BASE_JSON_PATH,
        help=f'Path to the JSON config file to use (default: {DEFAULT_BASE_JSON_PATH})'
    )

    parser.add_argument(
        '-t', '--testid',
        type=int,
        help='Numeric test ID to skip to. If omitted, starts from first test.'
    )

    parser.add_argument(
        '-r', '--randomorder',
        action='store_true',
        help='Flag. If provided, test order will be randomized. If provided with -t/--testid, that test ID will still be first.'
    )

    return parser.parse_args()

def warn_and_confirm():
    """Show warning and get user confirmation before proceeding."""
    print("=" * 60)
    print("WARNING: File Cleanup Utility")
    print("=" * 60)
    print("This script will DELETE all files/folders matching these patterns:")
    print()
    for pattern in PATTERNS_TO_DELETE:
        print(f"  - {pattern}")
    print()
    print(f"From directory: {os.getcwd()}")
    print()
    print("This includes:")
    print("  - All saved animation frames (PNG files with seeds)")
    print("  - All layer output folders")
    print("  - All animation run folders")
    print()
    print("This cleanup will run BEFORE EVERY TEST to assist in easily isolating test data.")
    print("This action is PERMANENT and cannot be undone.")
    print()

    response = input("Are you sure you want to continue? (yes/NO): ").strip().lower()
    if response != 'yes':
        print("Cleanup cancelled. Exiting.")
        return False
    return True

def delete_matching_files():
    """Delete all files and folders matching the patterns."""
    deleted_count = 0
    error_count = 0

    # Walk through the current directory
    for root, dirs, files in os.walk(os.getcwd(), topdown=False):
        # Check directories
        for dir_name in dirs:
            full_path = os.path.join(root, dir_name)
            for pattern in PATTERNS_TO_DELETE:
                if re.match(pattern, dir_name):
                    try:
                        shutil.rmtree(full_path)
                        print(f"  Deleted folder: {os.path.relpath(full_path, os.getcwd())}")
                        deleted_count += 1
                        break
                    except Exception as e:
                        print(f"  Error deleting folder {full_path}: {e}")
                        error_count += 1

        # Check files
        for file_name in files:
            full_path = os.path.join(root, file_name)
            for pattern in PATTERNS_TO_DELETE:
                if re.match(pattern, file_name):
                    try:
                        os.remove(full_path)
                        print(f"  Deleted file: {os.path.relpath(full_path, os.getcwd())}")
                        deleted_count += 1
                        break
                    except Exception as e:
                        print(f"  Error deleting file {full_path}: {e}")
                        error_count += 1

    return deleted_count, error_count

def resolve_path(path: str) -> str:
    """Resolve a path relative to the script location."""
    if os.path.isabs(path):
        return path
    return os.path.join(os.getcwd(), path)

def detect_type(value: str) -> Any:
    """Convert string to appropriate type."""
    value = value.strip()
    if value.lower() == 'true':
        return True
    if value.lower() == 'false':
        return False
    try:
        return int(value)
    except ValueError:
        pass
    try:
        return float(value)
    except ValueError:
        pass
    return value

def load_test_cases(csv_path: str, start_test_id: Optional[int] = None, randomorder: bool = False) -> List[Dict]:
    """Load test cases from CSV, optionally starting from a specific test ID and/or randomizing order."""
    all_test_cases = []
    with open(resolve_path(csv_path), 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        print(f"Discovered columns: {', '.join(reader.fieldnames)}")
        for row in reader:
            test_case = {}
            for col, val in row.items():
                test_case[col.strip()] = detect_type(val)
            if 'test_id' in test_case:
                all_test_cases.append(test_case)

    print(f"Loaded {len(all_test_cases)} test cases total")

    # Case 1: No start_test_id
    if start_test_id is None:
        if randomorder:
            import random
            shuffled = all_test_cases.copy()
            random.shuffle(shuffled)
            print(f"Randomized order of {len(shuffled)} test cases")
            return shuffled
        return all_test_cases

    # Case 2: We have a start_test_id
    # Find the target test case
    target_index = None
    for i, test_case in enumerate(all_test_cases):
        if test_case.get('test_id') == start_test_id:
            target_index = i
            break

    if target_index is None:
        print(f"ERROR: Test ID {start_test_id} not found in {csv_path}")
        sys.exit(1)

    # Reorder tests to start with the target, then continue in original order wrapping around
    reordered = all_test_cases[target_index:] + all_test_cases[:target_index]
    
    if randomorder:
        import random
        # Keep the first test (target), randomize the rest
        first_test = reordered[0:1]
        rest_tests = reordered[1:]
        random.shuffle(rest_tests)
        result = first_test + rest_tests
        print(f"Test ID {start_test_id} will run first, followed by {len(rest_tests)} randomized tests")
    else:
        result = reordered
        print(f"Starting from test ID {start_test_id}, will run {len(reordered)} tests in original cyclic order")
    
    return result

def patch_json_config(json_path: str, test_case: Dict) -> None:
    """Directly patch the JSON config file."""
    json_path = resolve_path(json_path)

    with open(json_path, 'r', encoding='utf-8') as f:
        config = json.load(f)

    settings = config['global_settings']

    # Apply all fields except test_id and expected_result
    skip_fields = {'test_id', 'expected_result', 'expected result'}
    patched = []
    for key, value in test_case.items():
        if key not in skip_fields and value is not None and key in settings:
            settings[key] = value
            patched.append(key)

    if patched:
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=4)
        print(f"Patched: {', '.join(patched)}")

def run_processing_sketch(sketch_path: str) -> tuple[bool, str]:
    """Run the Processing sketch."""
    # Handle Windows/Cygwin paths
    if sys.platform in ["win32", "cygwin"]:
        try:
            sketch_path = subprocess.run(
                ["cygpath", "-w", sketch_path],
                capture_output=True, text=True, check=True
            ).stdout.strip() or sketch_path
        except:
            pass

    cmd = f'{PROCESSING_CMD} cli --sketch="{sketch_path}" --run'

    print(f"\nRunning: {cmd}")

    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=300
        )

        output = result.stdout + "\n" + result.stderr
        return (result.returncode == 0, output)

    except Exception as e:
        return (False, str(e))

def is_valid_png(file_path: str) -> bool:
    """Check if a file is a valid PNG image."""
    try:
        with Image.open(file_path) as img:
            return img.format == 'PNG'
    except Exception:
        return False

def verify_animation_folder() -> Tuple[bool, str]:
    """Verify animation folder exists and contains valid PNG files."""
    anim_pattern = "_imageBomber__anim_run__*"
    matching_dirs = glob.glob(anim_pattern)

    if not matching_dirs:
        return False, "Animation folder not found"

    anim_dir = matching_dirs[0]
    if not os.path.isdir(anim_dir):
        return False, f"Animation path exists but is not a directory: {anim_dir}"

    png_files = glob.glob(os.path.join(anim_dir, "*.png"))
    if not png_files:
        return False, f"No PNG files found in animation folder {anim_dir}"

    test_file = random.choice(png_files)
    if not is_valid_png(test_file):
        return False, f"Invalid PNG file: {test_file}"

    return True, f"Animation folder OK: {anim_dir} with {len(png_files)} frames"

def verify_layers_folder() -> Tuple[bool, str]:
    """Verify layers folder exists and contains valid PNG files."""
    layers_pattern = "_imageBomber__layers__*"
    matching_dirs = glob.glob(layers_pattern)

    if not matching_dirs:
        return False, "Layers folder not found"

    layers_dir = matching_dirs[0]
    if not os.path.isdir(layers_dir):
        return False, f"Layers path exists but is not a directory: {layers_dir}"

    png_files = glob.glob(os.path.join(layers_dir, "*.png"))
    if not png_files:
        return False, f"No PNG files found in layers folder {layers_dir}"

    test_file = random.choice(png_files)
    if not is_valid_png(test_file):
        return False, f"Invalid PNG file: {test_file}"

    return True, f"Layers folder OK: {layers_dir} with {len(png_files)} layer files"

def verify_last_frame_files() -> Tuple[bool, str]:
    """Verify at least one frame file exists and is a valid PNG."""
    frame_pattern = "_imageBomber__v*__seed_*_fr_*.png"
    matching_files = glob.glob(frame_pattern)

    if not matching_files:
        return False, "No frame files found"

    test_file = random.choice(matching_files)
    if not is_valid_png(test_file):
        return False, f"Invalid PNG file: {test_file}"

    return True, f"Frame file(s) OK: found {len(matching_files)} files"

def verify_automated_results(test_case: Dict) -> Dict[str, Any]:
    """Automatically verify file-based results."""
    results = {
        'automated_checks': {},
        'automated_pass': True,
        'automated_notes': []
    }

    save_frames = test_case.get('saveFrames', False)
    save_layers = test_case.get('saveLayers', False)
    save_last_frame = test_case.get('saveLastFrameEveryVariant', False)

    # Verify animation folder if saveFrames is True
    if save_frames:
        anim_ok, anim_msg = verify_animation_folder()
        results['automated_checks']['animation_folder'] = anim_ok
        results['automated_notes'].append(f"Animation: {anim_msg}")
        if not anim_ok:
            results['automated_pass'] = False
    else:
        # Verify no animation folder was created
        if glob.glob("_imageBomber__anim_run__*"):
            results['automated_checks']['animation_folder'] = False
            results['automated_notes'].append("Animation folder created when saveFrames=False")
            results['automated_pass'] = False
        else:
            results['automated_checks']['animation_folder'] = True

    # Verify layers folder if saveLayers is True
    if save_layers:
        layers_ok, layers_msg = verify_layers_folder()
        results['automated_checks']['layers_folder'] = layers_ok
        results['automated_notes'].append(f"Layers: {layers_msg}")
        if not layers_ok:
            results['automated_pass'] = False
    else:
        # Verify no layers folder was created
        if glob.glob("_imageBomber__layers__*"):
            results['automated_checks']['layers_folder'] = False
            results['automated_notes'].append("Layers folder created when saveLayers=False")
            results['automated_pass'] = False
        else:
            results['automated_checks']['layers_folder'] = True

    # Verify last frame files if saveLastFrameEveryVariant is True
    if save_last_frame:
        last_frame_ok, last_frame_msg = verify_last_frame_files()
        results['automated_checks']['last_frame'] = last_frame_ok
        results['automated_notes'].append(f"Last frame: {last_frame_msg}")
        if not last_frame_ok:
            results['automated_pass'] = False
    else:
        # Verify no frame files were created
        if glob.glob("_imageBomber__v*__seed_*_fr_*.png"):
            results['automated_checks']['last_frame'] = False
            results['automated_notes'].append("Frame file created when saveLastFrameEveryVariant=False")
            results['automated_pass'] = False
        else:
            results['automated_checks']['last_frame'] = True

    return results

def display_test_info(test_case: Dict, automated_results: Dict[str, Any] = None) -> None:
    """Display test ID, configuration, and automated verification results."""
    print(f"\nTest ID: {test_case.get('test_id')}")
    print("-" * 40)
    print("Configuration:")
    for key, value in test_case.items():
        if key not in ['test_id', 'expected_result', 'expected result']:
            print(f"  {key}: {value}")

    expected = test_case.get('expected_result') or test_case.get('expected result')
    if expected:
        print(f"\nExpected: {expected}")

    if automated_results:
        print("\n" + "-" * 40)
        print("Automated Verification:")
        if automated_results.get('automated_pass', False):
            print("  :) All automated checks PASSED")
        else:
            print("  :/ Some automated checks FAILED")

        for note in automated_results.get('automated_notes', []):
            print(f"  - {note}")

def prompt_user_result(test_case: Dict, automated_results: Dict[str, Any]) -> tuple[str, str, bool]:
    """Prompt user for test result and optional notes."""
    print("\nResult codes:")
    print("  p = PASS (all expected behavior verified)")
    print("  k = KEEP (save automated notes and continue)")
    print("  f = FAIL (expected behavior not observed)")
    print("  a = PARTIAL (some expected behavior, some not)")
    print("  s = SKIP")
    print("  r = RETEST (run this test again)")
    print("  q = QUIT")

    # Pre-fill notes with automated results summary
    default_notes = ""
    if automated_results:
        if automated_results.get('automated_pass'):
            default_notes = "Automated file checks passed"
        else:
            fail_reasons = [note for note in automated_results.get('automated_notes', [])
                          if any(x in note.lower() for x in ['not found', 'invalid', 'error', 'fail'])]
            if fail_reasons:
                default_notes = "; ".join(fail_reasons[:2])

    r = input("\nResult: ").strip().lower()

    # Handle RETEST specially
    if r == 'r':
        return 'RETEST', "", True

    # Handle KEEP specially - save automated notes and continue
    if r == 'k':
        return 'KEEP', default_notes, False

    result_map = {'p': 'PASS', 'f': 'FAIL', 'a': 'PARTIAL', 's': 'SKIP', 'q': 'QUIT'}
    result = result_map.get(r, 'SKIP')

    notes = ""
    if result in ['FAIL', 'PARTIAL']:
        prompt = f"Notes [{default_notes}]: " if default_notes else "Notes: "
        notes = input(prompt).strip()
        if not notes and default_notes:
            notes = default_notes
    elif result == 'PASS' and default_notes:
        # Optionally accept automated notes for PASS results
        use_default = input(f"Use automated notes? ({default_notes}) [y/N]: ").strip().lower()
        if use_default == 'y':
            notes = default_notes

    return result, notes, False

def log_result(results_file: str, test_case: Dict, result: str, notes: str,
               output: str, automated_results: Dict[str, Any]) -> None:
    """Log test result including automated verification results."""
    results_path = resolve_path(results_file)
    row = test_case.copy()
    row['result'] = result
    row['notes'] = notes
    row['automated_pass'] = automated_results.get('automated_pass', False)
    row['automated_notes'] = "; ".join(automated_results.get('automated_notes', []))
    row['timestamp'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    row['output_preview'] = output[:200] + "..." if len(output) > 200 else output

    file_exists = os.path.isfile(results_path)
    with open(results_path, 'a', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=row.keys())
        if not file_exists:
            writer.writeheader()
        writer.writerow(row)

def main():
    args = parse_arguments()

    sketch_path = args.scriptpath
    json_path = resolve_path(args.configfilepath)

    if not os.path.exists(json_path):
        print(f"ERROR: JSON config not found at {json_path}")
        sys.exit(1)

    # Show warning and get confirmation before starting
    if not warn_and_confirm():
        sys.exit(0)

    # Load all test cases once - we'll use an index to track position; optionally with random order also
    all_test_cases = load_test_cases(DEFAULT_TEST_CSV_PATH, args.testid, args.randomorder)
    if not all_test_cases:
        print("ERROR: No test cases found")
        sys.exit(1)

    # Initialize test index
    i = 0
    total_tests = len(all_test_cases)

    # Main test loop - runs once through all the test cases
    while i < total_tests:
        test_case = all_test_cases[i]

        print(f"\n{'='*60}")
        print(f"Test {i+1}/{total_tests} (Global test ID: {test_case.get('test_id')}) - Cleaning up previous output files...")

        # Clean up before each test
        deleted, errors = delete_matching_files()
        print(f"  Cleanup complete: {deleted} items deleted, {errors} errors")

        # Display test info
        display_test_info(test_case)

        patch_json_config(json_path, test_case)
        success, output = run_processing_sketch(sketch_path)

        # Run automated verification
        automated_results = verify_automated_results(test_case)

        # Display test info with automated results
        display_test_info(test_case, automated_results)

        result, notes, retest = prompt_user_result(test_case, automated_results)

        if result == 'QUIT':
            break
        elif retest:
            print("\nRETESTING same configuration...")
            continue
        else:
            # Log the result and move to next test
            log_result(DEFAULT_RESULTS_LOG_PATH, test_case, result, notes, output, automated_results)
            i += 1

        # end with cleanup if last test completed
        if i == total_tests:
            print("\nAll tests completed.")
            # final cleanup
            deleted, errors = delete_matching_files()
            print(f"  Cleanup complete: {deleted} items deleted, {errors} errors")

    print(f"\nResults saved to {DEFAULT_RESULTS_LOG_PATH}")

if __name__ == "__main__":
    main()