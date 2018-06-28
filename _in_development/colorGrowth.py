# IN DEVELOPMENT.

# DESCRIPTION
# Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Output file names are random. Original colorFibers.py (of which this is an evolution) horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# USAGE
# python thisScript.py

# DEPENDENCIES
# python 3 with numpy and PIL modules


# CODE
import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import sys		# Testing only: DELETE THIS LINE or comment out on commit!

height = 4
width = 16
colorbase = [157, 140, 157]		# A list of three values, or a "triplet" (purple gray)
# ((height, width, rgb_triplet)) :
arr = np.ones((height, width, 3)) * colorbase
noir = [0, 0, 0]	# Black

# NOTES
# print(arr) prints 4 elements, each with 14 elements, each a triplet
# len(arr) returns 4 (the list is 4 elements long)

# print(arr[0]) prints list 0, with 14 elements of triplet values
# len(arr[0]) prints list 0 of 14 elements of triplet values

# print(arr[0][0]) prints a triplet of values
# print(len(arr[0][0])) prints 3, the number of elements in that list (a triplet)

# print(arr[0][0][1]) returns 140 (second value of triplet in list 0 of list 0)

# TESTING ONLY:
# for x in arr:
# 	print('x')
# 	for y in x:
# 		print('y in x:', y[0], ' ', y[1], ' ', y[2])

def getRandomCoordinate(height, width):
	# Create a coordinate pair (of values) and initialize a used coordinate list with it; this will be our start point for "bacterial growth:"
	# range is zero to height-1 (not inclusive) :
	yCoord = np.random.randint(0, height)	# range is zero to height-1 (not inclusive)
	xCoord = np.random.randint(0, width)
	# yCoord = width
	# xCoord = width - 1
	# if xCoord < 0:
		# xCoord = width-1
	return yCoord, xCoord

coordinate = getRandomCoordinate(height, width)
previousCoordinate = coordinate
usedPixelsList = [coordinate]
print(usedPixelsList)

paintNewPixel = False
# Developing algo. The following searches 300 times for new coordinates, only adding ones to the used coordinate array which are not already in it:
for i in range(0, 8):
	# At this writing, the next line moves the coordinate one pixel vertically (y - 1) and zeros it if that makes it less than zero:
	yCoord = previousCoordinate[0] - 1
	if yCoord < 0:
		yCoord = 0
	xCoord = previousCoordinate[1]
	coordinate = [yCoord, previousCoordinate[1]]
	print('Previous coordinate is ', previousCoordinate)
	# Screen against array for whether the randomly chosen coordinate has been used:
	pixelAlreadyUsed = False
	for j in usedPixelsList:
		if coordinate == j:
			pixelAlreadyUsed = True
			# matchedCoordinate = coordinate
	# If the randomly chosen coordinate has not been used before, use it and add it to the used array; otherwise do nothing and the outer loop will continue the search:
	if pixelAlreadyUsed == False:
		usedPixelsList.append(coordinate)
		previousCoordinate = coordinate
		arr[yCoord][xCoord] = noir
		# print('Appended new unused coordinate ', coordinate, ' to usedPixelsList.')
	# else:
		# print('Already used coordinate found was ', matchedCoordinate)

im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
im.save('tst.png')

