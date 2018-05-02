# IN DEVELOPMENT. AT THIS WRITING

# DESCRIPTION
# Generates a random hex color scheme of file format .hexplt (named after the date and time and a few random characters), which is a plain text file with one hex color per line. Modeled after a color theory given in Itten's "ELEMENTS OF COLOR," which states that color combinations tend to be more pleasing to the human eye if, when the colors are mixed (by substractive color mixing), they make gray.

# USAGE
# Until I paramaterize this script, hack the initialization values for:
# grayHighThreshold
# grayLowThreshold
# numColorPairs
# -- and run this script:
# python /path/toThisScript/NrandomHexColorSchemesGrayMath.py

# TO DO
# Let this take parameters for number of palettes to create and number of colors per palette (with randomization for the latter?)


# CODE
import datetime
import random
import os.path

# Randomly pick color values in the red, green and blue channels between these numbers:
grayHighThreshold = 222; grayLowThreshold = 60
	# For the above values, try these:
	# Full light range -- you'll probably want to throw out some garish or otherwise unwanted results:
	# grayHighThreshold = 255; grayLowThreshold = 0
	# High-ish mid light range -- astonishingly unfailingly produces pleasing combinations:
	# grayHighThreshold = 212; grayLowThreshold = 96
	# Lower light range:
	# grayHighThreshold = 154; grayLowThreshold = 40

redHighThreshold=grayHighThreshold
greenHighThreshold=grayHighThreshold
blueHighThreshold=grayHighThreshold

redLowThreshold=grayLowThreshold
greenLowThreshold=grayLowThreshold
blueLowThreshold=grayLowThreshold

HEXColors = []

# TO DO: make numColorPairs parametric.
numColorPairs = 2
print("Color pairs to generate: "); print(numColorPairs)

i=0
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
	newColorOneRGBprintStr = str(i) + ' ' + str(newRedLowVal) + ' ' + str(newGreenLowVal) + ' ' + str(newBlueLowVal)
	print(newColorOneRGBprintStr)
	# Formatting converts decimal value to hex:
	newColorOneHEX = "#" + str("%0.2X" % newRedLowVal) + str("%0.2X" % newGreenLowVal) + str("%0.2X" % newBlueLowVal)
	# Print color 2 RGB values in decimal:
	newColorTwoRGBprintStr = str(i + 1) + '  ' + str(newRedHighVal) + ' ' + str(newGreenHighVal) + ' ' + str(newBlueHighVal)
	print(newColorTwoRGBprintStr)
	newColorTwoHEX = "#" + str("%0.2X" % newRedHighVal) + str("%0.2X" % newGreenHighVal) + str("%0.2X" % newBlueHighVal)

	HEXColors.append(newColorOneHEX); HEXColors.append(newColorTwoHEX); 
	# Set reference (to be used in next iteration of this loop) to new vals:
	i+=1

# Create unique, date-time informative .hexplt file name.
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
# Halleluja that the following automagically change to a backslash when working with Windows' backwards ;) path conventions! :
fullFilePath = curDir + "/" + hexpltFileName

# OPEN file for writing:
f = open(fullFilePath,"w+")

print("Colors written to that file are:")
for color in HEXColors:
	# WRITE to file:
	print(color)
	f.write(color)
	f.write("\n")

# CLOSE file:
f.close()