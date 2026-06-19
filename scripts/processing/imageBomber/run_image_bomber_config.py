#!/usr/bin/env python3
"""
DESCRIPTION
Run Image Bomber Processing sketch with a specific JSON config file.
Uses the sketch's built-in CLI argument support for config path override.

DEPENDENCIES
- Processing 4.x or later (processing-java in PATH)
- Image Bomber Processing sketch with CLI arg support (args[0] reads config path)

USAGE
python run_image_bomber_config.py /path/to/sketch /path/to/config.json

Examples:
python run_image_bomber_config.py . ./image_bomber_configs/imageBomberDefaultConfig.json
python run_image_bomber_config.py . ./image_bomber_configs/test.json

NOTES
- Paths are relative to the current working directory
- The sketch must have been modified to accept config path as first CLI argument
- See imageBomber.pde setup() for the CLI argument handling

CODE
"""

import subprocess
import sys
import os

# Change this if necessary to match your Processing installation
PROCESSING_CMD = r'"C:\Program Files\Processing\processing.exe"'
# For Mac: PROCESSING_CMD = '/Applications/Processing.app/Contents/MacOS/Processing'
# For Linux: PROCESSING_CMD = 'processing-java'

def run_image_bomber(sketch_path: str, config_path: str) -> bool:
    """Run the sketch with the given config file."""
    
    # Resolve paths relative to current working directory
    sketch_path = os.path.abspath(sketch_path)
    config_path = os.path.abspath(config_path)
    
    # Verify files exist
    if not os.path.exists(config_path):
        print(f"ERROR: Config not found: {config_path}")
        return False
    
    if not os.path.exists(sketch_path):
        print(f"ERROR: Sketch not found: {sketch_path}")
        return False
    
    # The sketch expects config path as first argument
    # Processing's --args passes everything after it to the sketch's args array
    cmd = f'{PROCESSING_CMD} cli --sketch="{sketch_path}" --run --args="{config_path}"'
    print(f"\nRunning: {cmd}\n")
    
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
            
        return result.returncode == 0
        
    except Exception as e:
        print(f"ERROR: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python run_image_bomber_config.py /path/to/sketch /path/to/config.json")
        print("Example: python run_image_bomber_config.py ./imageBomber ./image_bomber_configs/test.json")
        sys.exit(1)
    
    sketch_path = sys.argv[1]
    config_path = sys.argv[2]
    
    success = run_image_bomber(sketch_path, config_path)
    sys.exit(0 if success else 1)