# DESCRIPTION
# Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Right now it is one virtual, undead bacterium which randomly walks and poops mutated colors. A possible future update will manage multiple bacteria. Output file names are random. Inspired and drastically evolved from colorFibers.py, which was horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# USAGE
# Run this script without any paramaters, and it will use a default set of parameters:
# python thisScript.py
# To see available parameters, run this script with the -h switch:
# python thisScript.py -h

# DEPENDENCIES
# python 3 with the various modules installed that you see in the import statements here near the start of this script.

# TO DO:
# - For coordinate mutation, pick from an array of possible mutation states which dwindles (shrink the array of reference states every time a mutation against one of them fails). This avoids redundant failed mutations, and could extremely help efficiency, and has implications for altering use of the -f parameter).
# - Option to save an output frame from every successful mutation (to make an animation from all frames).
# - Option to use a parameter preset (which would be literally just an input file of desired parameters?). Is this a standardized nixy' CLI thing to do?
# - Clamp randomly generated colors that are out of gamut (back into the gamut).
# - Throw an error and exit script when conflicting CLI options are passed (a parameter that overrides another).
# - Have more than one bacterium alive at a time (and have all their colors evolve on creating new bacterium).
# - Initialize mutationColorbase by random selection from a .hexplt color scheme
# - Have optional random new color selection when failedMutationsThreshold is met (coordination mutation fails)?
#  - Do random new color selection from a .hexplt color scheme


# CODE
import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import sys

parser = argparse.ArgumentParser(description='Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Right now it is one virtual, undead bacterium which randomly walks and poops mutated colors. A possible future update will manage multiple bacteria. Output file names are random. Inspired and drastically evolved from colorFibers.py, which was horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numberOfImages', type=int, default=7, help='How many images to generate. Default 7.')
parser.add_argument('-w', '--width', type=int, default=250, help='Width of output image(s). Default 1200.')
parser.add_argument('-t', '--height', type=int, default=125, help='Height of output image(s). Default 600.')
parser.add_argument('-r', '--rshift', type=int, default=2, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut 4. Ripped or torn looking color streaks are more likely toward 6 or higher.')
parser.add_argument('-m', '--mutationColorbase', default='[157, 140, 157]', help='Base initialization color for pixels, which randomly mutates as painting proceeds. Expressed as a python list or single number that will be assigned to every RGB value. If a list, put the parameter in quotes and give the RGB values in the format e.g. \'[255, 70, 70]\' (this example would produce a deep red, as Red = 255, Green = 70, Blue = 70). A single number example like just 150 will result in a medium-light gray of [150, 150, 150] (Red = 150, Green = 150, Blue = 150). All values must be between 0 and 255. Default [157, 140, 157] (a medium-medium light, slightly violet gray).')
parser.add_argument('-c', '--canvasColor', default='[157, 140, 157]', help='Canvas color. If omitted, defaults to whatever mutationColorbase is. If included, may differ from mutationColorbase. This option must be given in the same format as mutationColorbase.')
parser.add_argument('-p', '--percentMutation', type=float, default=0.00248, help='(Alternate for -m) What percent of the canvas would have been covered by failed mutation before it triggers selection of a random new available unplotted coordinate. Percent expressed as a decimal (float) between 0 and 1.')
parser.add_argument('-f', '--failedMutationsThreshold', type=int, help='How many times coordinate mutation must fail to trigger selection of a random new available unplotted coordinate. Overrides -p | --percentMutation if present.')
parser.add_argument('-s', '--stopPaintingPercent', type=float, default=0.65, help='What percent canvas fill to stop painting at. To paint until the canvas is filled (which is infeasible for higher resolutions), pass 1 (for 100 percent) If not 1, value should be a percent expressed as a decimal (float) between 0 and 1.')

args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

numIMGsToMake = args.numberOfImages
rshift = args.rshift
width = args.width
height = args.height
percentMutation = args.percentMutation
failedMutationsThreshold = args.failedMutationsThreshold
stopPaintingPercent = args.stopPaintingPercent
# Interpreting -c (or --mutationColorbase) argument as python literal and assigning that to a variable, re: https://stackoverflow.com/a/1894296/1397555
mutationColorbase = ast.literal_eval(args.mutationColorbase)
canvasColor = ast.literal_eval(args.canvasColor)
purple = [255, 0, 255]	# Purple

allesPixelCount = width * height

# Conditional argument overrides logic.
# If no specific threshold given, calculate it. Otherwise what is given will be used (it will not be altered):
if failedMutationsThreshold == None:
	failedMutationsThreshold = int(allesPixelCount * percentMutation)
terminatePaintingAtFillCount = int(allesPixelCount * stopPaintingPercent)
# If no canvas color given, use mutationColorbase:
if canvasColor == None:
	canvasColor = mutationColorbase

print('Will generate ', numIMGsToMake, ' image(s).')

# Loop making N (-n | numimages) images.
# "Initialize" (paint over entire) the "canvas" with the chosen base canvas color:
for n in range(1, (numIMGsToMake + 1) ):		# + 1 because it iterates n *after* the loop.
	arr = np.ones((height, width, 3)) * canvasColor
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

	totalPixels = width * height

	# function gets random unused coordinate:
	def getRNDunusedCoord():
		unusedCoordsListSize = len(unusedCoords)
		randomIndex = np.random.randint(0, unusedCoordsListSize)
		chosenCoord = unusedCoords[randomIndex]
		return chosenCoord

	# Initialize chosenCoord:
	chosenCoord = getRNDunusedCoord()
	usedCoords = []
	color = mutationColorbase
	previousColor = color
	failedCoordMutationCount = 0
	reportStatsEveryNthLoop = 1800
	reportStatsNthLoopCounter = 0

	# function prints coordinate plotting statistics (progress report):
	def printProgress():
		print('Unused coordinates: ', len(unusedCoords), ' Have plotted ', len(usedCoords), 'of ', terminatePaintingAtFillCount, ' desired coordinates (on a canvas of', totalPixels, ' pixels).')

	# Create unique, date-time informative image file name. Note that this will represent when the painting began, not when it ended (~State filename will be based off this).
	now = datetime.datetime.now()
	timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
	rndStr = ('%03x' % random.randrange(16**3)).lower()
	imgFileBaseName = timeStamp + '-' + rndStr + '-colorGrowth-Py-r' + str(rshift) + '-f' + str(failedMutationsThreshold)
	imgFileName = imgFileBaseName + '.png'
	stateIMGfileName = imgFileBaseName + '-state.png' 

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
			im.save(stateIMGfileName)
			printProgress()
			reportStatsNthLoopCounter = 0
		# This will terminate all coordinate and color mutation at an arbitary number of mutations.
		usedCoordsCount = len(usedCoords)
		if usedCoordsCount == terminatePaintingAtFillCount:
			print('Pixel fill (successful mutation) termination count ', terminatePaintingAtFillCount, ' reached. Ending algorithm and painting.')
			break

	# Save result and delete state image file.
	print('Saving image ', imgFileName, ' . . .')
	im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
	im.save(imgFileName)
	print('Created ', n, ' of ', numIMGsToMake, ' images.')
	os.remove(stateIMGfileName)