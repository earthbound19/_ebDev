# Image Bomber Test Runner

This test runner automates the verification of behavior resulting from all possible global boolean variable configurations, for the Image Bomber Processing sketch.

## Prerequisites

1. Python 3.6+ installed
2. Processing installed at `C:\Program Files\Processing\processing.exe` (or update path in script)
3. The three files in the same directory:
   - `test_runner.py` (this script)
   - `test_cases.csv` (your test cases)
   - `image_bomber_configs/test.json` (base configuration)
4. The Image Bomber Processing sketch folder with all its files

## Usage

- hard code this variable in the Processing script imageBomber.pde:

    String JSONconfigFileName = "image_bomber_configs/test.json"

-- or to point to any test config you want used as a template. Then run:

    python test_runner.py "/path/to/processing/sketch/folder"
	
## Notes

The test runner script patches (overwrites) the image_bomber_configs/test.json with every run of a test of a configuration state. That's fine; it's a test JSON meant to be changed a lot.

The following python code helped create the test case table:

import itertools
import csv

flag_names = ['saveFrames', 'stopAtFrame', 'exitOnRenderComplete', 'renderVariantsInfinitely', 'saveLastFrame', 'saveLayers']
combinations = list(itertools.product([True, False], repeat=6))

with open('test_cases.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    
    # Write header with ID
    writer.writerow(['test_id'] + flag_names)
    
    # Write combinations with ID
    for i, combo in enumerate(combinations, 1):
        writer.writerow([i] + list(combo))