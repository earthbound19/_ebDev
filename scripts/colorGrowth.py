# DESCRIPTION
# Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Or I hope eventually it will. Right now it is actually just one undead bacterium which poops mutated colors. Output file names are random. Original colorFibers.py (of which this is an evolution) horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# USAGE
# Run this script without any paramaters, or for CLI options:
# python thisScript.py -h

# DEPENDENCIES
# python 3 with numpy and PIL modules, also other modules you'll see in the import statements here near the start of this script.

# TO DO:
# - Option to save an output frame from every successful mutation (to make an animation from all frames).
# - Option to use a parameter preset (which would be literally just an input file of desired parameters?). Is this a standardized nixy' CLI thing to do?
# - Clamp randomly generated colors that are out of gamut (back into the gamut).
# - Throw an error and exit script when conflicting CLI options are passed (a parameter that overrides another).
# - Have more than one bacterium alive at a time (and have all their colors evolve on creating new bacterium).
# - Have optional random new color selection when failedMutationsThreshold is met (coordination mutation fails)?


# CODE
import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image

parser = argparse.ArgumentParser(description='Renders an image like colored horizontal plasma fibers via python\'s numpy and PIL modules. Output file names are random. Horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numimages', type=int, default=7, help='How many images to generate. Default 7.')
parser.add_argument('-w', '--width', type=int, default=250, help='Width of output image(s). Default 1200.')
parser.add_argument('-t', '--height', type=int, default=125, help='Height of output image(s). Default 600.')
parser.add_argument('-r', '--rshift', type=int, default=2, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut 4. Ripped or torn looking color streaks are more likely toward 6 or higher.')
parser.add_argument('-c', '--colorbase', default='[157, 140, 157]', help='Base color that the image is initialized with, expressed as a python list or single number that will be assigned to every RGB value. If a list, put the parameter in quotes and give the RGB values in the format e.g. \'[255, 70, 70]\' for a deep red (Red = 255, Green = 70, Blue = 70). If a single number e.g. just 150, it will result in a medium-light gray of [150, 150, 150] where 150 is assigned to every Red, Green and Blue channel in every pixel in the first column of the image. All RGB channel values must be between 0 and 255. Default [157, 140, 157] (a medium-medium light, slightly violet gray). NOTE: unless until the color tearing problem is fixed, you are more likely to get a look of torn dramatically different colors the further away from nuetral gray your base color is.')
parser.add_argument('-p', '--percentMutation', type=float, default=0.00248, help='(Alternate for -m) What percent of the canvas would have been covered by failed mutation before it triggers selection of a random new available unplotted coordinate. Percent expressed as a decimal (float) between 0 and 1.')
parser.add_argument('-f', '--failedMutationsThreshold', type=int, help='How many times coordinate mutation must fail to trigger selection of a random new available unplotted coordinate. Overrides -p | --percentMutation if present.')
parser.add_argument('-s', '--stopPaintingPercent', type=float, default=0.65, help='What percent canvas fill to stop painting at. To paint until the canvas is filled (which is infeasible for higher resolutions, pass 1. If not 1, value should be a percent expressed as a decimal (float) between 0 and 1.')

args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

numIMGsToMake = args.numimages
rshift = args.rshift
width = args.width
height = args.height
percentMutation = args.percentMutation
failedMutationsThreshold = args.failedMutationsThreshold
stopPaintingPercent = args.stopPaintingPercent
# Interpreting -c (or --colorbase) argument as python literal and assigning that to a variable, re: https://stackoverflow.com/a/1894296/1397555
colorbase = ast.literal_eval(args.colorbase)
purple = [255, 0, 255]	# Purple

allesPixelCount = width * height

# Conditional argument overrides logic.
# If no specific threshold given, calculate it. Otherwise what is given will be used (it will not be altered):
if failedMutationsThreshold == None:
	failedMutationsThreshold = int(allesPixelCount * percentMutation)
terminatePaintingAtFillCount = int(allesPixelCount * stopPaintingPercent)

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
			# If coordiante mutation fails failedMutationsThreshold times, get a new random coordinate, and print a message saying so.
			if failedCoordMutationCount == failedMutationsThreshold:
				chosenCoord = getRNDunusedCoord()
				print('Coordinate mutation failure threshold met at ', failedMutationsThreshold, '. New random, unused coordinate selected: ', chosenCoord)
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
		# This will terminate all coordinate and color mutation at an arbitary number of mutations.
		usedCoordsCount = len(usedCoords)
		if usedCoordsCount == terminatePaintingAtFillCount:
			print('Pixel fill (successful mutation) termination count ', terminatePaintingAtFillCount, ' reached. Ending algorithm and painting.')
			break

	# print('usedCoords array contains: ', usedCoords)
	# print('unusedCoords array contains: ', unusedCoords)
	# print('painting array is:\n', arr)

	# Create unique, date-time informative image file name.
	now = datetime.datetime.now()
	timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
	rndStr = ('%03x' % random.randrange(16**3)).lower()
	imgFileName = timeStamp + '-' + rndStr + '-colorGrowth-Py-r' + str(rshift) + '-m' + str(failedMutationsThreshold) + '.png'

	print('Saving image ', imgFileName, ' . . .')
	im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
	im.save(imgFileName)
	print('Created ', n, ' of ', numIMGsToMake, ' images.')

