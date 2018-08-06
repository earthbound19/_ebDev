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
# - Throw an error and exit script when conflicting CLI options are passed (a parameter that overrides another).
# - Option to use a parameter preset (which would be literally just an input file of desired parameters?). Is this a standardized nixy' CLI thing to do?
# - Initialize colorMutationBase by random selection from a .hexplt color scheme
# - Coordinate mutation: optionally revert to coordinate before last known successful mutation on coordinate mutation fail (instead of continuing random walk). This would still need the failsafe of failedMutationsThreshold.
# - Color mutation option: on coordinate mutation fail, select random new color (including from a .hexplt color scheme). If this and -d are present, -d wins.
# - Have more than one bacterium alive at a time (and have all their colors evolve on creating new bacterium).
# - Major new feature? : Initialize arr[] from an image, pick a random coordinate from the image, and use the color at that coordinate both as the origin coordinate and the color at that coordinate as colorMutationBase. Could also be used to continue terminated runs with the same or different parameters.


# CODE
import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import colorpoop as cp		# Uses my custom class in colorpoop.py
# import sys

parser = argparse.ArgumentParser(description='Renders a PNG image like bacteria that produce random color mutations as they grow over a surface. Right now it is one virtual, undead bacterium. A planned update will host multiple virtual bacteria. Output file names are after the date plus random characters. Inspired by and drastically evolved from colorFibers.py, which was horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numberOfImages', type=int, default=7, help='How many images to generate. Default 7.')
parser.add_argument('-w', '--width', type=int, default=1200, help='Width of output image(s). Default 1200.')
parser.add_argument('-t', '--height', type=int, default=400, help='Height of output image(s). Default 400.')
parser.add_argument('-r', '--rshift', type=int, default=2, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut 2. Ripped or torn looking color streaks are more likely toward 6 or higher. Default 2.')
parser.add_argument('-b', '--backgroundColor', default='[157, 140, 157]', help='Canvas color. Expressed as a python list or single number that will be assigned to every value in an RGB triplet. If a list, give the RGB values in the format \'[255,70,70]\' (if you add spaces after the commas, you must surround the parameter in single or double quotes). This example would produce a deep red, as Red = 255, Green = 70, Blue = 70). A single number example like just 150 will result in a medium-light gray of [150, 150, 150] (Red = 150, Green = 150, Blue = 150). All values must be between 0 and 255. Default [157, 140, 157] (a medium-medium light, slightly violet gray).')
parser.add_argument('-c', '--colorMutationBase', help='Base initialization color for pixels, which randomly mutates as painting proceeds. If omitted, defaults to whatever backgroundColor is. If included, may differ from backgroundColor. This option must be given in the same format as backgroundColor.')
parser.add_argument('-p', '--percentMutation', type=float, default=0.02, help='(Alternate for -m) What percent of the canvas would have been covered by failed mutation before it triggers selection of a random new available unplotted coordinate. Percent expressed as a decimal (float) between 0 and 1. Default 0.043 (about 4 percent).')
parser.add_argument('-f', '--failedMutationsThreshold', type=int, help='How many times coordinate mutation must fail to trigger selection of a random new available unplotted coordinate. Overrides -p | --percentMutation if present.')
parser.add_argument('-d', '--revertColorOnMutationFail', type=int, default=1, help='If (-f | --failedMutationsThreshold) is reached, revert color to color mutation base (-c | --colorMutationBase). Default 1 (true). If you use this at all you want to change the default 1 (true) by passing 0 (false). If false, color will change more in the painting. If true, color will only evolve as much as coordinates successfully evolve.')
parser.add_argument('-s', '--stopPaintingPercent', type=float, default=0.475, help='What percent canvas fill to stop painting at. To paint until the canvas is filled (which is infeasible for higher resolutions), pass 1 (for 100 percent) If not 1, value should be a percent expressed as a decimal (float) between 0 and 1. Default 0.475 (about 48 percent).')
parser.add_argument('-a', '--animationSaveEveryNframes', type=int, help='Every N successful coordinate and color mutations, save an animation frame into a subfolder named after the intended final art file. To save every frame, set this to 1, or to save every 3rd frame set it to 3, etc. Saves zero-padded numbered frames to a subfolder which may be strung together into an animation of the entire painting process (for example via ffmpegAnim.sh). May substantially slow down render, and can also create many, many gigabytes of data, depending. Off by default. To switch it on, use it (with a number).')

args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

numIMGsToMake = args.numberOfImages
rshift = args.rshift
width = args.width
height = args.height
percentMutation = args.percentMutation
failedMutationsThreshold = args.failedMutationsThreshold
revertColorOnMutationFail = args.revertColorOnMutationFail
stopPaintingPercent = args.stopPaintingPercent
animationSaveEveryNframes = args.animationSaveEveryNframes
# Interpreting -c (or --colorMutationBase) argument as python literal and assigning that to a variable, re: https://stackoverflow.com/a/1894296/1397555
backgroundColor = ast.literal_eval(args.backgroundColor)
colorMutationBase = args.colorMutationBase
# If no color mutation base given, use backgroundColor; if given, reinitialize colorMutationBase as a list from it:
if colorMutationBase == None:
	colorMutationBase = backgroundColor
else:
	colorMutationBase = ast.literal_eval(args.colorMutationBase)
# purple = [255, 0, 255]	# Purple. In prior commits of this script, this has been defined and unused, just like in real life. Now, it is commented out or not even defined, just like it is in real life.
allesPixelCount = width * height
# If no specific threshold given, calculate it. Otherwise what is given will be used (it will not be altered):
if failedMutationsThreshold == None:
	failedMutationsThreshold = int(allesPixelCount * percentMutation)
terminatePaintingAtFillCount = int(allesPixelCount * stopPaintingPercent)

print('Will generate ', numIMGsToMake, ' image(s).')

# Loop making N (-n | numimages) images.
# "Initialize" (paint over entire) the "canvas" with the chosen base canvas color:
for n in range(1, (numIMGsToMake + 1) ):		# + 1 because it iterates n *after* the loop.
	animationSaveNFramesCounter = 0
	animationFrameCounter = 0

	arr = []	# list of Coordinate objects
	for xCoord in range(0, width):
		for yCoord in range(0, height):	# RGBcolor can also be initialized with: np.random.randint(0, 255, size=3)
			arr.append(cp.coordinate(xCoord, yCoord, width, height, np.random.randint(0, 255, size=3), False, False, None))

	unusedCoords = []		# list of tuples of unused coordinates
	for coord in arr:
		unusedCoords.append( (coord.x, coord.y) )
# TO DO: fix the places that are using y, x to use x, y?

	# function takes two ints and shifts each up or down one or not at all. I know, it doesn't receive a tuple as input but it gives one as output:
# TO DO: use the following repeatedly only if Coordinate.getRNDemptyNeighbors() fails:
	def mutateCoordinate(xCoordParam, yCoordParam):
		xCoord = np.random.random_integers((xCoordParam - 1), xCoordParam + 1)
		yCoord = np.random.random_integers((yCoordParam - 1), yCoordParam + 1)
		# if necessary, move results back in range of the array indices this is intended to be used with (zero-based indexing, so maximum (n - 1) and never less than 0) :
		if (xCoord < 0):
			xCoord = 0
		if (xCoord > (width - 1)):
			xCoord = (width - 1)
		if (yCoord < 0):
			yCoord = 0
		if (yCoord > (height - 1)):
			yCoord = (height - 1)
		return (xCoord, yCoord)

	totalPixels = width * height

	# function gets random unused coordinate:
	def getRNDunusedCoord():
		unusedCoordsListSize = len(unusedCoords)
		randomIndex = np.random.random_integers(0, unusedCoordsListSize-1)
		chosenCoord = unusedCoords[randomIndex]
		return chosenCoord

	# Initialize chosenCoord:
	chosenCoord = getRNDunusedCoord()
	usedCoords = []
	color = colorMutationBase
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
	rndStr = ('%03x' % random.randrange(16**3))		# Returns three random lowercase hex characters. Wherever I horked that from originally appended .lower() to it, pointless because it already returns lowercase characters.
	imgFileBaseName = timeStamp + '-' + rndStr + '-colorGrowth-Py-r' + str(rshift) + '-f' + str(failedMutationsThreshold)
	imgFileName = imgFileBaseName + '.png'
	stateIMGfileName = imgFileBaseName + '-state.png'
	animFramesFolderName = imgFileBaseName + '_frames'

	if animationSaveEveryNframes:	# If that has a value that isn't None, create a subfolder to write frames to:
		# Also, initailize a varialbe which is how many zeros to pad animation save frame file (numbers) to, based on how many frames will be rendered:
		padAnimationSaveFramesNumbersTo = len(str(terminatePaintingAtFillCount))
		os.mkdir(animFramesFolderName)

	print('Generating image . . .')
	while unusedCoords:
		chosenCoord = mutateCoordinate(chosenCoord[0], chosenCoord[1])
		boolIsInUsedCoords = chosenCoord in usedCoords
		if not boolIsInUsedCoords:		# If the coordinate is NOT in usedCoords, use it (whether or not it is, the coordinate is still mutated; this loop keeps mutating the coordinate (and pooping colors on newly arrived at unused coordinates) until terminate conditions are met).
			# print('chosenCoord ', chosenCoord, ' is NOT in usedCoords. Will use.')
			usedCoords.append(chosenCoord)
			previousCoord = chosenCoord
			arrXidx = chosenCoord[0]
			arrYidx = chosenCoord[1]
			newColor = previousColor + np.random.random_integers(-rshift, rshift, size=3) / 2
			# Clip that within RGB range if it wandered outside of that range. If this slows it down too much and you don't care if colors randomly freak out (bitmap conversion seems to take colors outside range as wrapping around?) comment the next line out:
			newColor = np.clip(newColor, 0, 255)
			arr[arrYidx][arrXidx] = newColor
			previousColor = newColor
			unusedCoords.remove(chosenCoord)
			# Also, if a parameter was passed saying to do so, save an animation frame (if we are at the Nth (-a) mutation:
			if animationSaveEveryNframes:
				if (animationSaveNFramesCounter % animationSaveEveryNframes) == 0:
					strOfThat = str(animationFrameCounter)
					frameFilePathAndFileName = animFramesFolderName + '/' + strOfThat.zfill(padAnimationSaveFramesNumbersTo) + '.png'
					im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
					im.save(frameFilePathAndFileName)
					animationFrameCounter += 1		# Increment that *after* because by default ffmpeg expects frame count to start at 0.
				animationSaveNFramesCounter += 1

		else:		# If the coordinate is NOT NOT used (is used), print a progress message.
			failedCoordMutationCount += 1
			# If coordiante mutation fails failedMutationsThreshold times, get a new random coordinate, and print a message saying so.
			if failedCoordMutationCount == failedMutationsThreshold:
				chosenCoord = getRNDunusedCoord()
				print('Coordinate mutation failure threshold met at ', failedMutationsThreshold, '. New random, unused coordinate selected: ', chosenCoord)
				printProgress()
				failedCoordMutationCount = 0
				# if a switch was passed saying to revert or randomise the color mutation base when we reach revertColorOnMutationFail, do so (actually, change the "previous color" to the mutation color base, and the next color mutation will be off that) :
				if revertColorOnMutationFail == 1:
					previousColor = colorMutationBase
		# Running progress report:
		reportStatsNthLoopCounter += 1
		if reportStatsNthLoopCounter == reportStatsEveryNthLoop:
			# Save a progress snapshot image.
			print('Saving prograss snapshot image ', stateIMGfileName, ' . . .')
			im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
			im.save(stateIMGfileName)
			printProgress()
			reportStatsNthLoopCounter = 0
		# This will terminate all coordinate and color mutation at an arbitary number of mutations.
		usedCoordsCount = len(usedCoords)
		if usedCoordsCount == terminatePaintingAtFillCount:
			print('Pixel fill (successful mutation) termination count ', terminatePaintingAtFillCount, ' reached. Ending algorithm and painting.')
			break

	# Save final image file and delete progress (state, temp) image file.
	print('Saving image ', imgFileName, ' . . .')
	im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
	im.save(imgFileName)
	print('Created ', n, ' of ', numIMGsToMake, ' images.')
	os.remove(stateIMGfileName)
	
	
# Deprecated scraps from prior version of script:
# arr = np.ones((height, width, 3)) * backgroundColor
	# DEBUGGING / REFERENCE:
	# Iterates through every datum in the three-dimensional list (array) :
	# for a, b in enumerate(arr):
	# 	print('- arr[', a, ']:\n', b)		# [ [0. 0. 0.] [0. 0. 0.] . . ]
	# 	for i, j in enumerate(b):
	# 		print('-- arr[', a, '][', i, ']:\n', arr[a][i])		# [0. 0. 0.]
	# 		for x, y in enumerate(j):
	# 			print('--- arr[', a, '][', i, '][', x, ']:\n', y)
	# 			felf = 'nor'