# DESCRIPTION
# Extract N (parameter 2) colors from an image (parameter 1), via Python colorgram library, and print them as RGB values.

# USAGE
# Run this script through a python interpreter with these parameters:
# - sys.argv[1] file name of an image to get colors for.
# - sys.argv[2] number of colors to sample
# For example, if the source image is named source.png, and you want to extract 23 colors, run:
#    python full/path_to_this_script/get_colors_colorgram.py darks-v2.png 23
# To pipe the results to a text file, add a > redirect operator and text file to the end of that command, like this:
#    python full/path_to_this_script/get_colors_colorgram.py darks-v2.png 23 > darks-v2.rgbplt
# NOTES
# - For whatever reason, it seems that it maxes out at producing 23 colors. It didn't give me 199 colors from a color grid image with exactly that many colors in it when I tried. So it won't work for grids of a lot of colors. However, it will work for many kinds of images you want to get a color palette from.


# CODE
import colorgram, sys, ast
source_image = sys.argv[1]
how_many = ast.literal_eval(sys.argv[2])

colors = colorgram.extract(source_image, how_many)

for element in colors:
	RGB = element.RGB
	print(RGB[0], RGB[1], RGB[2])