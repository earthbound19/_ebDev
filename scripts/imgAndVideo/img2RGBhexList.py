# DESCRIPTION
# Samples every pixel in an image, and dumps a list of all sRGB colors therefrom, in hex format.

# USAGE
# Run this script through a Python interpreter, with the image file name as the first parameter to this script. Example:
#    python path/to_this/img2RGBhexList.py input_image.png
# To pipe the output to a file:
#    python path/to_this/img2RGBhexList.py input_image.png > input_image_hex_colors_list.hexplt
# To reduce that to unique colors:
#    sort tmp.hexplt > tmp_garblethax.txt && uniq tmp_garblethax.txt > tmp.hexplt && rm ./tmp_garblethax.txt


# CODE
# ganked from: https://stackoverflow.com/a/19917486/1397555
import sys
from PIL import Image

def rgb2hex(r, g, b):
    return '#{:02x}{:02x}{:02x}'.format(r, g, b)

img = Image.open((sys.argv[1]))

pixels = list(img.convert('RGBA').getdata())

for r, g, b, a in pixels:
	norf = rgb2hex(r, g, b)     # just ignore the alpha channel
	print(norf)