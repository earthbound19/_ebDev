# DESCRIPTION
# Extract colors from an image (parameter 1), over a
# regular grid of pixel samples taken from the center of a virtual
# cell division (columns and rows) structure, and print them as RGB
# values in hexadecimal format.

# USAGE
# Invoke the script with the source image to sample as parameter 1,
# number of columns to divide the image into for sampling as paramter 2,
# and number of rows to divide the image into for sampling as parameter 3.
# For example, if the source image is named darks-v2.png, and you want it to
# sample from the center each cell in a grid 16 across (16 columns) and 12 down
# (12 rows), run:
# python full/path_to_this_script/darks-v2 16 12
# To pipe the results to a text file, add a > redirect operator and text
# file to the end of that command, like this:
# > darks-v2.hexplt

import colorgram, sys, ast
from PIL import Image
import numpy as np
np.set_printoptions(threshold=np.inf)

source_image = sys.argv[1]
columns = ast.literal_eval(sys.argv[2])
rows = ast.literal_eval(sys.argv[3])

# Loads and converts images more efficiently,
# re: https://stackoverflow.com/a/42036542
with Image.open(source_image) as image:         
	im_arr = np.frombuffer(image.tobytes(), dtype=np.uint8)
	im_arr = im_arr.reshape((image.size[1], image.size[0], 3))
	# That's height (image.size[1]), width (image.size[0])

img_width = len(im_arr[0]) - 1		# - 1 because will be used in zero-based index iteration
img_height = len(im_arr) - 1		#	^
column_pix_width = int(img_width / columns) - 1
row_pix_height = int(img_height / rows) - 1
column_pix_width_offset = int(column_pix_width / 2)
row_pix_height_offset = int(row_pix_height / 2)

# find and print all desired samples:
for row in range(rows):
	for column in range(columns):
		Y = ((row_pix_height * row) + row_pix_height_offset)
		X = ((column_pix_width * column) + column_pix_width_offset)
		# extract and assign RGB values:
		RGB_vals = im_arr[Y][X]
		# convert to hex and print:
		hex_code = '#%02x%02x%02x' % (RGB_vals[0], RGB_vals[1], RGB_vals[2])
		hex_code = hex_code.upper()
		print(hex_code)