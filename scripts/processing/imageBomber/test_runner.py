#!/usr/bin/env python3
"""
Test runner for Image Bomber Processing sketch.
Directly patches JSON config, runs sketch, logs results with notes.
"""

import csv
import json
import os
import subprocess
import sys
from typing import Dict, List, Any
from datetime import datetime

# Configuration
TEST_CSV_PATH = "test_cases.csv"
BASE_JSON_PATH = "image_bomber_configs/test.json"
RESULTS_LOG_PATH = "test_results.csv"
PROCESSING_CMD = r'"C:\Program Files\Processing\processing.exe"'

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

def load_test_cases(csv_path: str) -> List[Dict]:
    """Load test cases from CSV."""
    test_cases = []
    with open(resolve_path(csv_path), 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        print(f"Discovered columns: {', '.join(reader.fieldnames)}")
        for row in reader:
            test_case = {}
            for col, val in row.items():
                test_case[col.strip()] = detect_type(val)
            if 'test_id' in test_case:
                test_cases.append(test_case)
    print(f"Loaded {len(test_cases)} test cases")
    return test_cases

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

def prompt_user_result(test_case: Dict) -> tuple[str, str]:
    """Prompt user for test result and optional notes."""
    print(f"\nTest ID: {test_case.get('test_id')}")
    for key, value in test_case.items():
        if key not in ['test_id', 'expected_result', 'expected result']:
            print(f"  {key}: {value}")
    
    expected = test_case.get('expected_result') or test_case.get('expected result')
    if expected:
        print(f"\nExpected: {expected}")
    
    print("\nResult codes:")
    print("  p = PASS")
    print("  f = FAIL")
    print("  a = PARTIAL")
    print("  s = SKIP")
    print("  q = QUIT")
    
    r = input("\nResult: ").strip().lower()
    result_map = {'p': 'PASS', 'f': 'FAIL', 'a': 'PARTIAL', 's': 'SKIP', 'q': 'QUIT'}
    result = result_map.get(r, 'SKIP')
    
    notes = ""
    if result in ['FAIL', 'PARTIAL']:
        notes = input("Notes: ").strip()
    
    return result, notes

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
    if len(sys.argv) < 2:
        print("Usage: python test_runner.py <sketch_folder>")
        print("Example: python test_runner.py '/c/Users/username/Documents/Processing/imageBomber'")
        sys.exit(1)
    
    sketch_path = sys.argv[1]
    json_path = resolve_path(BASE_JSON_PATH)
    
    if not os.path.exists(json_path):
        print(f"ERROR: JSON config not found at {json_path}")
        sys.exit(1)
    
    test_cases = load_test_cases(TEST_CSV_PATH)
    if not test_cases:
        print("ERROR: No test cases found")
        sys.exit(1)
    
    for i, test_case in enumerate(test_cases):
        print(f"\n{'='*60}")
        print(f"Test {i+1}/{len(test_cases)}")
        
        patch_json_config(BASE_JSON_PATH, test_case)
        success, output = run_processing_sketch(sketch_path)
        
        result, notes = prompt_user_result(test_case)
        if result == 'QUIT':
            break
        
        log_result(RESULTS_LOG_PATH, test_case, result, notes, output)
        
        if i < len(test_cases) - 1:
            if input("\nNext test? (y/n): ").lower() != 'y':
                break
    
    print(f"\nResults saved to {RESULTS_LOG_PATH}")

if __name__ == "__main__":
    main()