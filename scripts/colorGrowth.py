# DESCRIPTION
# Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Or I hope eventually it will. Right now it is actually just one undead bacterium which poops mutated colors. Output file names are random. Original colorFibers.py (of which this is an evolution) horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# USAGE
Run this script without any paramaters, or for CLI options:
# python thisScript.py -h

# DEPENDENCIES
# python 3 with numpy and PIL modules, also other modules you'll see in the import statements here near the start of this script.

# TO DO:
# - Clamp randomly generated colors that are out of gamut (back into the gamut).
# - Have more than one bacterium alive at a time (and have all their colors evolve on creating new bacterium).
# - Have optional random new color selection when mutationFailureThreshold is met (coordination mutation fails)?


# CODE
import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image

# Note that this variable must be a decimal between 0 and 1:
# mutationFailureThresholdAreaPercentDefault = 0.008		# For a 100x50 image, this becomes 40.
mutationFailureThresholdAreaPercentDefault = 0.00248
# mutationFailureThresholdAreaPercentDefault = 0.00008		# For a 1000x500 image, this becomes 40.
# mutationFailureThresholdAreaPercentDefault = 0.00013

parser = argparse.ArgumentParser(description='Renders an image like colored horizontal plasma fibers via python\'s numpy and PIL modules. Output file names are random. Horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numimages', type=int, default=7, help='How many images to generate. Default 7.')
parser.add_argument('-w', '--width', type=int, default=250, help='Width of output image(s). Default 1200.')
parser.add_argument('-t', '--height', type=int, default=125, help='Height of output image(s). Default 600.')
parser.add_argument('-r', '--rshift', type=int, default=2, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut 4. Ripped or torn looking color streaks are more likely toward 6 or higher.')
parser.add_argument('-c', '--colorbase', default='[157, 140, 157]', help='Base color that the image is initialized with, expressed as a python list or single number that will be assigned to every RGB value. If a list, put the parameter in quotes and give the RGB values in the format e.g. \'[255, 70, 70]\' for a deep red (Red = 255, Green = 70, Blue = 70). If a single number e.g. just 150, it will result in a medium-light gray of [150, 150, 150] where 150 is assigned to every Red, Green and Blue channel in every pixel in the first column of the image. All RGB channel values must be between 0 and 255. Default [157, 140, 157] (a medium-medium light, slightly violet gray). NOTE: unless until the color tearing problem is fixed, you are more likely to get a look of torn dramatically different colors the further away from nuetral gray your base color is.')
parser.add_argument('-m', '--mutationFailureThreshold', type=int, default=-1, help='How many times coordinate mutation must fail to trigger selection of a random new available unplotted coordinate. Default value in script is -1, which if the script sees as a value, it will calculate a new value based on the formula: (width * height * int(mutationFailureThresholdAreaPercentDefault) (or, mutationFailureThresholdAreaPercentDefault percent of surface area) (see the declaration of that variable near the top of this script).')

args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

numIMGsToMake, rshift, width, height, mutationFailureThreshold = args.numimages, args.rshift, args.width, args.height, args.mutationFailureThreshold
if mutationFailureThreshold == (-1):
	mutationFailureThreshold = int(width * height * mutationFailureThresholdAreaPercentDefault)
	print('No -m or --mutationFailureThreshold value was passed to the script (was at default -1). That value has been set to int(width * height * ', mutationFailureThresholdAreaPercentDefault, '), or ', mutationFailureThreshold)
# Interpreting -c (or --colorbase) argument as python literal and assigning that to a variable, re: https://stackoverflow.com/a/1894296/1397555

colorbase = ast.literal_eval(args.colorbase)
purple = [255, 0, 255]	# Purple

print('Will generate ', numIMGsToMake, ' image(s).')

for n in range(1, (numIMGsToMake + 1) ):		# + 1 because it iterates n *after* the loop.
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

	# function takes two ints and shifts each up or down one or not at all. I know, it doesn't recieve a tuple as input but it gives one as output:
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

	totalDesiredCoords = width * height

	# function gets random unused coordinate:
	def getRNDunusedCoord():
		unusedCoordsListSize = len(unusedCoords)
		randomIndex = np.random.randint(0, unusedCoordsListSize)
		chosenCoord = unusedCoords[randomIndex]
		return chosenCoord

	# Initialize chosenCoord:
	chosenCoord = getRNDunusedCoord()
	usedCoords = []
	color = colorbase
	previousColor = color
	failedCoordMutationCount = 0
	reportStatsEveryNthLoop = 1800
	reportStatsNthLoopCounter = 0

	# function prints coordinate plotting statistics (progress report):
	def printProgress():
		print('Unused coordinates: ', len(unusedCoords), ' Have plotted ', len(usedCoords), 'of ', totalDesiredCoords, ' desired coordinates.')

	print('Generating image . . .')
	while unusedCoords:
		chosenCoord = mutateCoordinate(chosenCoord[0], chosenCoord[1])
		boolIsInUsedCoords = chosenCoord in usedCoords
		if not boolIsInUsedCoords:		# If the coordinate is NOT in usedCoords, use it.
			# print('chosenCoord ', chosenCoord, ' is NOT in usedCoords. Will use.')
			# print('usedCoords before append: ', usedCoords)
			usedCoords.append(chosenCoord)
			# print('usedCoords AFTER append: ', usedCoords)
			previousCoord = chosenCoord
			arrXidx = chosenCoord[0]
			arrYidx = chosenCoord[1]
			newColor = previousColor + np.random.randint(-rshift, rshift+1, size=3) / 2
			arr[arrYidx][arrXidx] = newColor
			previousColor = newColor
			unusedCoords.remove(chosenCoord)
		else:		# If the coordinate is NOT NOT used (is used), print a progress message. If you have infinite patience and don't want it slowed down by a progress message, comment out this else clause and the next indented lines of code.
			failedCoordMutationCount += 1
			# If coordiante mutation fails mutationFailureThreshold times, get a new random coordinate, and print a message saying so.
			if failedCoordMutationCount == mutationFailureThreshold:
				chosenCoord = getRNDunusedCoord()
				print('Coordinate mutation failure threshold met at ', mutationFailureThreshold, '. New random, unused coordinate selected: ', chosenCoord)
				printProgress()
				failedCoordMutationCount = 0
		# Running progress report:
		reportStatsNthLoopCounter += 1
		if reportStatsNthLoopCounter == reportStatsEveryNthLoop:
			# Save a progress snapshot image.
			print('Saving prograss snapshot image colorGrowthState.png . . .')
			im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
			im.save('colorGrowthState.png')
			printProgress()
			reportStatsNthLoopCounter = 0
		# Optional lines of code that will terminate all coordinate and color mutation at an arbitary number of mutations:
		# terminateMutationsAt = 500
		# debugCount = len(usedCoords)
		# if debugCount == terminateMutationsAt:
		# 	print('Arbitrary mutation termination count reached. Ending algorithm.')
		# 	break

	# print('usedCoords array contains: ', usedCoords)
	# print('unusedCoords array contains: ', unusedCoords)
	# print('painting array is:\n', arr)

	# Create unique, date-time informative image file name.
	now = datetime.datetime.now()
	timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
	rndStr = ('%03x' % random.randrange(16**3)).lower()
	imgFileName = timeStamp + '-' + rndStr + '-colorGrowth-Py-r' + str(rshift) + '-m' + str(mutationFailureThreshold) + '.png'

	print('Saving image ', imgFileName, ' . . .')
	im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
	im.save(imgFileName)
	print('Created ', n, ' of ', numIMGsToMake, ' images.')

