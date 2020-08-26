# DESCRIPTION
# Renders a PNG image like colored horizontal plasma fibers via python's numpy and PIL modules. Output file names are random. Horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# DEPENDENCIES
# python 3 with numpy and PIL modules.

# USAGE
# Run through a Python interpreter without any parameters:
#    python path/to/this/script/color_fibers.py


# CODE
import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image

parser = argparse.ArgumentParser(description='Renders an image like colored horizontal plasma fibers via python\'s numpy and PIL modules. Output file names are random. Horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numimages', type=int, default=7, help='How many images to generate. Default 7.')
parser.add_argument('-w', '--width', type=int, default=1200, help='Width of output image(s). Default 1200.')
parser.add_argument('-t', '--height', type=int, default=600, help='Height of output image(s). Default 600.')
parser.add_argument('-r', '--rshift', type=int, default=4, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut 4. Ripped or torn looking color streaks are more likely toward 6 or higher.')
parser.add_argument('-c', '--colorbase', default='[157, 140, 157]', help='Base color that the image is initialized with, expressed as a python list or single number that will be assigned to every RGB value. If a list, put the parameter in quotes and give the RGB values in the format e.g. \'[256, 70, 70]\' for a deep red (Red = 256, Green = 70, Blue = 70). If a single number e.g. just 150, it will result in a medium-light gray of [150, 150, 150] where 150 is assigned to every Red, Green and Blue channel in every pixel in the first column of the image. All RGB channel values must be between 0 and 256. Default [157, 140, 157] (a medium-medium light, slightly violet gray). NOTE: unless until the color tearing problem is fixed, you are more likely to get a look of torn dramatically different colors the further away from neutral gray your base color is.')

args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

numIMGsToMake, rshift, width, height = args.numimages, args.rshift, args.width, args.height
# Interpreting -c (or --colorbase) argument as python literal and assigning that to a variable, re: https://stackoverflow.com/a/1894296/1397555
colorbase = ast.literal_eval(args.colorbase)

print('Will generate ', numIMGsToMake, ' image(s).')

i = 0
while i < numIMGsToMake:
	i += 1
	print('Generating image ', i, ' of ', numIMGsToMake, ' . . .')
	# Create unique, date-time informative image file name.
	now = datetime.datetime.now()
	timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
	rndStr = ('%03x' % random.randrange(16**3)).lower()
	imgFileName = timeStamp + '-' + rndStr + '-colorFibersPy-rshift' + str(rshift) + '.png'
	
	# (re)initialize arr
	arr = np.ones((height, width, 3)) * colorbase

	for y in range(1, height):	# Algo. step 1 (see comments at bottom of script)
		arr[y, 0] = arr[y-1, 0] + np.random.randint(-rshift, rshift+1, size=3)

	for x in range(1, width):	# Algo. step 2
		for y in range(1, height-1):	# Algo. step 3
			arr[y, x] =	(arr[y-1, x-1] + arr[y, x-1] + arr[y+1, x-1]) / 3 + np.random.randint(-rshift, rshift+1, size=3)
			
	im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
	im.save(imgFileName)
	print('Generated and saved image ', imgFileName)


# IMAGE GENERATION ALGORITHM description in steps:
# 1. For the first pixel (column) on every row, randomly shift the RGB in the range negative rshift to positive rshift:
# 2. For every column (except the first),
# 3. On every row in that column, perform the following operation: give the pixel the value from the operation: (one row up, one col left + this row, one col left + next row, one col left) / 3 . . (That means: average of R, G, and B per channel one pixel up, this pixel, and one pixel down), ? plus . . . ?