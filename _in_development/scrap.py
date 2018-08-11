# doodle coding for colorGrowth.py development.

import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import sys

width = 5
height = 4
backgroundColor = [0,0,0]

# START COORDINATE CLASS
class Coordinate:
	# slots for allegedly higher efficiency re: https://stackoverflow.com/a/49789270
	__slots__ = ["YXtuple", "x", "y", "maxX", "maxY", "RGBcolor", "isAlive", "isConsumed", "emptyNeighbors"]
	def __init__(self, x, y, maxX, maxY, RGBcolor, isAlive, isConsumed, emptyNeighbors):
		self.YXtuple = (y, x)
		self.x = x; self.y = y; self.RGBcolor = RGBcolor; self.isAlive = isAlive;	self.isConsumed = isConsumed
		# Adding all possible empty neighbor values even if they would result in values out of bounds of image (negative or past maxX or maxY), and will check for and clean up pairs with out of bounds values after:
		tmpList = [ (x-1, y-1), (x-1, y), (x-1, y+1), (x, y-1), (x, y+1), (x+1, y-1), (x+1, y), (x+1, y+1) ]
		deleteList = []
		for element in tmpList:
			if -1 in element:
				deleteList.append(element)
# TO DO: debug whether I even need this; the print never happens:
		for element in tmpList:
			if (maxX+1) in element:
				deleteList.append(element)
		for element in tmpList:
			if (maxY+1) in element:
				deleteList.append(element)
		# reduce deleteList to a list of unique tuples (in case of duplicates, where duplicates could lead us to attempt to remove something that ins't there, which would throw an exception and stop the script) :
		deleteList = list(set(deleteList))
		# the deletions:
		for no in deleteList:
			tmpList.remove(no)
		# finallu initialize the intended object member from that built list:
		self.emptyNeighbors = list(tmpList)
	def getRNDemptyNeighbors(self):
		random.shuffle(self.emptyNeighbors)		# shuffle the list of empty neighbor Coordinates
		nNeighborsToReturn = np.random.random_integers(0, len(self.emptyNeighbors))		# Decide how many to pick
		rndNeighborsToReturn = []		# init an empty array we'll populate with neighbors and return
		# iterate over nNeighborsToReturn items in shuffled self.emptyNeighbors and add them to a list to return:
		for pick in range(0, nNeighborsToReturn):
			rndNeighborsToReturn.append(self.emptyNeighbors[pick])
		return rndNeighborsToReturn
# END COORDINATE CLASS

# START GLOBAL FUNCTIONS
# function takes two ints and shifts each up or down one or not at all. I know, it doesn't receive a tuple as input but it gives one as output:
def mutateCoordinate(xCoordParam, yCoordParam):
	xCoord = np.random.random_integers((xCoordParam - 1), xCoordParam + 1)
	yCoord = np.random.random_integers((yCoordParam - 1), yCoordParam + 1)
	# if necessary, move results back in range of the array indices this is intended to be used with (zero-based indexing, so maximum (n - 1) and never less than 0) :
	if (xCoord < 0):
		xCoord = 0
	if (xCoord > (width - 1)):
		xCoord = (width - 1)
	if (yCoord < 0):
		yCoord = 0
	if (yCoord > (height - 1)):
		yCoord = (height - 1)
	return [xCoord, yCoord]

arr = np.ones((height, width, 3)) * backgroundColor
# THAT ARRAY is organized as [down][across] OR [y][x] OR [height - n][width - n] OR [row][column]; re the following numpy / PIL-compatible list of lists of lists of numbers and debug print to help understand the structure:
arr[2][3] = [255,0,255]		# y (down) = 1, x (across) = 2 (actual coordinates are +1 each because of zero-based indexing)
for y in range(0, height):
	print('- y height (', height, ') iterator ', y, 'in arr[', y, '] gives:\n', arr[y])
	for x in range(0, width):
		print(' -- x width (', width, ') iterator ', x, 'in arr[', y, '][', x, '] gives:', arr[y][x])

# Duplicating that structure with a list of lists:
imgArr = []		# Intended to be a list of lists
for y in range(0, height):		# for columns (x) in row)
	tmpList = []
	for x in range(0, width):		# over the columns, prep and add:
		tmpList.append(Coordinate(x, y, width, height, backgroundColor, False, False, None))
	imgArr.append(tmpList)

# Printing the second to compare to the first for comprehension:
print('------------')
for y in range(0, height):
	print('-')
	for x in range(0, width):
		print(' -- imgArr[y][x].YXtuple (imgArr[', y, '][', x, '].YXtuple) is:', imgArr[y][x].YXtuple)

