# DESCRIPTION
# Run this script with the --help parameter or examine "description" in parser = argparse.. code in this script.

# USAGE
# Run this script with the --help parameter or examine the parser = argparse.. code in this script.


# CODE
import datetime, random, os.path, argparse, sys

parser = argparse.ArgumentParser(description="Generates a random hex color scheme of file format .hexplt (named after the date and time and a few random characters), which is a plain text file with one hex color per line. Modeled after a color theory given in Itten's \"ELEMENTS OF COLOR,\" which states that color combinations tend to be more pleasing to the human eye if, when the colors are mixed (by substractive color mixing), they make gray.")
parser.add_argument("-n", "--numschemes", type=int, default=28, help="How many color schemes to generate. Default 28.")
parser.add_argument("-c", "--numcolorpairs", type=int, default=2, help="How many colors to generate per scheme (2 pairs would be 2x2 = 4). Default 2.")
parser.add_argument("-g", "--grayhigh", type=int, default=222, help="Gray high threshold. No RGB-256 value will be higher than this number. Default 222. Range 0-255.")
parser.add_argument("-l", "--graylow", type=int, default=60, help="Gray low threshold. No RGB-256 value will be lower than this number. Default 60. Range 0-255.")

args = parser.parse_args()

nSchemes = args.numschemes; print 'Will generate ', nSchemes, ' color schemes.'

numColorPairs = args.numcolorpairs; print 'Will generate ', (args.numcolorpairs * 2), ' colors (', numColorPairs, ' pairs) per scheme.'

grayHighThreshold = args.grayhigh
if grayHighThreshold > 255:
	grayHighThreshold = 255; print "Specified -g or --grayhigh was too high and is now adjusted to 255."
if grayHighThreshold < 0:
	grayHighThreshold = 0; print "Specified -g or --grayhigh was too low and is now adjusted to 0."
print 'Gray high threshold is ', grayHighThreshold

grayLowThreshold = args.graylow
if grayLowThreshold > 255:
	grayLowThreshold = 255; print "Specified -l or --graylow was too high and is now adjusted to 255."
if grayLowThreshold < 0:
	grayLowThreshold = 0; print "Specified -l or --graylow was too low and is now adjusted to 0."
print 'Gray low threshold is ', grayLowThreshold

# Randomly pick color values in the red, green and blue channels between grayHighThreshold and grayLowThreshold:
	# For the above values, try these:
	# Full light range -- you'll probably want to throw out some garish or otherwise unwanted results:
	# grayHighThreshold = 255; grayLowThreshold = 0
	# High-ish mid light range -- astonishingly unfailingly produces pleasing combinations:
	# grayHighThreshold = 212; grayLowThreshold = 96
	# Lower light range:
	# grayHighThreshold = 154; grayLowThreshold = 40

h = 0
while h < nSchemes:
	# Create unique, date-time informative .hexplt file name, and open a new handle to it for writing.
	# The start of the file name is three-padded digits indicating how many colors are in the palette.
	numColorsStr = str(numColorPairs * 2)
	paddedNum = numColorsStr.zfill(3)
	now = datetime.datetime.now()
	timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
	# Get a random string of lenght 3 with numbers and lowercase; re: https://stackoverflow.com/a/20688431/1397555
	rndStr = ('%03x' % random.randrange(16**3)).lower()
	hexpltFileName = paddedNum + "__" + timeStamp + "__" + rndStr + ".hexplt"
	print("hexpltFileName is: "); print(hexpltFileName)
	
	# Puts the full immediate path into a string; with help from: https://stackoverflow.com/a/2725195/1397555
	curDir=os.path.realpath('.')
	# Halleluja that the following automagically changes to a backslash when working with Windows' backwards ;) path conventions! :
	fullFilePath = curDir + "/" + hexpltFileName

	# OPEN file for writing:
	f = open(fullFilePath,"w+")
	
	redHighThreshold=grayHighThreshold
	greenHighThreshold=grayHighThreshold
	blueHighThreshold=grayHighThreshold

	redLowThreshold=grayLowThreshold
	greenLowThreshold=grayLowThreshold
	blueLowThreshold=grayLowThreshold
	i = 0
	# Create colors under constraints and write them to that opened .hexplt file.
	while (i < numColorPairs):
		# print("~~loop iteration started; redHighThreshold value is: "); print(redHighThreshold)
		# REDS
		newRedLowVal = random.randint(redLowThreshold,redHighThreshold)
		newRedHighVal=(redHighThreshold - newRedLowVal)
		# The new red high threshold is the boundary of the red partition:
		redHighThreshold=newRedLowVal
		# GREENS
		newGreenLowVal = random.randint(greenLowThreshold,greenHighThreshold)
		newGreenHighVal=(greenHighThreshold - newGreenLowVal)
		greenHighThreshold=newGreenLowVal
		# BLUES
		newBlueLowVal = random.randint(blueLowThreshold,blueHighThreshold)
		newBlueHighVal=(blueHighThreshold - newBlueLowVal)
		blueHighThreshold=newBlueLowVal
		# Print color 1 RGB values in decimal to screen (for debugging):
		print 'color 1 RGB vals: ', str(i), ' ', str(newRedLowVal), ' ', str(newGreenLowVal), ' ', str(newBlueLowVal)
		# Formatting converts decimal value to hex:
		newColorOneHEX = "#" + str("%0.2X" % newRedLowVal) + str("%0.2X" % newGreenLowVal) + str("%0.2X" % newBlueLowVal)
		# Print color 2 RGB values in decimal:
		print 'color 2 RGB vals: ', str(i + 1), '  ', str(newRedHighVal), ' ', str(newGreenHighVal), ' ', str(newBlueHighVal)
		newColorTwoHEX = "#" + str("%0.2X" % newRedHighVal) + str("%0.2X" % newGreenHighVal) + str("%0.2X" % newBlueHighVal)

		f.write(newColorOneHEX)
		f.write("\n")
		f.write(newColorTwoHEX)
		f.write("\n")

		i += 1

	# CLOSE file:
	f.close()
	h += 1