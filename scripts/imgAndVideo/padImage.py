# DESCRIPTION
# Takes an input image and background color and pads the image to larger dimensions using the background color, writing to a new image. For example letterboxing or keeping all image information but making the image fit a different overall shape.

# DEPENDENCIES
# Requires Python 3.x and Pillow (PIL) library.
# Install Pillow with: pip install Pillow
# Uses argparse which is built into Python 3.x.

# USAGE
# Required arguments:
#   -i, --input        source image file name
#   -c, --colorhexcode color to use for padding, expressed as sRGB hex without # sign
#                      (6 chars for RGB, 8 chars for RGBA)

# At least one of these must be provided (if all are omitted, script will error):
#   -x, --xpad         number of pixels to add horizontally (split left/right)
#   -y, --ypad         number of pixels to add vertically (split top/bottom)
#   -r, --resizex      target x dimension to resize/pad to. Must be >= original width.
#   -s, --resizey      target y dimension to resize/pad to. Must be >= original height.

# Optional argument:
#   -o, --overwriteoriginal  if set, overwrites the original image instead of creating a new file

# Notes:
#   -x and -y add a specific number of pixels (padding amount)
#   -r and -s set target dimensions (resulting size)
#   You can mix padding and resize on the same axis - the final dimension will be the MAXIMUM of:
#     (original + padding) and (resize target)
#   Example: original width 100, -x 50, -r 200 -> final width = max(150, 200) = 200
#   Example: original width 100, -x 50, -r 120 -> final width = max(150, 120) = 150
#   When using -r or -s, the target dimension must be >= original dimension
#   If total padding is odd, the extra pixel goes to the right (for x) or bottom (for y)

# Output filename behavior:
#   Without -o: creates [original_name]_xPad[value]_yPad[value]_canvasResize_[r]x[s].[ext]
#               (only includes suffixes for dimensions that were specified)
#               Examples:
#                 image.png -> image_xPad50_yPad70.png (added 50px horizontally, 70px vertically)
#                 photo.jpg -> photo_canvasResize_1920x1080.jpg (resized to 1920x1080)
#                 portrait.png -> portrait_xPad100_canvasResize_1920x1200.png (added 100px horizontally, resized canvas to 1920x1200)
#   
#   With -o:    overwrites the original image file

# Examples:
#   Add 100 pixels horizontally (50 left, 50 right):
#     python padImage.py -i image.png -x 100 -c 000000
#   
#   Add 50 pixels vertically (25 top, 25 bottom):
#     python padImage.py -i image.png -y 50 -c E0DBC8
#   
#   Pad to exact dimensions 1920x1080:
#     python padImage.py -i photo.jpg -r 1920 -s 1080 -c FFFFFF
#   
#   Add horizontal padding and ensure minimum canvas height of 1200:
#     python padImage.py -i portrait.png -x 200 -s 1200 -c 01edfd80
#   
#   Mix padding and resize (adds 100px horizontally, ensures canvas at least 800 tall):
#     python padImage.py -i image.png -x 100 -s 800 -c 000000FF
#   
#   Pad to wider aspect ratio and overwrite original:
#     python padImage.py -i landscape.jpg -r 1920 -c 000000 -o

#CODE
import sys
import argparse
import os
from PIL import Image

# Set up argument parser
parser = argparse.ArgumentParser(description='Pad an image to larger dimensions with a background color.')
parser.add_argument('-i', '--input', required=True, help='source image file name')
parser.add_argument('-c', '--colorhexcode', required=True, help='sRGB hex color (6 chars RGB, 8 chars RGBA)')
parser.add_argument('-x', '--xpad', type=int, help='number of pixels to add horizontally')
parser.add_argument('-y', '--ypad', type=int, help='number of pixels to add vertically')
parser.add_argument('-r', '--resizex', type=int, help='target x dimension (must be >= original width)')
parser.add_argument('-s', '--resizey', type=int, help='target y dimension (must be >= original height)')
parser.add_argument('-o', '--overwriteoriginal', action='store_true', help='overwrite original image instead of creating new file')

args = parser.parse_args()

# Ensure at least one padding/resize option is provided
if (args.xpad is None and args.ypad is None and 
    args.resizex is None and args.resizey is None):
    print("Error: At least one of --xpad, --ypad, --resizex, or --resizey must be provided")
    sys.exit(1)

# Open source image
try:
    im = Image.open(args.input)
except FileNotFoundError:
    print(f"Error: Source image '{args.input}' not found")
    sys.exit(1)
