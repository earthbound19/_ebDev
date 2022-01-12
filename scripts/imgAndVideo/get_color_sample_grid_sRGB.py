# DESCRIPTION
# Extracts color samples from an image (parameter 1), divided into a grid of columns and rows, with each color sample taken from the color of each cell in the grid. Prints the samples as RGB values in hexadecimal format.

# DEPENDENCIES
# python PIL and numpy libraries

# USAGE
# Run this script through a Python interpreter, with these parameters:
# - sys.argv[1] source image to sample
# - sys.argv[2] number of columns to divide the image into cells for samples
# - sys.argv[3] number of rows to divide the image into cells for samples
# - sys.argv[4] CONDITIONALLY OPTIONAL. Override X percent offset to sample from left edge of each cell. For example to offset the sample by twelve percent from the left edge, pass 0.12 here as argument 4. If omitted, defaults to 0.5 (center from left edge of cell). May be a value between 0 (no offset from left edge of cell) and 1 (at right edge of cell) inclusive. If you pass something for sys.argv[5] (read on), you must logically pass something also for this.
# - sys.argv[5] OPTIONAL. Override Y percent offset to sample from top edge of each cell. For example to offset the sample by ten percent from the top edge of each cell, pass 0.1 here as argument 5. If omitted, defaults to 0.5 (center from top edge of cell). May be a value between 0 (no offset from top edge of cell) and 1 (at bottom edge of cell) inclusive.
# For example, if the source image is named darks-v2.png, and you want to sample from the center of each cell in a grid 16 across (16 columns) and 12 down (12 rows), run:
#    python full/path_to_this_script/get_color_sample_grid_sRGB.py darks-v2.png 16 12
# To pipe the results to a text file, add a > redirect operator and text file to the end of that command, like this:
#    python full/path_to_this_script/get_color_sample_grid_sRGB.py darks-v2.png 16 12 > darks-v2.hexplt


# CODE
import sys, ast
from PIL import Image
import numpy as np
np.set_printoptions(threshold=np.inf)

# Parameter checking:
if len(sys.argv) > 1:
	source_image = sys.argv[1]
else:
	print('\nNo parameter 1 (source image file name) passed to script. Exit.')
	sys.exit(1)
if len(sys.argv) > 2:
	columns = ast.literal_eval(sys.argv[2])
else:
	print('\nNo parameter 2 (number of columns to sample from) passed to script. Exit.')
	sys.exit(2)
if len(sys.argv) > 3:
	rows = ast.literal_eval(sys.argv[3])
else:
	print('\nNo parameter 3 (number of rows to sample from) passed to script. Exit.')
	sys.exit(3)
# set default value; override if instructed by script parameter:
x_percent_cell_sample_offset = 0.5
if len(sys.argv) > 4:
    x_percent_cell_sample_offset = ast.literal_eval(sys.argv[4])
# set another default value; override if instructed by script parameter:
y_percent_cell_sample_offset = 0.5
if len(sys.argv) > 5:
    y_percent_cell_sample_offset = ast.literal_eval(sys.argv[5])
# Loads and converts images more efficiently,
# re: https://stackoverflow.com/a/42036542
with Image.open(source_image) as image:
	image = image.convert("RGB")
	im_arr = np.frombuffer(image.tobytes(), dtype=np.uint8)
	im_arr = im_arr.reshape((image.size[1], image.size[0], 3))
	# That's height (image.size[1]), width (image.size[0])

img_width = len(im_arr[0])
img_height = len(im_arr)
column_pix_width = int(img_width / columns) - 1
row_pix_height = int(img_height / rows) - 1
# if x_percent_cell_sample_offset is zero (0), this will result in zero offset, which is okay; 1 * 1 is also okay:
x_sample_offset = int(column_pix_width * x_percent_cell_sample_offset)
y_sample_offset = int(row_pix_height * y_percent_cell_sample_offset)
# find and print all desired samples:
counter = 0
# prints colors on grid shaped after sampled columns and rows:
for row in range(rows):
	counter += 1
	for column in range(columns):
		Y = ((row_pix_height * row) + y_sample_offset)
		X = ((column_pix_width * column) + x_sample_offset)
		# print('X,Y', X, Y)
		# extract and assign RGB values:
		RGB_vals = im_arr[Y][X]
		# convert to hex and print:
		hex_code = '#%02x%02x%02x' % (RGB_vals[0], RGB_vals[1], RGB_vals[2])
		print(hex_code + ' ', end = '')
	if counter == 1:
		print(' columns: ' + str(columns), end = '')
		print(' rows: ' + str(rows), end = '')
	print('\n', end = '')