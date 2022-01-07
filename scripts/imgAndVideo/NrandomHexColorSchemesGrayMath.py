# DESCRIPTION
# Generates a random hex color scheme of file format .hexplt, which is a plain text file with one hex color per line. The generated colors are constructed according to a color theory given in Itten\'s "ELEMENTS OF COLOR," which states that color combinations tend to be more pleasing to the human eye if, when the colors are mixed (by substractive color mixing), they make gray. This script makes colors that are mixed by additive light (RGB), but the principle is the same and the results have generally verified the theory. EDIT: except not. The way this script is constructed you won't generally ever get brilliant intensity colors by default. I'm not sure anymore things would combine to a tint of gray. You'll almost always want to further modify any resulting palettes that you like; they would be a basis for further work. This is a creative brainstorming tool at best.

# USAGE
# Run this script through a Python interpreter, with the `--help` parameter or examine the `parser = argparse` code in this script:
#    python path/to_this/script/NrandomHexColorSchemesGrayMath.py --help
# -- and examine the help print. Or examine the `help=` strings in the source code.


# CODE
import datetime, random, os.path, argparse

parser = argparse.ArgumentParser(description='Generates a random hex color scheme of file format .hexplt, which is a plain text file with one hex color per line. The generated colors are constructed according to a color theory given in Itten\'s "ELEMENTS OF COLOR," which states that color combinations tend to be more pleasing to the human eye if, when the colors are mixed (by substractive color mixing), they make gray. This script makes colors that are mixed by additive light (RGB), but the principle is the same and the results have generally verified the theory.')
parser.add_argument('-n', '--numschemes', type=int, default=36, help='How many color schemes to generate. Default 36.')
parser.add_argument('-g', '--grayhigh', type=int, default=222, help='Gray high threshold. No RGB-256 value will be higher than this number. Default 222. Range 0-255.')
parser.add_argument('-l', '--graylow', type=int, default=60, help='Gray low threshold. No RGB-256 value will be lower than this number. Default 60. Range 0-255. When the sum of any generated RGB values is less than this number, this script will stop generating colors.')

args = parser.parse_args()

nSchemes = args.numschemes; print('Will generate ', nSchemes, ' color schemes.')

grayHighThreshold = args.grayhigh
if grayHighThreshold > 255:
	grayHighThreshold = 255; print('Specified -g or --grayhigh was too high and is now adjusted to 255.')
if grayHighThreshold < 0:
	grayHighThreshold = 0; print('Specified -g or --grayhigh was too low and is now adjusted to 0.')
print('Gray high threshold is ', grayHighThreshold)

grayLowThreshold = args.graylow
if grayLowThreshold > 255:
	grayLowThreshold = 255; print('Specified -l or --graylow was too high and is now adjusted to 255.')
if grayLowThreshold < 0:
	grayLowThreshold = 0; print('Specified -l or --graylow was too low and is now adjusted to 0.')
print('Gray low threshold is ', grayLowThreshold)

# Randomly pick color values in the red, green and blue channels between grayHighThreshold and grayLowThreshold:
	# For the above values, try these:
	# Full light range -- you'll probably want to throw out some garish or otherwise unwanted results:
	# grayHighThreshold = 255; grayLowThreshold = 0
	# High-ish mid light range -- astonishingly unfailingly produces pleasing combinations:
	# grayHighThreshold = 212; grayLowThreshold = 96
	# Lower light range:
	# grayHighThreshold = 154; grayLowThreshold = 40

HEXColors = []

h = 0
while h < nSchemes:
	# Reset these (they are altered in the inner loop) :
	redHighThreshold=grayHighThreshold
	greenHighThreshold=grayHighThreshold
	blueHighThreshold=grayHighThreshold

	# Although this code at this writing doesn't ever change these:
	redLowThreshold=grayLowThreshold
	greenLowThreshold=grayLowThreshold
	blueLowThreshold=grayLowThreshold
	print('GENERATING new color sheme. redHighThreshold value is ', redHighThreshold)
	
	colorsCount = 0
	while 1:		# I'm certain a condition will be met that triggers a break statement in this otherwise infinite loop.
		# RED
		# If the value for redHighThreshold is less than redLowThreshold, swap them to avoid an error from the random.randint() call:
		if redHighThreshold < redLowThreshold:
			redHighThreshold, redLowThreshold = redLowThreshold, redHighThreshold
		newRedVal = random.randint(redLowThreshold,redHighThreshold)
		redHighThreshold = redHighThreshold - newRedVal
		print('redHighThreshold is ', redHighThreshold)
		
		# GREEN
		if greenHighThreshold < greenLowThreshold:
			greenHighThreshold, greenLowThreshold = greenLowThreshold, greenHighThreshold
		newGreenVal = random.randint(greenLowThreshold,greenHighThreshold)
		greenHighThreshold=(greenHighThreshold - newGreenVal)
		print('greenHighThreshold is ', greenHighThreshold)

		# BLUE
		if blueHighThreshold < blueLowThreshold:
			blueHighThreshold, blueLowThreshold = blueLowThreshold, blueHighThreshold
		newBlueVal = random.randint(blueLowThreshold,blueHighThreshold)
		blueHighThreshold=(blueHighThreshold - newBlueVal)
		print('blueHighThreshold is ', blueHighThreshold)
		
		# If the sum of newRedVal, newGreenVal and newBlueVal is less than or equal to grayLowThreshold, break out of this loop, as we have reached our lower desired light limit for colors; this means effectively don't generate colors anymore:
		RGBvalsList = [newRedVal, newGreenVal, newBlueVal]
		sumOfRGBvals = sum(RGBvalsList)
		# using args.graylow effectively as a constant--maybe it literally is? :	
		if sumOfRGBvals <= args.graylow:
			print('Sum of RGB values, ', sumOfRGBvals, ' is lower than -l or --graylow parameter (low gray threshold), ', args.graylow, '. Will stop generating colors. Made ', str(colorsCount), ' colors in this scheme.')
			break
		
		# Print color 1 RGB values in decimal to screen (for debugging):
		print('color ', str(colorsCount), ' RGB values: ', str(newRedVal), ' ', str(newGreenVal), ' ', str(newBlueVal))
		# Formatting converts decimal value to hex:
		newColorOneHEX = '#' + str.lower("%0.2X" % newRedVal) + str.lower("%0.2X" % newGreenVal) + str.lower("%0.2X" % newBlueVal)
		HEXColors.append(newColorOneHEX)
		colorsCount += 1
	# Create unique, date-time informative .hexplt file name.
	# The start of the file name is three-padded digits indicating how many colors are in the palette.
	# colorsCountStr = str(colorsCount)
	now = datetime.datetime.now()
	timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
	# Get a random string of lenght 3 with numbers and lowercase; re: https://stackoverflow.com/a/20688431/1397555
	rndStr = ('%03x' % random.randrange(16**3)).lower()
	colorsCountStr = str(colorsCount)
	hexpltFileName = colorsCountStr + '-' + timeStamp + '-' + rndStr + '.hexplt'
	print('hexpltFileName is', hexpltFileName)

	# Puts the full immediate path into a string; with help from: https://stackoverflow.com/a/2725195/1397555
	curDir=os.path.realpath('.')
	fullFilePath = curDir + '/' + hexpltFileName

	# OPEN file for writing:
	f = open(fullFilePath,'w+')

	print('Colors written to that file are:')
	for color in HEXColors:
		# WRITE to file:
		print(color)
		f.write(color)
		f.write('\n')
	# Empty the list:
	HEXColors[:] = []

	# CLOSE file:
	f.close()
	h += 1