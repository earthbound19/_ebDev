import numpy as np
from PIL import Image
import sys

# slots for higher memory / use efficiency re: https://stackoverflow.com/a/49789270
class Coordinate:
	__slots__ = ["x", "y", "maxX", "maxY", "RGBcolor", "isAlive", "isConsumed", "unoccupiedNeighbors"]
	def __init__(self, x, y, maxX, maxY, RGBcolor, isAlive, isConsumed, unoccupiedNeighbors):
		self.x = x;	self.y = y;	self.RGBcolor = RGBcolor; self.isAlive = isAlive;	self.isConsumed = isConsumed
		# if x >= maxX-1:	x = x-1; print('x changed to', x)
		self.unoccupiedNeighbors = [ [x -1, y -1], [x -1, y], [x -1, y +1], [x, y-1], [x, y+1], [x+1, y-1], [x+1, y], [x+1, y+1] ]		# List of possible neighbor relative coordinates for any coordinate (unless the coordinate is at a border):
			# x-1, y-1	:	left, up		ONE
			# x-1, y	:	left			TWO
			# x-1, y+1	:	left, down		THREE
			# x, y-1	:	up				FOUR
			# x, y+1	:	down			FIVE
			# x+1, y-1	:	right, up		SIX
			# x+1, y	:	right			SEVEN
			# x+1, y+1	:	right, down		EIGHT
			# -~-~ I DOUBLE-CHECKED and verified that all intialized values in self.unoccupiedNeighbors in this class initalize according to this list.

# object creation and manipulation tests:
# p1 = Coordinate(5, 31, False, False, None)
# p1.unoccupiedNeighbors.remove([4,32]); p1.unoccupiedNeighbors.pop(); p1.unoccupiedNeighbors.pop()
# print('wut', p1.unoccupiedNeighbors)

height = 4; width = 5; allCoordinates = []
mediumPurplishGray = [157, 140, 157]

# init. allCoordinates array:
for yCoord in range(0, width):
	for xCoord in range(0, height):
		allCoordinates.append(Coordinate(yCoord, xCoord, width, height, np.random.randint(0, 255, size=3), False, False, None))

# print('Intended bitmap width: ', width, '\nIntended bitmap height: ', height, '\nCoordinate objects in array allCoordinates:')
for loopCoord in allCoordinates:
	# if loopCoord.x >= 0:
	print(loopCoord.x, loopCoord.y, loopCoord.RGBcolor)
	# print(loopCoord.x, loopCoord.y, loopCoord.unoccupiedNeighbors)
	# print(loopCoord.x, loopCoord.y, loopCoord.RGBcolor, loopCoord.isAlive, loopCoord.isConsumed, loopCoord.unoccupiedNeighbors)

# arr = np.ones((height, width, 3)) * mediumPurplishGray
# im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
# im.save('tstScrap-py.png')
# print(arr)

print('check what was just printed to match the following:')
imgArray = []
# Relies on this script never making allCoordinates longer than width * height (so, never an out of index error) :
for i in range(0, len(allCoordinates), width-1):
	for j in range(0, height):
		print(allCoordinates[i+j].x, allCoordinates[i+j].y, allCoordinates[i+j].RGBcolor)