except Exception as e:
    print(f"Error opening image: {e}")
    sys.exit(1)

width, height = im.size

# Validate padding amounts are not negative
if args.xpad is not None and args.xpad < 0:
    print(f"Error: --xpad value ({args.xpad}) cannot be negative")
    sys.exit(1)

if args.ypad is not None and args.ypad < 0:
    print(f"Error: --ypad value ({args.ypad}) cannot be negative")
    sys.exit(1)

# Validate resize dimensions are not smaller than original
if args.resizex is not None and args.resizex < width:
    print(f"Error: --resizex target ({args.resizex}) must be >= original width ({width})")
    sys.exit(1)

if args.resizey is not None and args.resizey < height:
    print(f"Error: --resizey target ({args.resizey}) must be >= original height ({height})")
    sys.exit(1)

# Calculate target dimensions using additive approach (max of padded and resize targets)
padded_width = width + (args.xpad if args.xpad is not None else 0)
padded_height = height + (args.ypad if args.ypad is not None else 0)

target_width = padded_width
target_height = padded_height

if args.resizex is not None:
    target_width = max(padded_width, args.resizex)
if args.resizey is not None:
    target_height = max(padded_height, args.resizey)

# Calculate padding amounts for centering (handles odd totals)
x_pad_total = target_width - width
y_pad_total = target_height - height

# Distribute padding (if odd, extra pixel goes to right/bottom)
xLeftPad = x_pad_total // 2
xRightPad = x_pad_total - xLeftPad

yTopPad = y_pad_total // 2
yBottomPad = y_pad_total - yTopPad

# hex to sRGB integer conversion
hex_color = args.colorhexcode.lstrip("#")

# Parse color with optional alpha
if len(hex_color) == 6:
    # RGB only
    sRGB = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    
    # If source has alpha, we don't know what alpha value to use
    if im.mode in ('RGBA', 'LA'):
        print("Error: Source image has alpha channel but you provided only 6 hex digits (RGB).")
        print("Please provide 8 hex digits (RGBA) to specify alpha value, e.g.:")
        print(f"  - For fully opaque background: {hex_color}FF")
        print(f"  - For fully transparent background: {hex_color}00")
        print(f"  - For 50% opacity: {hex_color}80")
        sys.exit(1)
        
elif len(hex_color) == 8:
    # RGBA
    sRGB = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4, 6))
else:
    print("Error: Hex color must be 6 characters (RGB) or 8 characters (RGBA)")
    sys.exit(1)

# Determine output mode
if im.mode in ('RGBA', 'LA') or len(sRGB) == 4:
    # Source has alpha or we're using RGBA color
    output_mode = 'RGBA'
    # If sRGB is RGB only but source has alpha, we already handled that as an error above
else:
    output_mode = 'RGB'
    # If sRGB is RGBA but source doesn't have alpha, strip alpha
    if len(sRGB) == 4:
        sRGB = sRGB[:3]

# Convert image if needed
if im.mode != output_mode:
    im = im.convert(output_mode)

result = Image.new(output_mode, (target_width, target_height), sRGB)

# Paste original image using calculated padding
# xLeftPad and yTopPad position the top-left corner of original image
result.paste(im, (xLeftPad, yTopPad))

# Determine output filename
if args.overwriteoriginal:
    outfileName = args.input
else:
    # Build descriptive suffix
    suffix_parts = []
    if args.xpad is not None:
        suffix_parts.append(f"xPad{args.xpad}")
    if args.ypad is not None:
        suffix_parts.append(f"yPad{args.ypad}")
    
    # Handle resize suffix (only if either resize dimension was specified)
    if args.resizex is not None or args.resizey is not None:
        r_val = args.resizex if args.resizex is not None else width
        s_val = args.resizey if args.resizey is not None else height
        suffix_parts.append(f"canvasResize_{r_val}x{s_val}")
    
    suffix = "_" + "_".join(suffix_parts)
    
    # Split path and filename
    dir_name = os.path.dirname(args.input)
    base_name = os.path.basename(args.input)
    name, ext = os.path.splitext(base_name)
    
    # Construct new filename: name + suffix + extension
    new_base_name = f"{name}{suffix}{ext}"
    outfileName = os.path.join(dir_name, new_base_name)

try:
    result.save(outfileName)
    print("DONE. Wrote padded image to", outfileName)
except Exception as e:
    print(f"Error saving image: {e}")
    sys.exit(1)