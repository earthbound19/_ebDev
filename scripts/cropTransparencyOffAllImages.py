# DESCRIPTION
# Creates cropped copies of all images of many types in the current directory, such that all areas without any pixels (only transparency -- or alternately only white?) are cropped off, and only a rectangle bounding all pixel values remains. Useful for preparing art for later conversion to a vector format without wasted border space.

# USAGE
# Run from a directory tree with one or more images of a given type (with associated extension), e.g. png, and run with:
# REQUIRED. -t --type, the image file type to operate on
# OPTIONAL. -o --overwrite, which will cause it to clobber the original files instead of saving to files named after the original but adding _cropped to the base file name.
# For example, to operate on all png images and save cropped results to new files, run:
#    python /path_to/cropTransparencyOffAllImages.py --type png
# Or just with the -t flag:
#    python /path_to/cropTransparencyOffAllImages.py -t png
# To operate on all png images and overwrite the original files with the result, run:
#    python /path_to/cropTransparencyOffAllImages.py -t png --overwrite
# Or just with the -o flag:
#    python /path_to/cropTransparencyOffAllImages.py -t png -o
# Without the -o flag, result images are named after the original file names but add _cropped to the base file name. With the -o flag, original files are permanently overwritten with the cropped result; you may wish to only overwrite the original files if you can afford to lose them (for example if you have a backup of them) should something go wrong.


# CODE
# Adapted from - https://stackoverflow.com/a/61952048 - Posted by Basj
# Retrieved 2026-02-08, License - CC BY-SA 4.0

import argparse
import os
import numpy as np
from PIL import Image

parser = argparse.ArgumentParser(
    description='Crop white borders from all images of specified type in current directory.'
)
parser.add_argument(
    '-t', '--type',
    required=True,
    help='Image file type to process (e.g., png, jpg, jpeg)'
)
parser.add_argument(
    '-o', '--overwrite',
    action='store_true',
    help='Overwrite original files instead of creating new _cropped files'
)

args = parser.parse_args()

def bbox(im):
    a = np.array(im)[:,:,:3]  # keep RGB only
    m = np.any(a != [255, 255, 255], axis=2)
    coords = np.argwhere(m)
    y0, x0, y1, x1 = *np.min(coords, axis=0), *np.max(coords, axis=0)
    return (x0, y0, x1+1, y1+1)

def process_images(file_type, overwrite=False):
    # Get all files with the specified extension in current directory
    files = [f for f in os.listdir('.') if f.lower().endswith(f'.{file_type.lower()}')]
    
    if not files:
        print(f"No .{file_type} files found in current directory.")
        return
    
    print(f"Found {len(files)} .{file_type} file(s) to process.")
    print(f"Overwrite mode: {'ON (original files will be replaced)' if overwrite else 'OFF (new _cropped files will be created)'}")
    
    for file_name in files:
        try:
            print(f"Processing: {file_name}")
            
            # Open image
            im = Image.open(file_name)
            
            # Get bounding box and crop
            crop_box = bbox(im)
            im2 = im.crop(crop_box)
            
            # Determine output filename based on overwrite flag
            if overwrite:
                output_name = file_name
            else:
                name_without_ext = os.path.splitext(file_name)[0]
                output_name = f"{name_without_ext}_cropped.{file_type}"

            im2.save(output_name)
            print(f"  Saved cropped image as: {output_name}")
            
        except Exception as e:
            print(f"  Error processing {file_name}: {e}")

# Process all images of the specified type
process_images(args.type, args.overwrite)