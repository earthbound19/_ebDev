# IN DEVELOPMENT. AT THIS WRITING

# DESCRIPTION
# Generates random hex color schemes of file format .hexplt (randomly named), which are plain text files with one hex color per line. Employs a color theory given in Itten's "ELEMENTS OF COLOR" that color combinations tend to be more pleasing to the human eye which when mixed (by substractive color mixing) form gray.

# USAGE
# TO DO: make it work thusly:
# Invoke this script with 1 or 2 parameters, both optional:
# $1 How many such color schemes to generate. If not provided, one will be made.
# $2 The number of colors to have in the generated color scheme. If omitted, the script will randomly pick a number between 2 and 7.


# DEV NOTES
# Until I figure out how to get Python to look in other paths, invoke this script with:
# python /path/toThisScript/NrandomHexColorSchemesGrayMath.py


# CODE
import random
# Pixel stub:
grayHighThreshold=255
grayLowThreshold=23
minimumRangeDivisor=90

referenceRedVal = grayHighThreshold
referenceGreenVal = grayHighThreshold
referenceBlueVal = grayHighThreshold

# TO DO: make numColors parametric.
numColors = 3
HEXColors = []
i=0
while (i < numColors):
	# DESCRIPTION OF failed algorithm.
	# Tends to make monochrome color schemes:
	# - Start with a triplet of 127, 127, and 127 (256 / 2 - 1 for zero-index counting) for gray RGB
	# Subtract random numbers between 0-197 from each in the triple. The minuends are the values for one color, the subtrahends are the values for another.
	# - Repeat that with the substrahends as new minuends
	# - Do this N times until you have the desired number of colors.
	# IMPLEMENTATION
	# To preserve divisible space, the lowest possible randomly chosen new value shall be 1/Nth (1/percentileLowThreshold) of the maximum possible value.
	lowRangeRed = int(referenceRedVal / minimumRangeDivisor) + grayLowThreshold
	print 'lowRangeRed value is ', lowRangeRed, ' and referenceRedVal is ', referenceRedVal
	lowRangeGreen = int(referenceGreenVal / minimumRangeDivisor) + grayLowThreshold
	print 'lowRangeGreen value is ', lowRangeGreen, ' and referenceGreenVal is ', referenceGreenVal
	lowRangeBlue = int(referenceBlueVal / minimumRangeDivisor) + grayLowThreshold
	print 'lowRangeBlue value is ', lowRangeBlue, ' and referenceBlueVal is ', referenceBlueVal
	# Select new random RGB vals within that minimum range and the previous max:
	newRedVal = random.randint(lowRangeRed, referenceRedVal)
	newGreenVal = random.randint(lowRangeGreen, referenceGreenVal)
	newBlueVal = random.randint(lowRangeBlue, referenceBlueVal)
	# Convert those from int to hex before storing them:
	hexRed = "%0.2X" % newRedVal
	hexGreen = "%0.2X" % newGreenVal
	hexBlue = "%0.2X" % newBlueVal
	# print 'That is ', hexRed, hexGreen, hexBlue
	allHex = "#" + hexRed + hexGreen + hexBlue
	HEXColors.append(allHex)
	# Set reference (to be used in next iteration of this loop) to new vals:
	referenceRedVal = newRedVal
	referenceGreenVal = newGreenVal
	referenceBlueVal = newBlueVal
	i+=1

for colors in HEXColors:
	print(colors)