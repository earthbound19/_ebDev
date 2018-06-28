# IN DEVELOPMENT.

# DESCRIPTION
# Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Output file names are random. Original colorFibers.py (of which this is an evolution) horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# USAGE
# python thisScript.py

# DEPENDENCIES
# python 3 with numpy and PIL modules

# TO DO
# - Instead of checking whether a coordinate has been used, SUBTRACT used coordinates from a list of coordinates, then randomly select coordinates from that reduced list! Except that I have to select a coordinate near the previous used coordinate--how do I use this subtractive approach yet still do that? Hmm..that may require serious data structure refactoring.
# - Clamp randomly generated colors that are out of gamut (back into the gamut) and/or select a new random walk origin when this happens.
# - Verify this makes pixels go up to the edge but not past.


# CODE
import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import sys		# Testing only: DELETE THIS LINE or comment out on commit!

# print('debug output:')
# GLOBAL VARIABLES
rshift = 23
height = 200
width = 400
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

# I could make these functions take and return tuples, but no. Syntaxy bleh. Re: https://stackoverflow.com/questions/1993727/expanding-tuples-into-arguments
# Function takes two int range parameters and returns two random ints within that range
def getRandomCoordinate(height, width):
	# Create a coordinate pair (of values) and initialize a used coordinate list with it; this will be our start point for "bacterial growth:"
	# range is zero to height-1 (not inclusive) :
	yCoord = np.random.randint(0, height)	# range is zero to height-1 (not inclusive)
	xCoord = np.random.randint(0, width)
	return yCoord, xCoord

# Function takes two ints and shifts them up or down one or not at all.
def mutateCoordinate(yCoordParam, xCoordParam):
	# Clamp range to what will prevent going past ceiling or floor:
	if yCoordParam < 1:
		yCoordParam = 1
	if yCoordParam > (height - 2):
		yCoordParam = (height - 2)
	yCoord = np.random.randint((yCoordParam - 1), (yCoordParam + 2))	#(upper range not inclusive)
	# Clamp range to either wall if it would go past either:
	if xCoordParam < 1:
		xCoordParam = 1
	if xCoordParam > (width - 2):
		xCoordParam = (width - 2)
	xCoord = np.random.randint((xCoordParam - 1), (xCoordParam + 2))	#(upper range not inclusive)
	return yCoord, xCoord
	

coordinate = getRandomCoordinate(height, width)		# Uh, I think python is dynamically making a tuple there.
previousCoordinate = coordinate
usedPixelsList = [coordinate]

# Searches n times for new coordinates, only adding ones to the used coordinate array which are not already in it; also pick a new random coordinate when we're stuck:
pixelAlreadyUsedCount = 0
for i in range(0, 80000):
	# print('Previous coordinate is ', previousCoordinate)
	# Mutate coordinate off previous coordinate:
	yCoord, xCoord = mutateCoordinate(previousCoordinate[0], previousCoordinate[1])
	coordinate = [yCoord, xCoord]
	# print('New prospective coordinate is ', coordinate)
	# Screen candidate new coordinate against array to see if it's already been used:
	pixelAlreadyUsed = False
	for j in usedPixelsList:
		if coordinate == j:
			pixelAlreadyUsed = True
			pixelAlreadyUsedCount += 1
			# print('pixelAlreadyUsedCount: ', pixelAlreadyUsedCount)
			# If we've tried and failed to find an unused coordinate 42 times, we're clearly stuck, so pick a new random origin:
			if pixelAlreadyUsedCount >= 42:
				coordinate = getRandomCoordinate(height, width)
				previousCoordinate = coordinate
			# matchedCoordinate = coordinate
	# If the randomly chosen coordinate has not been used before, use it and add it to the used array; otherwise do nothing and the outer loop will continue the search:
	if pixelAlreadyUsed == False:
		usedPixelsList.append(coordinate)
		previousCoordinate = coordinate
		arr[yCoord][xCoord] = arr[yCoord][xCoord] + np.random.randint(-rshift, rshift+1, size=3)
		# print(arr[yCoord][xCoord])
		# print('Appended new unused coordinate ', coordinate, ' to usedPixelsList.')
	# else:
		# print('Already used coordinate found was ', matchedCoordinate)

im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
im.save('tst.png')

# Optionally print the RGB values array:
# print('RGB values array:\n', arr)

