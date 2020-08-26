# DESCRIPTION
# This is saved as a new script from a development version of colorGrowth.py which has unintended functionality, which is that colors, soon after they have already been filled, still spawn new coordinates and fill them with mutated color for a while. With the -a 1 switch passed to the script and saved animation frames strung together into a video render (e.g. via ffmpegAnim.sh), this appears like ink flowing after it has been poured. This is however much more computationally expensive to simulate, so I saved this development glitch script separate (not intended to be in the final). Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Output file names are based on the date and add random characters. Inspired and drastically evolved from colorFibers.py, which was horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# DEPENDENCIES
# python 3 with the various modules installed that you see in the import statements here near the start of this script.

# USAGE
# Run this script through a Python interpreter without any parameters, and it will use a default set of parameters:
#    python /path/to/this/script/color_growth_inky_flow_glitch.py
# To see available parameters, run this script with the -h switch:
#    python /path/to/this/script/color_growth_inky_flow_glitch.py


# CODE
# TO DO
# - fix bugs extant in that this is a dev version?
import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image

# START OPTIONS AND GLOBALS
parser = argparse.ArgumentParser(description='Renders a PNG image like bacteria that produce random color mutations as they grow over a surface. Right now it is one virtual, undead bacterium. A planned update will host multiple virtual bacteria. Output file names are after the date plus random characters. Inspired by and drastically evolved from colorFibers.py, which was horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numberOfImages', type=int, default=4, help='How many images to generate. Default 7.')
parser.add_argument('-w', '--width', type=int, default=450, help='Width of output image(s). Default 1200.')
parser.add_argument('-t', '--height', type=int, default=226, help='Height of output image(s). Default 400.')
parser.add_argument('-r', '--rshift', type=int, default=4, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut 2. Ripped or torn looking color streaks are more likely toward 6 or higher. Default 2.')
parser.add_argument('-b', '--backgroundColor', default='[253, 252, 206]', help='Canvas color. Expressed as a python list or single number that will be assigned to every value in an RGB triplet. If a list, give the RGB values in the format \'[253, 252, 206]\' (if you add spaces after the commas, you must surround the parameter in single or double quotes). A single number example like just 150 will result in a medium-light gray of [150, 150, 150] (Red = 150, Green = 150, Blue = 150). All values must be between 0 and 255. Default [253, 252, 206] (a light buttery yellow).')
parser.add_argument('-c', '--colorMutationBase', help='Base initialization color for pixels, which randomly mutates as painting proceeds. If omitted, defaults to whatever backgroundColor is. If included, may differ from backgroundColor. This option must be given in the same format as backgroundColor.')
parser.add_argument('-s', '--stopPaintingPercent', type=float, default=1, help='What percent canvas fill to stop painting at. To paint until the canvas is filled (which is infeasible for higher resolutions), pass 1 (for 100 percent) If not 1, value should be a percent expressed as a decimal (float) between 0 and 1. Default 1 (100 percent). For high failedMutationsThreshold or random walk (random walk not implemented at this writing), 0.475 (around 48 percent) is recommended.')
parser.add_argument('-a', '--animationSaveEveryNframes', type=int, default=1, help='Every N successful coordinate and color mutations, save an animation frame into a subfolder named after the intended final art file. To save every frame, set this to 1, or to save every 3rd frame set it to 3, etc. Saves zero-padded numbered frames to a subfolder which may be strung together into an animation of the entire painting process (for example via ffmpegAnim.sh). May substantially slow down render, and can also create many, many gigabytes of data, depending. 1 by default. To disable, set it to 0 with: -a 0 OR: --animationSaveEveryNframes 0')

args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

numIMGsToMake = args.numberOfImages
rshift = args.rshift
width = args.width
height = args.height
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
allesPixelCount = width * height

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
# VISCOSITY HARD-CODED HERE.
			# Conditionally throttle maxRNDrange (for random selection of empty neighbors).
			# NOTE: If viscosity is higher, coordinate growth will appear to follow a more stringy/meandering/splatty path/form (it will spread less uniformly) ; viscosity must be between 0 (very liquid--viscosity check will always be bypassed) to 6 (thick):			
			viscosity = 4
			if len(self.emptyNeighbors) - viscosity > 1 and viscosity != 0:		# If we can subtract the highest possiible number (of random selection count) of available neighbors by viscosity and still have 1 left (and if viscosity is nonzero), do that:
				maxRNDrange = len(self.emptyNeighbors) - viscosity
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
# startCoordsN HARD CODED HERE.
	startCoordsN = 3
	for i in range(0, startCoordsN):
		RNDcoord = random.choice(unusedCoords)
		getNewLivingCoord(colorMutationBase, RNDcoord, unusedCoords, livingCoords, arr)

	color = colorMutationBase
	reportStatsEveryNthLoop = 3
	reportStatsNthLoopCounter = 0

	# Create unique, date-time informative image file name. Note that this will represent when the painting began, not when it ended (~State filename will be based off this).
	now = datetime.datetime.now()
	timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
	rndStr = ('%03x' % random.randrange(16**3))		# Returns three random lowercase hex characters.
	imgFileBaseName = timeStamp + '-' + rndStr + '-colorGrowth-Py-r' + str(rshift)
	imgFileName = imgFileBaseName + '.png'
	stateIMGfileName = imgFileBaseName + '-state.png'
	animFramesFolderName = imgFileBaseName + '_frames'

	if animationSaveEveryNframes > 0:	# If that has a value greater than zero, create a subfolder to write frames to:
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

		# Save an animation frame if that variable has a value:
		if animationSaveEveryNframes:
			if (animationSaveNFramesCounter % animationSaveEveryNframes) == 0:
				strOfThat = str(animationFrameCounter)
				animIMGFileName = animFramesFolderName + '/' + strOfThat.zfill(padAnimationSaveFramesNumbersTo) + '.png'
				coordinatesListToSavedImage(arr, height, width, animIMGFileName)
				animationFrameCounter += 1		# Increment that *after*, for image tools expecting series starting at 0.
			animationSaveNFramesCounter += 1

		# Save a snapshot/progress image and print progress:
		if reportStatsNthLoopCounter == 0 or reportStatsNthLoopCounter == reportStatsEveryNthLoop:
			print('Saving prograss snapshot image ', stateIMGfileName, ' . . .')
			coordinatesListToSavedImage(arr, height, width, stateIMGfileName)
			printProgress()
			reportStatsNthLoopCounter = 1
		reportStatsNthLoopCounter += 1

		# This will terminate all coordinate and color mutation at an arbitary number of mutations.
		if paintedCoordinates >= terminatePaintingAtFillCount:
			print('Painted coordinate termination count', paintedCoordinates, 'reached. Ending paint algorithm.')
			break
	# END IMAGE MAPPING
	# ----

	# Save final image file and delete progress (state, temp) image file:
	print('Saving image ', imgFileName, ' . . .')
	coordinatesListToSavedImage(arr, height, width, imgFileName)
	print('Created ', n, ' of ', numIMGsToMake, ' images.')
	os.remove(stateIMGfileName)
