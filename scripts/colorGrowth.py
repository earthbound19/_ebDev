# IN DEVELOPMENT. At this writing, one bacterium does a random walk over the entire canvas (petri dish) pooping evolving colors. I'm pretty sure. See TO DO.

# DESCRIPTION
# Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Output file names are random. Original colorFibers.py (of which this is an evolution) horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# USAGE
# python thisScript.py

# DEPENDENCIES
# python 3 with numpy and PIL modules

# TO DO:
# Debug that in fact one bacterium is doing a random walk at this writing, by having it walk half the range of the pixel array and mutate color.
# - Have more than one bacterium alive at a time (and have all their colors evolve on creating new bacterium)
# - Clamp randomly generated colors that are out of gamut (back into the gamut).


# CODE
import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import sys		# Testing only: DELETE THIS LINE or comment out on commit!

parser = argparse.ArgumentParser(description='Renders an image like colored horizontal plasma fibers via python\'s numpy and PIL modules. Output file names are random. Horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numimages', type=int, default=7, help='How many images to generate. Default 7.')
parser.add_argument('-w', '--width', type=int, default=1200, help='Width of output image(s). Default 1200.')
parser.add_argument('-t', '--height', type=int, default=600, help='Height of output image(s). Default 600.')
parser.add_argument('-r', '--rshift', type=int, default=4, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut 4. Ripped or torn looking color streaks are more likely toward 6 or higher.')
parser.add_argument('-c', '--colorbase', default='[157, 140, 157]', help='Base color that the image is initialized with, expressed as a python list or single number that will be assigned to every RGB value. If a list, put the parameter in quotes and give the RGB values in the format e.g. \'[256, 70, 70]\' for a deep red (Red = 256, Green = 70, Blue = 70). If a single number e.g. just 150, it will result in a medium-light gray of [150, 150, 150] where 150 is assigned to every Red, Green and Blue channel in every pixel in the first column of the image. All RGB channel values must be between 0 and 256. Default [157, 140, 157] (a medium-medium light, slightly violet gray). NOTE: unless until the color tearing problem is fixed, you are more likely to get a look of torn dramatically different colors the further away from nuetral gray your base color is.')

args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

numIMGsToMake, rshift, width, height = args.numimages, args.rshift, args.width, args.height
# Interpreting -c (or --colorbase) argument as python literal and assigning that to a variable, re: https://stackoverflow.com/a/1894296/1397555
print('Will generate ', numIMGsToMake, ' image(s).')

colorbase = ast.literal_eval(args.colorbase)
# noir = [0, 0, 0]	# Black

arr = np.ones((height, width, 3)) * colorbase
	# DEBUGGING / REFERENCE:
	# Iterates through every datum in the three-dimensional list (array) :
	# for a, b in enumerate(arr):
	# 	print('- arr[', a, ']:\n', b)		# [ [0. 0. 0.] [0. 0. 0.] . . ]
	# 	for i, j in enumerate(b):
	# 		print('-- arr[', a, '][', i, ']:\n', arr[a][i])		# [0. 0. 0.]
	# 		for x, y in enumerate(j):
	# 			print('--- arr[', a, '][', i, '][', x, ']:\n', y)
	# 			felf = 'nor'

# Function takes two ints and shifts each up or down one or not at all. I know, it doesn't recieve a tuple as input but it gives one as output:
def mutateCoordinate(xCoordParam, yCoordParam):
	xCoord = np.random.randint((xCoordParam - 1), xCoordParam + 2)
	yCoord = np.random.randint((yCoordParam - 1), yCoordParam + 2)
	# if necessary, move results back in range of the array indices this is intended to be used with (zero-based indexing, so maximum (n - 1) and never less than 0) :
	if (xCoord < 0):
		xCoord = 0
	if (xCoord > (width - 1)):
		xCoord = (width - 1)
	if (yCoord < 0):
		yCoord = 0
	if (yCoord > (height - 1)):
		yCoord = (height - 1)
	return [xCoord, yCoord]

unusedCoords = []
for yCoord in range(0, width):
	for xCoord in range(0, height):
		unusedCoords.append([yCoord, xCoord])
usedCoords = []
color = colorbase
previousColor = color

print('Generating image . . .')
while unusedCoords:
	unusedCoordsListSize = len(unusedCoords)
	# print('unusedCoordsListSize: ', unusedCoordsListSize)
	randomIndex = np.random.randint(0, unusedCoordsListSize)
	# print('randomIndex: ', randomIndex)
	chosenCoord = unusedCoords[randomIndex]
	mutatedCoord = mutateCoordinate(chosenCoord[0], chosenCoord[1])
	# print(chosenCoord)
	# print(chosenCoord[0], ',', mutatedCoord[0], ' : ', chosenCoord[1], ',', mutatedCoord[1])
	boolIsInUsedCoords = mutatedCoord in usedCoords
	if not boolIsInUsedCoords:		# If the coordinate is NOT in usedCoords, use it.
		# print('mutatedCoord ', mutatedCoord, ' is NOT in usedCoords. Will use.')
		# print('usedCoords before append: ', usedCoords)
		usedCoords.append(mutatedCoord)
		# print('usedCoords AFTER append: ', usedCoords)
		arrXidx = chosenCoord[0]
		arrYidx = chosenCoord[1]
		newColor = previousColor + np.random.randint(-rshift, rshift+1, size=3) / 2
		arr[arrYidx][arrXidx] = newColor
		previousColor = newColor
		unusedCoords.remove(mutatedCoord)
	# else:		# If the coordinate is NOT NOT used (is used), print a debug message saying so. This else clause should be commented out in the final script (it is for debugging print only)
		# print('mutatedCoord ', mutatedCoord, ' is in usedCoords. Will not re-use.')
		# print('usedCoords: ', usedCoords)

# print('usedCoords array contains: ', usedCoords)
# print('unusedCoords array contains: ', unusedCoords)
# print('painting array is:\n', arr)

# Create unique, date-time informative image file name.
now = datetime.datetime.now()
timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
rndStr = ('%03x' % random.randrange(16**3)).lower()
imgFileName = timeStamp + '-' + rndStr + '-colorGrowth-Py-rshift' + str(rshift) + '.png'

im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
im.save(imgFileName)