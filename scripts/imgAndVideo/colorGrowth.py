# DESCRIPTION
# Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Output file names are based on the date and add random characters. Inspired and drastically evolved from colorFibers.py, which was horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# USAGE
# Run this script without any paramaters, and it will use a default set of parameters:
# python thisScript.py
# To see available parameters, run this script with the -h switch:
# python thisScript.py -h

# DEPENDENCIES
# python 3 with the various modules installed that you see in the import statements here near the start of this script.

# TO DO:
# - Things listed in development code with TO DO comments
# - Option to suppress progress print to save time
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
import sys

# START OPTIONS AND GLOBALS
parser = argparse.ArgumentParser(description='Renders a PNG image like bacteria that produce random color mutations as they grow over a surface. Right now it is one virtual, undead bacterium. A planned update will host multiple virtual bacteria. Output file names are after the date plus random characters. Inspired by and drastically evolved from colorFibers.py, which was horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numberOfImages', type=int, default=7, help='How many images to generate. Default 7.')
parser.add_argument('-w', '--width', type=int, default=1200, help='Width of output image(s). Default 1200.')
parser.add_argument('-t', '--height', type=int, default=400, help='Height of output image(s). Default 400.')
parser.add_argument('-r', '--rshift', type=int, default=2, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut 2. Ripped or torn looking color streaks are more likely toward 6 or higher. Default 2.')
parser.add_argument('-b', '--backgroundColor', default='[157, 140, 157]', help='Canvas color. Expressed as a python list or single number that will be assigned to every value in an RGB triplet. If a list, give the RGB values in the format \'[255,70,70]\' (if you add spaces after the commas, you must surround the parameter in single or double quotes). This example would produce a deep red, as Red = 255, Green = 70, Blue = 70). A single number example like just 150 will result in a medium-light gray of [150, 150, 150] (Red = 150, Green = 150, Blue = 150). All values must be between 0 and 255. Default [157, 140, 157] (a medium-medium light, slightly violet gray).')
parser.add_argument('-c', '--colorMutationBase', help='Base initialization color for pixels, which randomly mutates as painting proceeds. If omitted, defaults to whatever backgroundColor is. If included, may differ from backgroundColor. This option must be given in the same format as backgroundColor.')
# NOTES: at this writing (with sucessful coordinates growth instead of only one coordinate wandering), the following will virtually never be needed; they may be needed again if I add random coordinate death (fail to continue growing at all) :
# TO DO? : UNCOMMENT and reintegrate associated code:
# parser.add_argument('-p', '--percentMutation', type=float, default=0.02, help='(Alternate for -m) What percent of the canvas would have been covered by failed mutation before it triggers selection of a random new available unplotted coordinate. Percent expressed as a decimal (float) between 0 and 1. Default 0.043 (about 4 percent).')
# TO DO? : UNCOMMENT and reintegrate associated code:
# parser.add_argument('-f', '--failedMutationsThreshold', type=int, help='How many times coordinate mutation must fail to trigger selection of a random new available unplotted coordinate. Overrides -p | --percentMutation if present.')
# TO DO? : UNCOMMENT and reintegrate associated code:
# parser.add_argument('-d', '--revertColorOnMutationFail', type=int, default=1, help='If (-f | --failedMutationsThreshold) is reached, revert color to color mutation base (-c | --colorMutationBase). Default 1 (true). If you use this at all you want to change the default 1 (true) by passing 0 (false). If false, color will change more in the painting. If true, color will only evolve as much as coordinates successfully evolve.')
parser.add_argument('-s', '--stopPaintingPercent', type=float, default=1, help='What percent canvas fill to stop painting at. To paint until the canvas is filled (which is infeasible for higher resolutions), pass 1 (for 100 percent) If not 1, value should be a percent expressed as a decimal (float) between 0 and 1. Default 1 (100 percent). For high failedMutationsThreshold or random walk (random walk not implemented at this writing), 0.475 (around 48 percent) is recommended.')
parser.add_argument('-a', '--animationSaveEveryNframes', type=int, help='Every N successful coordinate and color mutations, save an animation frame into a subfolder named after the intended final art file. To save every frame, set this to 1, or to save every 3rd frame set it to 3, etc. Saves zero-padded numbered frames to a subfolder which may be strung together into an animation of the entire painting process (for example via ffmpegAnim.sh). May substantially slow down render, and can also create many, many gigabytes of data, depending. Off by default. To switch it on, use it (with a number).')

args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

numIMGsToMake = args.numberOfImages
rshift = args.rshift
width = args.width
height = args.height
# percentMutation = args.percentMutation
# failedMutationsThreshold = args.failedMutationsThreshold
# revertColorOnMutationFail = args.revertColorOnMutationFail
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
# if failedMutationsThreshold == None:
	# failedMutationsThreshold = int(allesPixelCount * percentMutation)

terminatePaintingAtFillCount = int(allesPixelCount * stopPaintingPercent)

# START COORDINATE CLASS
class Coordinate:
	# slots for allegedly higher efficiency re: https://stackoverflow.com/a/49789270
	__slots__ = ["YXtuple", "x", "y", "maxX", "maxY", "parentRGBcolor", "mutatedRGBcolor", "emptyNeighbors"]
	def __init__(self, x, y, maxX, maxY, parentRGBcolor):
		self.YXtuple = (y, x)
		self.x = x; self.y = y;	self.parentRGBcolor = parentRGBcolor; self.mutatedRGBcolor = parentRGBcolor
		# Adding all possible empty neighbor values even if they would result in values out of bounds of image (negative or past maxX or maxY), and will check for and clean up pairs with out of bounds values after:
		tmpList = [ (y-1, x-1), (y, x-1), (y+1, x-1), (y-1, x), (y+1, x), (y-1, x+1), (y, x+1), (y+1, x+1) ]
		deleteList = []
		for element in tmpList:
			if -1 in element:
				deleteList.append(element)
		for element in tmpList:
			if element[1] == maxX:
				deleteList.append(element)
		for element in tmpList:
			if element[0] == maxY:
				deleteList.append(element)
		# reduce deleteList to a list of unique tuples (in case of duplicates, where duplicates could lead us to attempt to remove something that ins't there, which would throw an exception and stop the script) :
		deleteList = list(set(deleteList))
		# the deletions:
		for no in deleteList:
			tmpList.remove(no)
		# finally initialize the intended object member from that built list:
		self.emptyNeighbors = list(tmpList)
	def getRNDemptyNeighbors(self):
		rndNeighborsToReturn = []		# init an empty array we'll populate with neighbors (int tuples) and return
		if len(self.emptyNeighbors) > 0:		# If there is anything left in emptyNeighbors:
			# START VISCOSITY CONTROL.
# TO DO: add a viscosity control parameter (via argsparse, using a range 0-6, default 4 (see next comments), to be used by this section.
			# Conditionally throttle maxRNDrange (for random selection of empty neighbors).
			# NOTE: If viscosity is higher, coordinate growth will appear to follow a more stringy/meandering/splatty path/form (it will spread less uniformly) ; viscosity must be between 0 (very liquid--viscosity check will always be bypassed) to 6 (thick):			
			viscosity = 4
			if len(self.emptyNeighbors) - viscosity > 1 and viscosity != 0:		# If we can subtract the highest possiible number (of random selection count) of available neighbors by viscosity and still have 1 left (and if viscosity is nonzero), do that:
				# print('--------VISCOSITY CHECK PASSED---------)')
				maxRNDrange = len(self.emptyNeighbors) - viscosity
				# print('maxRNDrange selected of', maxRNDrange, 'where len is', len(self.emptyNeighbors))
			else:		# Otherwise take a random selection of available neighbors from the full number range of available neighbors:
				maxRNDrange = len(self.emptyNeighbors)
			# END VISCOSITY CONTROL.
			nNeighborsToReturn = np.random.random_integers(1, maxRNDrange)		# Decide how many to pick
			for pick in range(0, nNeighborsToReturn):
				RNDneighbor = random.choice(self.emptyNeighbors)
				rndNeighborsToReturn.append(RNDneighbor)
				self.emptyNeighbors.remove(RNDneighbor)
		else:		# If there is _not_ anything left in emptyNeighbors:
			rndNeighborsToReturn.append( () )		# Append an empty tuple, which is all that will be in rndNeighborsToReturn.
		return list(rndNeighborsToReturn)	# If you don't call that with list(), it returns a reference instead of copy (we want a copy).
# END COORDINATE CLASS

# START GLOBAL FUNCTIONS
# TO DO: REINTEGRATE AS DESIRED, ELSE DELETE:
# function takes two ints and shifts each up or down one or not at all. I know, it doesn't receive a tuple as input but it gives one as output:
# def mutateCoordinate(xCoordParam, yCoordParam):
# 	xCoord = np.random.random_integers((xCoordParam - 1), xCoordParam + 1)
# 	yCoord = np.random.random_integers((yCoordParam - 1), yCoordParam + 1)
# 	# if necessary, move results back in range of the array indices this is intended to be used with (zero-based indexing, so maximum (n - 1) and never less than 0) :
# 	if (xCoord < 0):
# 		xCoord = 0
# 	if (xCoord > (width - 1)):
# 		xCoord = (width - 1)
# 	if (yCoord < 0):
# 		yCoord = 0
# 	if (yCoord > (height - 1)):
# 		yCoord = (height - 1)
# 	return [xCoord, yCoord]


# function requires lists of Coordinates as parameters, and it directly maniuplates those lists (which are passed by reference). parentColor should be a list of RGB colors in the format [255,0,255].
def getNewLivingCoord(parentRGBColor, tupleToAllocate, unusedCoords, livingCoords, arr):	# Those last three parameters are lists!
	if tupleToAllocate:		# If that tuple has a value, do the function's work.
# TO DO: shift that burden of checking for emptiness out of this function?
		# (Maybe) move that tuple out of unusedCoords and into livingCoords:
		if tupleToAllocate in unusedCoords:		# Only execute the following remove line of code if it's in that:
			unusedCoords.remove(tupleToAllocate)
		if tupleToAllocate not in livingCoords:		# Only execute the following add line of code if it's not in that:
			livingCoords.append(tupleToAllocate)
			# Give that new living coord, IN arr[], a parent color (to later mutate from):
			arr[tupleToAllocate[0]][tupleToAllocate[1]].parentRGBcolor = parentRGBColor
			# All the following will also only be done if that was not found in livingCoords:
			# Using list of empty neighbors, remove that newly chosen RNDcoord from the emptyNeighbors lists of all empty neighbor coords (so that in later use of those empty neighbor lists, the new livingCoords won't erroneously be attempted to be reused) :
			tmpListOne = list(arr[tupleToAllocate[0]][tupleToAllocate[1]].emptyNeighbors)
			for toFindSelfIn in tmpListOne:
				if toFindSelfIn in arr[toFindSelfIn[0]][toFindSelfIn[1]].emptyNeighbors:		# Only execute the following remove line of code if toFindSelfIn is in that:
					arr[toFindSelfIn[0]][toFindSelfIn[1]].emptyNeighbors.remove(tupleToAllocate)
	else:		# If that tuple doesn't have a value, print a warning and return an empty tuple:
# TO DO: fix, if possible, what is causing this script to print this warning a lot:
		# print("Warning: empty tuple passed to function getNewLivingCoord().")
		tupleToAllocate = ()
	return tupleToAllocate

# function creates image from list of Coordinate objects, height and width definitions, and a filename string:
def coordinatesListToSavedImage(arr, height, width, imgFileName):
	tmpArray = []
	for i in range(0, height):
		coordsRow = []
		for j in range(0, width):
			coordsRow.append(arr[i][j].mutatedRGBcolor)
		tmpArray.append(coordsRow)
	tmpArray = np.asarray(tmpArray)
	im = Image.fromarray(tmpArray.astype(np.uint8)).convert('RGB')
	im.save(imgFileName)

# function prints coordinate plotting statistics (progress report):
def printProgress():
	print('Painted', paintedCoordinates, 'of desired', terminatePaintingAtFillCount, 'coordinates (on a canvas of', allesPixelCount, ' pixels).')
# END GLOBAL FUNCTIONS
# END OPTIONS AND GLOBALS

print('Will generate ', numIMGsToMake, ' image(s).')

# Loop making N (-n | numimages) images.
# "Initialize" (paint over entire) the "canvas" with the chosen base canvas color:
for n in range(1, (numIMGsToMake + 1) ):		# + 1 because it iterates n *after* the loop.
	animationSaveNFramesCounter = 0
	animationFrameCounter = 0

	unusedCoords = []		# A list of Coordinate objects which are free for the taking.
	# Initialize canvas array (list of lists of Coordinates), and init unusedCoords with grid int tuples along the way:
	arr = []
	for y in range(0, height):		# for columns (x) in row)
		tmpList = []
		for x in range(0, width):		# over the columns, prep and add:
			tmpList.append( Coordinate(x, y, width, height, colorMutationBase) )
			unusedCoords.append( (y, x) )
		arr.append(tmpList)

	livingCoords = []		# A list of Coordinate objects which are set aside for use (coloring, etc.)
	# Initialize first living Coordinates (livingCoords list) by random selection from unusedCoords (and remove from unusedCoords):
# TO DO: add an argsparse argument for startCoordsN (the number of starting coords) ; until then this is hard-coded:
	# print('unusedCoords before:', unusedCoords)
	# print('livingCoords before:', livingCoords)
	startCoordsN = 3
	for i in range(0, startCoordsN):
		RNDcoord = random.choice(unusedCoords)
		getNewLivingCoord(colorMutationBase, RNDcoord, unusedCoords, livingCoords, arr)
	# print('unusedCoords after:', unusedCoords)
	# print('livingCoords after:', livingCoords)

	color = colorMutationBase
	previousColor = color
	failedCoordMutationCount = 0
	reportStatsEveryNthLoop = 3
	reportStatsNthLoopCounter = 0

	# Create unique, date-time informative image file name. Note that this will represent when the painting began, not when it ended (~State filename will be based off this).
	now = datetime.datetime.now()
	timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
	rndStr = ('%03x' % random.randrange(16**3))		# Returns three random lowercase hex characters.
# TO DO: reactivate this file name string format if/when failedMutationsThreshold is reintegrated:
	# imgFileBaseName = timeStamp + '-' + rndStr + '-colorGrowth-Py-r' + str(rshift) + '-f' + str(failedMutationsThreshold)
	imgFileBaseName = timeStamp + '-' + rndStr + '-colorGrowth-Py-r' + str(rshift)
	imgFileName = imgFileBaseName + '.png'
	stateIMGfileName = imgFileBaseName + '-state.png'
	animFramesFolderName = imgFileBaseName + '_frames'

	if animationSaveEveryNframes:	# If that has a value that isn't None, create a subfolder to write frames to:
		# Also, initailize a varialbe which is how many zeros to pad animation save frame file (numbers) to, based on how many frames will be rendered:
		padAnimationSaveFramesNumbersTo = len(str(terminatePaintingAtFillCount))
		os.mkdir(animFramesFolderName)

	# ----
	# START IMAGE MAPPING
	paintedCoordinates = 0
	print('Generating image . . .')
	while livingCoords:
		# Operate on copy of livingCoords (not livingCoords itself), because this loop changes livingCoords (I don't know whether it copies the list in memory and operates from that or responds to it changing; I would do the former if I designed a language).
		copyOfLivingCoords = list(livingCoords)
		for coord in copyOfLivingCoords:
			livingCoords.remove(coord)		# Remove that to avoid wasted calculations (so many empty tuples passed to getNewLivingCoord)
			# Mutate color--! and assign it to the mutatedRGBcolor in the Coordinate object:
			RGBcolorTMP = arr[coord[0]][coord[1]].parentRGBcolor + np.random.random_integers(-rshift, rshift, size=3) / 2
			RGBcolorTMP = np.clip(RGBcolorTMP, 0, 255)
			arr[coord[0]][coord[1]].mutatedRGBcolor = RGBcolorTMP
			newLivingCoordsParentRGBcolor = arr[coord[0]][coord[1]].mutatedRGBcolor
# TO DO: DEBUG and if necessary fix: why is paintedCoordinates arriving at a number far greater than allesPixelCount?
			paintedCoordinates += 1
			RNDemptyCoordsList = arr[coord[0]][coord[1]].getRNDemptyNeighbors()
			for coord in RNDemptyCoordsList:
				getNewLivingCoord(newLivingCoordsParentRGBcolor, coord, unusedCoords, livingCoords, arr)

# TO DO: I might like it if this stopped saving new frames after every coordinate was colored (it can (always does?) save extra redundant frames at the end;
		# Save an animation frame if that variable has a value:
		if animationSaveEveryNframes:
			if (animationSaveNFramesCounter % animationSaveEveryNframes) == 0:
				strOfThat = str(animationFrameCounter)
				animIMGFileName = animFramesFolderName + '/' + strOfThat.zfill(padAnimationSaveFramesNumbersTo) + '.png'
				coordinatesListToSavedImage(arr, height, width, animIMGFileName)
				animationFrameCounter += 1		# Increment that *after*, for image tools expecting series starting at 0.
			animationSaveNFramesCounter += 1

# TO DO: REINTEGRATE AS WANTED for a more stringy (more walking than spreading) mode:
		# If the coordinate is NOT NOT used (is used), print a progress message.
		# 	failedCoordMutationCount += 1
		# Get a new random coordinate if failedMutationsThreshold met.
		# 	if failedCoordMutationCount == failedMutationsThreshold:
		# 		printProgress()
		# 		failedCoordMutationCount = 0
# TO DO: REINTEGRATE AS WANTED (how do I track color mutation fail now with multiple living coordinates?) :
				# On color mutation fail, revert color to base.
				# if revertColorOnMutationFail == 1:
				# 	previousColor = colorMutationBase

		# Save a snapshot/progress image and print progress:
		if reportStatsNthLoopCounter == 0 or reportStatsNthLoopCounter == reportStatsEveryNthLoop:
			print('Saving prograss snapshot image ', stateIMGfileName, ' . . .')
			coordinatesListToSavedImage(arr, height, width, stateIMGfileName)
# TO DO: uncomment and fix errors originating from the next line of code:
			printProgress()
			reportStatsNthLoopCounter = 1
		reportStatsNthLoopCounter += 1

		# This will terminate all coordinate and color mutation at an arbitary number of mutations.
		if paintedCoordinates == terminatePaintingAtFillCount:
			print('Painted coordinate termination count', paintedCoordinates, 'reached. Ending paint algorithm.')
			break
	# END IMAGE MAPPING
	# ----

# print('state of arrays after that loop:')
# print('unusedCoords:', unusedCoords)
# print('livingCoords:', livingCoords)

# Save final image file and delete progress (state, temp) image file:
print('Saving image ', imgFileName, ' . . .')
coordinatesListToSavedImage(arr, height, width, imgFileName)
print('Created ', n, ' of ', numIMGsToMake, ' images.')
os.remove(stateIMGfileName)


# MUCH BETTERER REFERENCE:
# arr = np.ones((height, width, 3)) * backgroundColor
# # THAT ARRAY is organized as [down][across] OR [y][x] OR [height - n][width - n] OR [row][column]; re the following numpy / PIL-compatible list of lists of lists of numbers and debug print to help understand the structure:
# arr[2][3] = [255,0,255]		# y (down) = 1, x (across) = 2 (actual coordinates are +1 each because of zero-based indexing)
# for y in range(0, height):
# 	print('- y height (', height, ') iterator ', y, 'in arr[', y, '] gives:\n', arr[y])
# 	for x in range(0, width):
# 		print(' -- x width (', width, ') iterator ', x, 'in arr[', y, '][', x, '] gives:', arr[y][x])

# Duplicating that structure with a list of lists:
# imgArr = []		# Intended to be a list of lists
# for y in range(0, height):		# for columns (x) in row)
# 	tmpList = []
# 	for x in range(0, width):		# over the columns, prep and add:
# 		tmpList.append(Coordinate(x, y, width, height, backgroundColor, False, False, None))
# 	imgArr.append(tmpList)

# Printing the second to compare to the first for comprehension:
# print('------------')
# for y in range(0, height):
# 	print('-')
# 	for x in range(0, width):
# 		print(' -- imgArr[y][x].YXtuple (imgArr[', y, '][', x, '].YXtuple) is:', imgArr[y][x].YXtuple)
# 		print(' ALSO I think the empty neighbor coordinate list in the Coordinate object at [y][x] can be used with this list of lists structure for instant access of neighbor coordinates?! That list here is:', imgArr[y][x].emptyNeighbors, ' . . .')
# 		rndEmptyNeighborList = imgArr[y][x].getRNDemptyNeighbors()
# 		print(' HERE ALSO is a random selection of those neighbors:', rndEmptyNeighborList)
