#!/usr/bin/env python3
"""
Test runner for Image Bomber Processing sketch.
Directly patches JSON config with globals from CSV of test configs, runs sketch, logs results with notes, and repeats for every config in the CSV.
Cleans up output files before each test to ensure clean results.
"""

import csv
import json
import os
import subprocess
import sys
import re
import shutil
import argparse
from typing import Dict, List, Any, Optional
from datetime import datetime

# Configuration
DEFAULT_TEST_CSV_PATH = "test_cases2.csv"
DEFAULT_BASE_JSON_PATH = "image_bomber_configs/test.json"
DEFAULT_RESULTS_LOG_PATH = "test_results.csv"
PROCESSING_CMD = r'"C:\Program Files\Processing\processing.exe"'

# Patterns for files/folders to delete before each test
PATTERNS_TO_DELETE = [
    r'.*__seed_.*\.png$',           # PNG files with __seed_ in name
    r'layers_.*',                     # folders starting with layers_
    r'_imageBomber__anim_run__.*'  # folders starting with _imageBomber__anim_run__
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
    
    return parser.parse_args()

def warn_and_confirm():
    """Show warning and get user confirmation before proceeding."""
    print("=" * 60)
    print("WARNING: File Cleanup Utility")
    print("=" * 60)
    print("This script will DELETE all files/folders matching these patterns:")
    print()
    for pattern in PATTERNS_TO_DELETE:
        print(f"  • {pattern}")
    print()
    print(f"From directory: {os.getcwd()}")
    print()
    print("This includes:")
    print("  • All saved animation frames (PNG files with seeds)")
    print("  • All layer output folders")
    print("  • All animation run folders")
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

def load_test_cases(csv_path: str, start_test_id: Optional[int] = None) -> List[Dict]:
    """Load test cases from CSV, optionally starting from a specific test ID."""
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
    
    # Filter to start from specific test ID if requested
    if start_test_id is not None:
        filtered_cases = []
        found = False
        for test_case in all_test_cases:
            if test_case.get('test_id') == start_test_id:
                found = True
            if found:
                filtered_cases.append(test_case)
        
        if not found:
            print(f"ERROR: Test ID {start_test_id} not found in {csv_path}")
            sys.exit(1)
        
        print(f"Starting from test ID {start_test_id}, will run {len(filtered_cases)} tests")
        return filtered_cases
    
    return all_test_cases

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

def display_test_info(test_case: Dict) -> None:
    """Display test ID and configuration."""
    print(f"\nTest ID: {test_case.get('test_id')}")
    for key, value in test_case.items():
        if key not in ['test_id', 'expected_result', 'expected result']:
            print(f"  {key}: {value}")
    
    expected = test_case.get('expected_result') or test_case.get('expected result')
    if expected:
        print(f"\nExpected: {expected}")

def prompt_user_result(test_case: Dict) -> tuple[str, str, bool]:
    """Prompt user for test result and optional notes.
    Returns: (result, notes, retest_flag)"""
    print("\nResult codes:")
    print("  p = PASS")
    print("  f = FAIL")
    print("  a = PARTIAL")
    print("  s = SKIP")
    print("  r = RETEST (run this test again)")
    print("  q = QUIT")
    
    r = input("\nResult: ").strip().lower()
    
    # Handle RETEST specially
    if r == 'r':
        return 'RETEST', "", True
    
    result_map = {'p': 'PASS', 'f': 'FAIL', 'a': 'PARTIAL', 's': 'SKIP', 'q': 'QUIT'}
    result = result_map.get(r, 'SKIP')
    
    notes = ""
    if result in ['FAIL', 'PARTIAL']:
        notes = input("Notes: ").strip()
    
    return result, notes, False

def log_result(results_file: str, test_case: Dict, result: str, notes: str, output: str) -> None:
    """Log test result."""
    results_path = resolve_path(results_file)
    row = test_case.copy()
    row['result'] = result
    row['notes'] = notes
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
    
    # Load all test cases once - we'll use an index to track position
    all_test_cases = load_test_cases(DEFAULT_TEST_CSV_PATH, args.testid)
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
        
        # Display test info before running the sketch
        display_test_info(test_case)
        
        patch_json_config(json_path, test_case)
        success, output = run_processing_sketch(sketch_path)
        
        result, notes, retest = prompt_user_result(test_case)
        
        if result == 'QUIT':
            break
        elif retest:
            # Stay on the same test index to retest
            print("\nRETESTING same configuration...")
            continue
        else:
            # Log the result and move to next test
            log_result(DEFAULT_RESULTS_LOG_PATH, test_case, result, notes, output)
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