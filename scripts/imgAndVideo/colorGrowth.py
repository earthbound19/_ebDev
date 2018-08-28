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
# - See if there are redundant "in deadCoords" checks (in code and in a function) -- I think there are -- and use only one.
# - Things listed in development code with TO DO comments
# - Option: instead of randomly mutating color for each individual chosen neighbor coordinate, mutate them all to the same new color. This would be more efficient, and might make colors more banded/ringed/spready than streamy. It would also visually indicate coordinate mutation more clearly. Do this or the other option (mutate each, so each can be different) based on an option check.
#  - option to randomly alternate that method as you go
#  - option to set the random chance for using one or the other
# - Random coordinate death in a frequency range (may make the animation turn anything between trickles to rivers to floods)?
# - Option to suppress progress print to save time
# - Initialize colorMutationBase by random selection from a .hexplt color scheme
# - (Applies to method used in colorWander.py:) Coordinate mutation: optionally revert to coordinate before last known successful mutation on coordinate mutation fail (instead of continuing random walk). This would still need the failsafe of failedMutationsThreshold.
# - (Applies to method used in colorWander.py:) Color mutation option: on coordinate mutation fail, select random new color (including from a .hexplt color scheme). If this and -d are present, -d wins.
# - Major new feature? : Initialize arr[] from an image, pick a random coordinate from the image, and use the color at that coordinate both as the origin coordinate and the color at that coordinate as colorMutationBase. Could also be used to continue terminated runs with the same or different parameters.


# CODE
import datetime, random, argparse, ast, os.path, sys, re, subprocess, shlex
import numpy as np
from PIL import Image

# Defaults which will be overriden if arguments of the same name are provided to the script:
numberOfImages = 1
width = 400
height = 200
rshift = 8
stopPaintingPercentAsDecimal = 0.64
animationSaveEveryNframes = 0
numberStartCoordinatesRNDrange = (1,13)
viscosity = 4		# Acceptable defaults: 0 to 5. 6 works, but test output with that was brief and uninteresting.
savePreset = True
# BACKGROUND color options;
# any of these (uncomment only one) are reinterpreted as a list later by ast.literal_eval(backgroundColor) :
# backgroundColor = '[157,140,157]'		# Medium purplish gray
backgroundColor = '[252,251,201]'		# Buttery light yellow


