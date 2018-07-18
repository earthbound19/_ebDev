# IN DEVELOPMENT. AT THIS WRITING, the core algorithm is in redevelopment, between headers so labeled, with the script exiting before the fully functional former algorithm starts.

# DESCRIPTION
# Renders a PNG image like colored, evolved bacteria (they produce different colors as they evolve) grown randomly over a surface. Output file names are random. Original colorFibers.py (of which this is an evolution) horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/

# USAGE
# python thisScript.py

# DEPENDENCIES
# python 3 with numpy and PIL modules

# TO DO:
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


	# DEBUGGING / REFERENCE:
	# Iterates through every datum in the three-dimensional list (array) :
	# for a, b in enumerate(arr):
	# 	print('- arr[', a, ']:\n', b)		# [ [0. 0. 0.] [0. 0. 0.] . . ]
	# 	for i, j in enumerate(b):
	# 		print('-- arr[', a, '][', i, ']:\n', arr[a][i])		# [0. 0. 0.]
	# 		for x, y in enumerate(j):
	# 			print('--- arr[', a, '][', i, '][', x, ']:\n', y)
	# 			felf = 'nor'
	# sys.exit()

	# delete list elements, re: https://campus.datacamp.com/courses/intro-to-python-for-data-science/chapter-2-python-lists?ex=15
	# x = ["a", "b", "c", "d"]
	# del(x[1])

	# remove list item re: https://www.quora.com/How-do-I-remove-an-item-from-a-python-list
	# The cleanest one might be your_list.remove(item), quite close to your_list.pop(item_index). -- remove item removes any (all?) matching elements: https://www.tutorialspoint.com/python/list_remove.htm
	# aList = [123, 'xyz', 'zara', 'abc', 'xyz'];
	# aList.remove('xyz');
	# print "List : ", aList
	# aList.remove('abc');
	# print "List : ", aList
	# elucidated more simply here: https://stackoverflow.com/questions/2793324/is-there-a-simple-way-to-delete-a-list-element-by-value


	# SPECULATIVE RE-WORKING DESCRIPTION OF ALGORITHM:
	#
	# - init list of lists of lists with RGB triplet
	# - initialize an unused coordinates list for desired size of image. make it mappable to that list of lists of lists of RGB triplets
	# - initialize empty used coordinates list
	# - set base color from script param
	# - set prev. base color from same script param

	# in a loop:
	# - check if unused coordinates list empty, and if not:
	# - get a random coordinate from that list (from function that gives that from a range) to start at
	# - mutate coordinate:
		# - check if coordinate is in unused coordinates list
		# - if so return to mutate color step
		# - if not mutate again
		# - if mutate fails N times return to get a random coordinate from that list step
	# - on mutate coordinate success:
	# - mutate color		(by rnd and avg rnd with prev. coord. color)
	# - set prev color to that new color
	# - write that new color to array of used coords
	# - REMOVE that coordinate from the unused coordinates list

	# ADVANCED ALGO will spawn coordinates that spawn other coordinates until they die (and iterate all existing living coordinates at once in the loop.


# BEGIN REDEVELOPMENT (NEW ALGORITHM).

# - init list of lists of lists with RGB triplet ALREADY DONE, ABOVE.
# - initialize an unused coordinates list for desired size of image. make it mappable to that list of lists of lists of RGB triplets
# IDLE session copy-paste demonstrating use of append and remove for arrays (or lists?), where remove() takes an element out of the list that matches a certain value (here, a certain set of values in a list in the list) :
# foo = []
# >>> foo.append([1,1])
# >>> foo
# [[1, 1]]
# >>> foo.append([1,2])
# >>> foo
# [[1, 1], [1, 2]]
# >>> foo.append([4,8])
# >>> foo
# [[1, 1], [1, 2], [4, 8]]
# >>> foo.remove([1,2])
# >>> foo
# [[1, 1], [4, 8]]

# END REDEVELOPMENT (NEW ALGORITHM).


# END SCRIPT RUN before so much former version of script reference to follow:
sys.exit()

# OLD, INEFFICIENT ALGORITHM.
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