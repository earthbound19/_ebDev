# DESCRIPTION
# Extract N (parameter 2) colors from an image (parameter 1), via Python
# colorgram library, and print them as RGB values.

# USAGE
# Invoke the script with the source image to sample as parameter 1,
# and number of colors to sample as parameter 2. For example, if
# the source image is named source.png, and you want to extract 23 colors, run:
# python full/path_to_this_script/get_colors_colorgram.py darks-v2.png 23
# To pipe the results to a text file, add a > redirect operator and text
# file to the end of that command, like this:
# > darks-v2.rgbplt
# NOTE: either the algorithm clamps or approximates colors it thinks are
# very near, or it is hard-coded to max out at 24, maybe. It didn't give me
# 199 images from a color grid image with exactly that many colors in it
# when I tried. So it won't work for grids of a lot of colors. It will work
# for many kinds of images you want to get a color palette from though.

import colorgram, sys, ast
source_image = sys.argv[1]
how_many = ast.literal_eval(sys.argv[2])

colors = colorgram.extract(source_image, how_many)

for element in colors:
	rgb = element.rgb
	print(rgb[0], rgb[1], rgb[2])