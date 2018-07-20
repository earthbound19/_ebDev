# DEV SNAPSHOT of colorGrowth.py in working state (which randomly selects and fills pixels with a series of mutating colors; the next thing to do is a random pixel walk instead of random selection series)

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
colorbase = ast.literal_eval(args.colorbase)

print('Will generate ', numIMGsToMake, ' image(s).')

print('Initializing uniform color canvas array . . .')
arr = np.ones((height, width, 3)) * colorbase

# Function takes two ints and shifts each up or down one or not at all.
def mutateCoordinate(xCoordParam, yCoordParam):
	xCoord = np.random.randint((xCoordParam - 1), xCoordParam + 2)
	yCoord = np.random.randint((yCoordParam - 1), yCoordParam + 2)
	# if necessary, move results back in range:
	if (yCoord < 0):
		yCoord = 0
	if (yCoord > (width - 1)):
		yCoord = (width - 1)
	if (xCoord < 0):
		xCoord = 0
	if (xCoord > (height - 1)):
		xCoord = (height - 1)
	return xCoord, yCoord

unusedCoords = []
for yCoord in range(0, width):
	for xCoord in range(0, height):
		unusedCoords.append([yCoord, xCoord])

# print('unusedCoords: \n', unusedCoords)
# sys.exit()

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
	# mutatedCoord = mutateCoordinate(chosenCoord[0], chosenCoord[1])
	print(chosenCoord)
	# print(chosenCoord, ' : ', mutatedCoord)
	unusedCoords.pop()		# DEBUG ONLY--comment out this line in production (not part of algorithm)!
	# print(chosenCoord, ' (', chosenCoord[0], ', ', chosenCoord[1], ') : ', mutatedCoord)
	# boolIsInUsedCoords = mutatedCoord in usedCoords
	# if boolIsInUsedCoords:
		# print('mutatedCoord ', mutatedCoord, ' is in usedCoords. Will not re-use.')
		# print('usedCoords: ', usedCoords)
		# Do nothing; this loop will start over and look for another suitable mutated coordinate.
	# else:
		# print('mutatedCoord ', mutatedCoord, ' is NOT in usedCoords. Will use.')
		# print('usedCoords: ', usedCoords)
		# print('usedCoords before append: ', usedCoords)
		# usedCoords.append(mutatedCoord)
		# print('usedCoords AFTER append: ', usedCoords)
		# arrXidx = chosenCoord[0]
		# arrYidx = chosenCoord[1]
		# newColor = previousColor + np.random.randint(-rshift, rshift+1, size=3) / 2
		# arr[arrYidx][arrXidx] = newColor
		# previousColor = newColor
		# unusedCoords.remove(mutatedCoord)
		# WHY DOES THAT BREAK if I remove mutatedCoord from that?

# print('usedCoords array contains: ', usedCoords)
# print('unusedCoords array contains: ', unusedCoords)

now = datetime.datetime.now()
timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
rndStr = ('%03x' % random.randrange(16**3)).lower()
imgFileName = timeStamp + '-' + rndStr + '-colorGrowth-Py-rshift' + str(rshift) + '.png'

# Oddly, the terminal may hang (on Windows only) unless we pad the following operations with print statements:
print('saving image ', imgFileName, ' . . .')
im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
im.save(imgFileName)
print('done.')