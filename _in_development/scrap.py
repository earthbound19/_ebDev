import numpy as np
from PIL import Image

# slots for higher memory / use efficiency re: https://stackoverflow.com/a/49789270
class Coordinate:
	__slots__ = ["x", "y", "isAlive", "isConsumed", "unoccupiedNeighbors"]
	def __init__(self, x, y, isAlive, isConsumed, unoccupiedNeighbors):
		self.x = x;	self.y = y;	self.isAlive = isAlive;	self.isConsumed = isConsumed
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

# init. allCoordinates array:
for yCoord in range(0, width):
	for xCoord in range(0, height):
		allCoordinates.append(Coordinate(yCoord, xCoord, False, False, None))
# delete out-of-bounds values in that array (that result from the way a Coordinate object self-initializes unoccupiedNeighbors from x and y) :
# for yCoord in range(0, width):
	# print('allCoordinates at yCoord ', yCoord, ':')
	# for xCoord in range(0, height):
		# forf = 'nor'

# print('Intended bitmap width: ', width, '\nIntended bitmap height: ', height, '\nCoordinate objects in array allCoordinates:')
# for loopCoord in allCoordinates:
	# print(loopCoord.x, loopCoord.y, loopCoord.isAlive, loopCoord.isConsumed, loopCoord.unoccupiedNeighbors)
	
arr = np.ones((height, width, 3)) * [157, 140, 157]
# im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
# im.save('tstScrap-py.png')
print(arr)