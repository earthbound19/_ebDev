import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import sys

# slots for higher memory / use efficiency re: https://stackoverflow.com/a/49789270
class Coordinate:
	__slots__ = ["x", "y", "maxX", "maxY", "RGBcolor", "isAlive", "isConsumed", "emptyNeighbors"]
	def __init__(self, x, y, maxX, maxY, RGBcolor, isAlive, isConsumed, emptyNeighbors):
		self.x = x;	self.y = y;	self.RGBcolor = RGBcolor; self.isAlive = isAlive;	self.isConsumed = isConsumed
		# Adding all possible empty neighbor values even if they would result in values out of bounds of image (negative or past maxX or maxY), and will check for and clean up pairs with out of bounds values after:
		tmpList = [ (x-1, y-1), (x-1, y), (x-1, y+1), (x, y-1), (x, y+1), (x+1, y-1), (x+1, y), (x+1, y+1) ]
			# List of possible neighbor relative coordinates for any coordinate (unless the coordinate is at a border):
			# x-1, y-1	:	left, up		ONE
			# x-1, y	:	left			TWO
			# x-1, y+1	:	left, down		THREE
			# x, y-1	:	up				FOUR
			# x, y+1	:	down			FIVE
			# x+1, y-1	:	right, up		SIX
			# x+1, y	:	right			SEVEN
			# x+1, y+1	:	right, down		EIGHT
			# -~-~ I DOUBLE-CHECKED and verified that all intialized values in tmpList in this class initalize according to this list.
		# make lists of all tuples that contain out of range values, then use the list to delete those tuples from the list of tuples; re: https://www.quora.com/How-do-you-search-a-list-of-tuples-in-Python
		deleteList = []
		for element in tmpList:
			if -1 in element:
				deleteList.append(element)
		for element in tmpList:		# TO DO: debug whether I even need this; the print never happens:
			if (maxX+1) in element:
				deleteList.append(element)
		for element in tmpList:
			if (maxY+1) in element:
				deleteList.append(element)
		# reduce deleteList to a list of unique tuples (in case of duplicates, which can lead us to attempt to remove something that ins't there, which throws an exception and stops the script) :
		deleteList = list(set(deleteList))
		# the deletions:
		for no in deleteList:
			tmpList.remove(no)
		# finallu initialize the intended object member from that built list:
		self.emptyNeighbors = list(tmpList)

height = 3; width = 5; allCoordinates = []
mediumPurplishGray = [157, 140, 157]

# init. allCoordinates array:
for xCoord in range(0, width):
	for yCoord in range(0, height):	# RGBcolor can also be initialized with: np.random.randint(0, 255, size=3)
		allCoordinates.append(Coordinate(xCoord, yCoord, width, height, np.random.randint(0, 255, size=3), False, False, None))

# test / debug information prints from that array:
print('Intended bitmap width: ', width, '\nIntended bitmap height: ', height, '\nCoordinate objects in array allCoordinates:')
for loopCoord in allCoordinates:
	# print(loopCoord.x, loopCoord.y, loopCoord.RGBcolor)
	print(loopCoord.x, loopCoord.y, loopCoord.emptyNeighbors)
	# print(loopCoord.x, loopCoord.y, loopCoord.RGBcolor, loopCoord.isAlive, loopCoord.isConsumed, loopCoord.emptyNeighbors)

# create numpy-compatible array (nparray is it called?) from allCoordinates:
imgArray = []
# # # Relies on this script never making allCoordinates longer than width * height (so, never an out of index error) :
for i in range(0, height):
	coordsRow = []
	for j in range(0, width):
		R = allCoordinates[i*width+j].RGBcolor[0]		# Somehow if I just use .RGBcolor it's wrapped in something that prints out as "array(..", so splitting out the elements of the list here.
		G = allCoordinates[i*width+j].RGBcolor[1]
		B = allCoordinates[i*width+j].RGBcolor[2]
		thisList = [R, G, B]
		coordsRow.append(thisList)
	imgArray.append(coordsRow)

# use that numpy array to create and save an image:
arr = np.asarray(imgArray)
im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
im.save('scrap-py-test.png')