# START OPTIONS AND GLOBALS
parser = argparse.ArgumentParser(description='Renders a PNG image like bacteria that produce random color mutations as they grow over a surface. Output file names are after the date plus random characters. Inspired by and drastically evolved from colorFibers.py, which was horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numberOfImages', type=int, help='How many images to generate. Default ' + str(numberOfImages) +'. WARNING: if you want to be able to later deterministially re-create a high resolution image which happens to be e.g. the 40th in a series where n=40 (using this -n switch with the --randomSeed switch), that may be time costly (because the determinant of that 40th image factors all pseudo-randomness used for all prior images), and you may wish to not do that. You may wish to set -n 1 for high resolution images (only make one image per run in that case).')
parser.add_argument('--width', type=int, help='Width of output image(s). Default ' + str(width) + '.')
parser.add_argument('--height', type=int, help='Height of output image(s). Default ' + str(height) + '.')
parser.add_argument('-r', '--rshift', type=int, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut ' + str(rshift) + '.')
parser.add_argument('-b', '--backgroundColor', type=str, help='Canvas color. Expressed as a python list or single number that will be assigned to every value in an RGB triplet. If a list, give the RGB values in the format \'[255,70,70]\' (if you add spaces after the commas, you must surround the parameter in single or double quotes). This example would produce a deep red, as Red = 255, Green = 70, Blue = 70). A single number example like just 150 will result in a medium-light gray of [150,150,150] (Red = 150, Green = 150, Blue = 150). All values must be between 0 and 255. Default ' + str(backgroundColor) + '.')
parser.add_argument('-c', '--colorMutationBase', type=str, help='Base initialization color for pixels, which randomly mutates as painting proceeds. If omitted, defaults to whatever backgroundColor is. If included, may differ from backgroundColor. This option must be given in the same format as backgroundColor.')
# NOTES: at this writing (with successful coordinates growth instead of only one coordinate wandering), the following will virtually never be needed; they may be needed again if I add random coordinate death (fail to continue growing at all) :
# TO DO? : UNCOMMENT and reintegrate associated code; update default handling to work like the rest of this script though (with defaults set in if args.parameter checks only if args.parameter not provided:
# parser.add_argument('-p', '--percentMutation', type=float, default=0.043, help='(Alternate for -m) What percent of the canvas would have been covered by failed mutation before it triggers selection of a random new available unplotted coordinate. Percent expressed as a decimal (float) between 0 and 1. Default 0.043 (about 4 percent).')
# TO DO? : UNCOMMENT and reintegrate associated code:
# parser.add_argument('-f', '--failedMutationsThreshold', type=int, help='How many times coordinate mutation must fail to trigger selection of a random new available unplotted coordinate. Overrides -p | --percentMutation if present.')
# TO DO? : UNCOMMENT and reintegrate associated code:
# parser.add_argument('-d', '--revertColorOnMutationFail', type=int, default=1, help='If (-f | --failedMutationsThreshold) is reached, revert color to color mutation base (-c | --colorMutationBase). Default 1 (true). If you use this at all you want to change the default 1 (true) by passing 0 (false). If false, color will change more in the painting. If true, color will only evolve as much as coordinates successfully evolve.')
parser.add_argument('--stopPaintingPercentAsDecimal', type=float, help='What percent canvas fill to stop painting at. To paint until the canvas is filled (which can take extremely long for higher resolutions), pass 1 (for 100 percent). If not 1, value should be a percent expressed as a decimal (float) between 0 and 1 (e.g 0.4 for 40 percent. Default ' + str(stopPaintingPercentAsDecimal) + '. For high --failedMutationsThreshold or random walk (neither of which is implemented at this writing), 0.475 (around 48 percent) is recommended. Stop percent is adhered to approximately (it could be much less efficient to make it exact).')
parser.add_argument('-a', '--animationSaveEveryNframes', type=int, help='Every N successful coordinate and color mutations, save an animation frame into a subfolder named after the intended final art file. To save every frame, set this to 1, or to save every 3rd frame set it to 3, etc. Saves zero-padded numbered frames to a subfolder which may be strung together into an animation of the entire painting process (for example via ffmpegAnim.sh). May substantially slow down render, and can also create many, many gigabytes of data, depending. ' + str(animationSaveEveryNframes) + ' by default. To disable, set it to 0 with: -a 0 OR: --animationSaveEveryNframes 0')
parser.add_argument('-s', '--randomSeed', type=int, help='Seed for random number generators (random and numpy.random are used). Default generated by random library itself and added to render file name for reference. Can be any integer in the range 0 to 4294967296 (2^32). If not provided, it will be randomly chosen from that range (meta!). If --savePreset is used, the chosen seed will be saved with the preset .cgp file. Interestingly, functionally different versions of the "random" and "numpy" libraries would theoretically produce different deterministic results (untested).')
parser.add_argument('-q', '--numberStartCoordinates', type=int, help='How many origin coordinates to begin coordinate and color mutation from. Default randomly chosen from range in --numberStartCoordinatesRNDrange (see). Random selection from that range is performed *after* random seeding by --randomSeed, so that the same random seed will always produce the same number of start coordinates. I haven\'t tested whether this will work if the number exceeds the number of coordinates possible in the image. Maybe it would just overlap itself until they\'re all used?')
parser.add_argument('--numberStartCoordinatesRNDrange', help='Random integer range to select a random number of --numberStartCoordinates if --numberStartCoordinates is not provided. Default (' + str(numberStartCoordinatesRNDrange[0]) + ',' + str(numberStartCoordinatesRNDrange[1]) + '). Must be provided in that form (a string that can be evaluated to a python tuple), and in the range 0 to 4294967296 (2^32), but I bet that sometimes nothing will render if you choose a max range number orders of magnitude higher than the number of pixels available in the image. I probably would never make the max range higher than (number of pixesl in image) / 62500 (which is 250 squared). Will not be used if [-q | numberStartCoordinates] is provided.')
parser.add_argument('--viscosity', type=int, help='How "thick" the liquid (if it were liquid) is, or how much difficulty coordinates have growing. Default ' + str(viscosity) + '. If this is higher, free neighbor coordinates are filled less frequently (fewer of them may be randomly selected), which will produce a more stringy/meandering/splatty path or form (as it spreads less uniformly). If this is lower, neighbor coordinates are more often or (if 0) always flooded. Must be between 0 to 5, where 0 is very liquid--viscosity check will always be bypassed, but coordinates will take longer to spread further--and where 5 is very thick (yet smaller streamy/flood things may traverse a distance faster). You can set it to 6, but in tests, that made a few small strings and ended.')
parser.add_argument('--savePreset', type=str, help='Save all parameters (which are passed to this script) to a .cgp (color growth preset) file. If provided, --savePreset must be a string representing a boolean state (True or False or 1 or 0). Default '+ str(savePreset) +'. The .cgp file can later be loaded with the --loadPreset switch to create either new or identical work from the same parameters (whether it is new or identical depends on the switches, --randomSeed being the most consequential). This with [-a | --animationSaveEveryNframes] can recreate gigabytes of exactly the same animation frames using just a preset. NOTES: --numberStartCoordinatesRNDrange and its accompanying value are not saved to config files, and the resultantly generated [-q | --numberStartCoordinates] is saved instead.')
parser.add_argument('--loadPreset', type=str, help='A preset file (as first created by --savePreset) to use. Empty (none used) by default. Not saved to any preset. At this writing only a single file name is handled, not a path, and it is assumed the file is in the current directory. NOTE: use of this switch discards all other parameters and loads all parameters from the preset. A .cgp preset file is a plain text file on one line, which is a collection of switches to be passed to this script, written literally the way you would pass them to this script.')

	# START ARGUMENT PARSING
	# DEVELOPER NOTE: Throughout the below argument checks, wherever a user does not specify an argument and I use a default (as defaults are defined near the start of working code in this script), add that default switch and switch value pair to sys.argv, for use by the --savePreset feature (which saves everything except for the script path ([0]) to a preset). I take this approach because I can't check if a default value was supplied if I do that in the parser.add_argument function -- http://python.6.x6.nabble.com/argparse-tell-if-arg-was-defaulted-td1528162.html -- so what I do is check for None (and then supply a default and add to argv if None is found). The check for None isn't literal: it's in the else: clause after an if (value) check (if the if check fails, that means the value is None, and else: is invoked) :
print('~-')
print('~- Processing any arguments to script . . .')
args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

# IF A PRESET file is given, load its contents (which should be a collection of CLI switches for this script itself) and pass them to a new running instance of this script, then exit this script:
if args.loadPreset:
	loadPreset = args.loadPreset
	print('loadPreset is', loadPreset)
	# print('path to this script itself is', sys.argv[0])
	print('Attempting to load subprocess of this script with the switches in loadPreset . . .')
	with open(loadPreset) as f:
		switches = f.readline()
	subprocess.call(shlex.split('python ' + sys.argv[0] + ' ' + switches))		# sys.argv[0] is the path to this script.
	print('Subprocess hopefully completed successfully. Will now exit script.')
	sys.exit()

if args.numberOfImages:		# If a user supplied an argument (so that numberOfImages has a value (is not None), use that:
	numberOfImages = args.numberOfImages	# It is in argv already, so it will be used by --savePreset.
else:						# If not, leave the default as it was defined, and add to sys.argv for reasons given above:
	sys.argv.append('-n'); sys.argv.append(str(numberOfImages))

if args.width:
	width = args.width
else:
	sys.argv.append('--width'); sys.argv.append(str(width))

if args.height:
	height = args.height
else:
	sys.argv.append('--height'); sys.argv.append(str(height))

if args.rshift:
	rshift = args.rshift
else:
	sys.argv.append('--rshift'); sys.argv.append(str(rshift))

if args.backgroundColor:
	# For preset saving, remove any troublesome spaces and save back directly to sys.argv, so that --savePreset will save working presets:
	backgroundColor = args.backgroundColor		# Is a string here; will convert to list later
	backgroundColor = re.sub(' ', '', backgroundColor)
	idx = sys.argv.index(args.backgroundColor)
	# print('that points to', sys.argv[idx])
	sys.argv[idx] = backgroundColor
else:
	sys.argv.append('-b'); sys.argv.append(backgroundColor)
# Convert backgroundColor (as set from args.backgroundColor or default) string to python list for use by this script, re: https://stackoverflow.com/a/1894296/1397555
backgroundColor = ast.literal_eval(backgroundColor)

if args.colorMutationBase:		# See comments in args.backgroundColor handling. We're handling this the same.
	colorMutationBase = args.colorMutationBase
	colorMutationBase = re.sub(' ', '', colorMutationBase)
	idx = sys.argv.index(args.colorMutationBase)
	sys.argv[idx] = colorMutationBase
	colorMutationBase = ast.literal_eval(colorMutationBase)
else:		# Default to same as backgroundColor:
	sys.argv.append('-c'); sys.argv.append(backgroundColor)
	# In this case we're using a list as already assigned to backgroundColor:
	colorMutationBase = list(backgroundColor)		# If I hadn't used list(), colorMutationBase would be a reference to backgroundColor (which is default Python list handling behavior with the = operator), and when I changed either, "both" would change (but they would really just be different names for the same list). I want them to be different.

# purple = [255, 0, 255]	# Purple. In prior commits of this script, this has been defined and unused, just like in real life. Now, it is commented out or not even defined, just like it is in real life.

if args.stopPaintingPercentAsDecimal:
	stopPaintingPercentAsDecimal = args.stopPaintingPercentAsDecimal
else:
	sys.argv.append('--stopPaintingPercentAsDecimal'); sys.argv.append(str(stopPaintingPercentAsDecimal))

if args.animationSaveEveryNframes:
	animationSaveEveryNframes = args.animationSaveEveryNframes
else:
	sys.argv.append('-a'); sys.argv.append(str(animationSaveEveryNframes))
# TO DO: if/when these next three are reintegrated, handle them the same way: args.percentMutation, args.failedMutationsThreshold, args.revertColorOnMutationFail. Make sure that if failedMutationsThreshold == None then failedMutationsThreshold = int(allesPixelCount * percentMutation)
if args.randomSeed:
	randomSeed = args.randomSeed
else:
	randomSeed = random.randint(0, 4294967296)
	sys.argv.append('--randomSeed'); sys.argv.append(str(randomSeed))
# Use that seed straightway:
random.seed(randomSeed)
np.random.seed(randomSeed)

	# BEGIN STATE MACHINE "Megergeberg 5,000."
	# DOCUMENTATION.
	# Possible combinations of these variables to handle; "coords" means numberStartCoordinates, RNDcoords means numberStartCoordinatesRNDrange:
	# --
	# ('coords', 'RNDcoords') : use coords, delete any RNDcoords
	# ('coords', 'noRNDcoords') : use coords, no need to delete any RNDcoords. These two: if coords if RNDcoords.
	# ('noCoords', 'RNDcoords') : assign user-provided RNDcoords for use (overwrite defaults).
	# ('noCoords', 'noRNDcoords') : continue with RNDcoords defaults (don't overwrite defaults). These two: else if RNDcoords else. Also these two: generate coords independent of (outside) that last if else (by using whatever RNDcoords ends up being (user-provided or default).
	# --
	# I COULD just have four different, independent "if" checks explicitly for those four pairs and work from that, but I have opted for the convoluted if: if else: if: else: structure. Two possible paths presented in code, and I, I took the convoluted one, and that has made all the difference. Tenuous justification: it is more compact logic (fewer checks).
if args.numberStartCoordinates:		# If --numberStartCoordinates is provided by the user, use it..
	numberStartCoordinates = args.numberStartCoordinates
	print('Will use the provided --numberStartCoordinates, ', numberStartCoordinates)
	if args.numberStartCoordinatesRNDrange:		# .. and delete any --numberStartCoordinatesRNDrange and its value from sys.argv (as it will not be used and would best not be stored in the .cgp config file via --savePreset:
		idx = sys.argv.index(args.numberStartCoordinatesRNDrange)
		del sys.argv[idx-1]		# Why does index() return a one-based index for a zero-based index list?!
		del sys.argv[idx-1]		# Note that the element at the same index is deleted twice because after the first is deleted, the second moves to the index of the first.
		print('** NOTE: ** You provided both [-q | --numberStartCoordinates] and --numberStartCoordinatesRNDrange, but the former overrides the latter (the latter will not be used). This program removed the latter from the sys.argv parameters list.')
else:		# If --numberStartCoordinates is _not_ provided by the user..
	if args.numberStartCoordinatesRNDrange:		# .. but if --numberStartCoordinatesRNDrange _is_ provided, assign from that:
		numberStartCoordinatesRNDrange = ast.literal_eval(args.numberStartCoordinatesRNDrange)
		decidedToUseSTRpart = 'from user-supplied range ' + str(numberStartCoordinatesRNDrange)
	else:		# .. otherwise use the default numberStartCoordinatesRNDrange:
		decidedToUseSTRpart = 'from default range ' + str(numberStartCoordinatesRNDrange)
	numberStartCoordinates = random.randint(numberStartCoordinatesRNDrange[0], numberStartCoordinatesRNDrange[1])
	sys.argv.append('-q'); sys.argv.append(str(numberStartCoordinates))
	print('Using', numberStartCoordinates, 'start coordinates, by random selection ' + decidedToUseSTRpart)
	# END STATE MACHINE "Megergeberg 5,000."

if args.viscosity:
	viscosity = args.viscosity
	# If that is outside accdeptable range, clip it to acceptable range and notify user:
	if viscosity < 0: viscosity = 0; print('NOTE: viscosity was less than 0. The value was clipped to 0.')
	if viscosity > 6: viscosity = 6; print('NOTE: viscosity was greater than 6. The value was clipped to 6.')
	if viscosity == 6: print('NOTE: you\'ll probably get uninteresting results with viscosity at 6. Range 0-6 allowed, 0-5 recommended (with a note that 0 is the slowest).')
	# Also update that in argv:
	idx = sys.argv.index('--viscosity')
	sys.argv[idx+1] = str(viscosity)
else:
	sys.argv.append('--viscosity'); sys.argv.append(str(viscosity))

if args.savePreset:
	savePreset = ast.literal_eval(args.savePreset)
else:
	sys.argv.append('--savePreset'); sys.argv.append(str(savePreset))

if savePreset == True:
	scriptArgsStr = sys.argv[1:]
	scriptArgsStr = ' '.join(str(element) for element in scriptArgsStr)
	# END ARGUMENT PARSING

allesPixelCount = width * height
terminatePaintingAtFillCount = int(allesPixelCount * stopPaintingPercentAsDecimal)

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
	# function returns both a list of randomly selected empty neighbor coordinates to use immediately, and a list of neighbors to use later:
	def getRNDemptyNeighbors(self):
		rndNeighborsToReturn = []		# init an empty array we'll populate with neighbors (int tuples) and return
		if len(self.emptyNeighbors) > 0:		# If there is anything left in emptyNeighbors:
			# START VISCOSITY CONTROL.
			# Conditionally throttle maxRNDrange (for random selection of empty neighbors), via viscosity value.
# TO DO: figure out why viscosity = 6 terminates so fast and whether it should. It works but is very short lived.
			if len(self.emptyNeighbors) - viscosity > 1 and viscosity != 0:		# If we can subtract the highest possiible number (of random selection count) of available neighbors by viscosity and still have 1 left (and if viscosity is nonzero), do that:
				# print('--------VISCOSITY CHECK PASSED---------')
				maxRNDrange = len(self.emptyNeighbors) - viscosity
				# print('maxRNDrange selected of', maxRNDrange, 'where len is', len(self.emptyNeighbors))
			else:		# Otherwise take a random selection of available neighbors from the full number range of available neighbors:
				# print('--------VISCOSITY CHECK BYPASSED-------')
				maxRNDrange = len(self.emptyNeighbors)
			# END VISCOSITY CONTROL.
			nNeighborsToReturn = np.random.random_integers(1, maxRNDrange)		# Decide how many to pick
			rndNeighborsToReturn = random.sample(self.emptyNeighbors, nNeighborsToReturn)
		else:		# If there is _not_ anything left in emptyNeighbors:
			rndNeighborsToReturn = [()]		# Return a list with one empty tuple
		return rndNeighborsToReturn, self.emptyNeighbors
# END COORDINATE CLASS

# START GLOBAL FUNCTIONS
# TO DO: REINTEGRATE AS DESIRED (applies to method used in colorWander.py), ELSE DELETE:
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


# function requires lists of Coordinates as parameters, and it directly maniuplates those lists (which are passed by reference). parentRGBColor should be a list of RGB colors in the format [255,0,255].
def getNewLivingCoord(parentRGBColor, tupleToAllocate, unusedCoords, livingCoords, deadCoords, arr):	# Those last three parameters are lists!
	# (Maybe) move that tuple out of unusedCoords and into livingCoords:
	if tupleToAllocate in unusedCoords:		# Only execute the following remove line of code if it's in that:
		unusedCoords.remove(tupleToAllocate)
	if tupleToAllocate not in livingCoords and tupleToAllocate not in deadCoords:		# Only execute the following add line of code if it's not in that:
		livingCoords.append(tupleToAllocate)
		# Give that new living coord, IN arr[], a parent color (to later mutate from):
		arr[tupleToAllocate[0]][tupleToAllocate[1]].parentRGBcolor = parentRGBColor
		# All the following will also only be done if that was not found in livingCoords:
		# Using list of empty neighbors, remove that newly chosen RNDcoord from the emptyNeighbors lists of all empty neighbor coords (so that in later use of those empty neighbor lists, the new livingCoords won't erroneously be attempted to be reused) :
		tmpListOne = list(arr[tupleToAllocate[0]][tupleToAllocate[1]].emptyNeighbors)
		for toFindSelfIn in tmpListOne:
			if toFindSelfIn in arr[toFindSelfIn[0]][toFindSelfIn[1]].emptyNeighbors:		# Only execute the following remove line of code if toFindSelfIn is in that:
				arr[toFindSelfIn[0]][toFindSelfIn[1]].emptyNeighbors.remove(tupleToAllocate)
#			print('Got new living coordinates.')
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


# START MAIN FUNCTIONALITY.
print('Will generate ', numberOfImages, ' image(s).')

# Loop making [-n | numberOfImages] images.
for n in range(1, (numberOfImages + 1) ):		# + 1 because it iterates n *after* the loop.
	animationSaveNFramesCounter = 0
	animationFrameCounter = 0

	arr = []					# The canvas that is filled by manipulating the other lists, being:
	unusedCoords = []			# A list of Coordinate objects which are free for the taking.
	livingCoords = []			# A list of Coordinate objects which are set aside for use (coloring, etc.)
	delayedBirthCoords = []		# In the below "while livingCoords:" loop, with higher viscosity some coordinates can be painted around (by other coordinates on all sides) but coordinate mutation never actually moves into that coordinate. The result is that some coordinates may never be "born." this list and associated code revives orphan coordinates
	deadCoords = []				# A list of coordinates which have been color mutated and may no longer coordinate mutate.

	# Initialize arr canvas and unusedCoords lists (arr being a list of lists of Coordinates):
	for y in range(0, height):		# for columns (x) in row)
		tmpList = []
		for x in range(0, width):		# over the columns, prep and add:
			tmpList.append( Coordinate(x, y, width, height, backgroundColor) )
			unusedCoords.append( (y, x) )
		arr.append(tmpList)

	# Initialize livingCoords list by random selection from unusedCoords (and remove from unusedCoords):
	for i in range(0, numberStartCoordinates):
		RNDcoord = random.choice(unusedCoords)
		getNewLivingCoord(colorMutationBase, RNDcoord, unusedCoords, livingCoords, deadCoords, arr)

# TO DO: UNCOMMENT AS WANTED (applies to method used in colorWander.py) and reintegrate code that uses it; how do I track color mutation fail now with multiple living coordinates? :
	# color = colorMutationBase
	# previousColor = color
# TO DO: REINTEGRATE AS WANTED (applies to method used in colorWander.py) for a more stringy (more walking than spreading) mode:
	# failedCoordMutationCount = 0
	reportStatsEveryNthLoop = 3
	reportStatsNthLoopCounter = 0

	# Create unique, date-time informative image file name. Note that this will represent when the painting began, not when it ended (~State filename will be based off this).
	now = datetime.datetime.now()
	timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__')
	rndStr = ('%03x' % random.randrange(16**6))		# Returns three random lowercase hex characters.
	imgFileBaseName = timeStamp + rndStr + '_colorGrowth-Py'
	imgFileName = imgFileBaseName + '.png'
	stateIMGfileName = imgFileBaseName + '-state.png'
	animFramesFolderName = imgFileBaseName + '_frames'

	# If bool set saying so, save arguments to this script to a .cgp file with the same base file name as the render target image:
	if savePreset:
		file = open(imgFileBaseName + '.cgp', "w"); file.write(scriptArgsStr); file.close()
	# Operate on copy of livingCoords (not livingCoords itself), because this loop changes livingCoords (I don't know whether it copies the list in memory and operates from that or responds to it changing; I would do the former if I designed a language).

	if animationSaveEveryNframes > 0:	# If that has a value greater than zero, create a subfolder to write frames to:
		# Also, initailize a varialbe which is how many zeros to pad animation save frame file (numbers) to, based on how many frames will be rendered:
		padAnimationSaveFramesNumbersTo = len(str(terminatePaintingAtFillCount))
		os.mkdir(animFramesFolderName)

	# ----
	# START IMAGE MAPPING
	paintedCoordinates = 0
	print('Generating image . . . ')
	while livingCoords:
		RNDnewEmptyCoordsList = []
		# For collecting into delayedBirthCoords:
		RNDnewdelayedBirthCoords = []
		#
		copyOfLivingCoords = list(livingCoords)
		for coord in copyOfLivingCoords:
			livingCoords.remove(coord)		# Remove that to avoid wasted calculations (so many empty tuples passed to getNewLivingCoord)
			if coord not in deadCoords:
				# Mutate color--! and assign it to the mutatedRGBcolor in the Coordinate object:
				RGBcolorTMP = arr[coord[0]][coord[1]].parentRGBcolor + np.random.random_integers(-rshift, rshift, size=3) / 2
				# print('Colored coordinate (y, x)', coord)
				RGBcolorTMP = np.clip(RGBcolorTMP, 0, 255)
				arr[coord[0]][coord[1]].mutatedRGBcolor = RGBcolorTMP
				newLivingCoordsParentRGBcolor = RGBcolorTMP
				deadCoords.append(coord)		# When a coordinate has its color mutated, it dies.
	# TO DO: DEBUG and if necessary fix: why is paintedCoordinates arriving at a number far greater than allesPixelCount?
				paintedCoordinates += 1
				# The first returned list is used straightway, the second at delays (every delayedBirthCoordsBirthingDelay) :
				RNDnewEmptyCoordsList, RNDnewdelayedBirthCoords = arr[coord[0]][coord[1]].getRNDemptyNeighbors()
				for coordZurg in RNDnewEmptyCoordsList:
					getNewLivingCoord(newLivingCoordsParentRGBcolor, coordZurg, unusedCoords, livingCoords, deadCoords, arr)
				# Set parentRGBcolor in arr via RNDnewdelayedBirthCoords:
				for coordYaerf in RNDnewdelayedBirthCoords:
					arr[coordYaerf[0]][coordYaerf[1]].parentRGBcolor = newLivingCoordsParentRGBcolor
				# Collect those coordinates for delayed birth, only if we are not within N iterations of delayedBirthCoordsBirthingDelayCounter == delayedBirthCoordsBirthingDelay (to avoid birthing unbirthed coordinates whose parents were recently birthed; it avoids spurts of growth around edges) :
				# Using delayed birth coordinates at intervals:
			# if SOME CONDITION:
#				delayedBirthCoords = list(set(delayedBirthCoords))	# Removes duplicates
#				for coordYarg in delayedBirthCoords:
#					getNewLivingCoord(newLivingCoordsParentRGBcolor, coordYarg, unusedCoords, livingCoords, deadCoords, arr)
#				delayedBirthCoords = []		# To be built up again via delayedBirthCoordsBirthingDelayCounter += 1 etc.
			#
# TO DO: fix, if possible, whatever leads to this else clause (checking for redundant attempts to use a coordinate) to be invoked A LOT if it is uncommented (and note that whatever this else clause followed is buried in git history now) :
				# else:
					# print('FUGGETABOUTIT!')

# TO DO: I might like it if this stopped saving new frames after every coordinate was colored (it can (always does?) save extra redundant frames at the end;
		# Save an animation frame if that variable has a value:
		if animationSaveEveryNframes:
			if (animationSaveNFramesCounter % animationSaveEveryNframes) == 0:
				strOfThat = str(animationFrameCounter)
				animIMGFileName = animFramesFolderName + '/' + strOfThat.zfill(padAnimationSaveFramesNumbersTo) + '.png'
				coordinatesListToSavedImage(arr, height, width, animIMGFileName)
				animationFrameCounter += 1		# Increment that *after*, for image tools expecting series starting at 0.
			animationSaveNFramesCounter += 1

		# If the coordinate is NOT NOT used (is used), print a progress message.
		# 	failedCoordMutationCount += 1
		# Get a new random coordinate if failedMutationsThreshold met.
		# 	if failedCoordMutationCount == failedMutationsThreshold:
		# 		printProgress()
		# 		failedCoordMutationCount = 0
				# On color mutation fail, revert color to base.
				# if revertColorOnMutationFail == 1:
				# 	previousColor = colorMutationBase

		# Save a snapshot/progress image and print progress:
		if reportStatsNthLoopCounter == 0 or reportStatsNthLoopCounter == reportStatsEveryNthLoop:
#			print('Saving prograss snapshot image ', stateIMGfileName, ' . . .')
			coordinatesListToSavedImage(arr, height, width, stateIMGfileName)
			printProgress()
			reportStatsNthLoopCounter = 1
		reportStatsNthLoopCounter += 1

		# This will terminate all coordinate and color mutation at an arbitary number of mutations.
		if paintedCoordinates >= terminatePaintingAtFillCount:
			print('Painted coordinate termination count', paintedCoordinates, 'reached (or recently exceeded). Ending paint algorithm.')
			break
	# END IMAGE MAPPING
	# ----

	# print('state of arrays after image generation loop:')
	# print('unusedCoords:', unusedCoords)
	# print('livingCoords:', livingCoords)

	# Save final image file and delete progress (state, temp) image file:
	print('Saving image ', imgFileName, ' . . .')
	coordinatesListToSavedImage(arr, height, width, imgFileName)
	print('Created ', n, ' of ', numberOfImages, ' images.')
	os.remove(stateIMGfileName)
# END MAIN FUNCTIONALITY.


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
