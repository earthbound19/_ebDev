# slots for higher memory / use efficiency re: https://stackoverflow.com/a/49789270
class Coordinate:
	__slots__ = ["x", "y", "isAlive", "isConsumed", "unoccupiedNeighbors"]
	def __init__(self, x, y, isAlive, isConsumed, unoccupiedNeighbors):
		self.x = x
		self.y = y
		self.isAlive = isAlive
		self.isConsumed = isConsumed
		self.unoccupiedNeighbors = [ [x -1, y -1], [x -1, y], [x -1, y +1], [x, y-1], [x, y+1], [x+1, y-1], [x+1, y], [x+1, y+1] ]		# List of possible neighbor relative coordinates for any coordinate (unless the coordinate is at a border):
			# x-1, y-1	:	left, up		ONE
			# x-1, y	:	left			TWO
			# x-1, y+1	:	left, down		THREE
			# x, y-1	:	up				FOUR
			# x, y+1	:	down			FIVE
			# x+1, y-1	:	right, up		SIX
			# x+1, y	:	right			SEVEN
			# x+1, y+1	:	right, down		EIGHT
			#
			# I DOUBLE-CHECKED and verified that all intialized values in self.unoccupiedNeighbors in this class initalize according to this list.

# p1 = Coordinate
p1 = Coordinate(5, 31, False, False, None)
p2 = Coordinate(5, 8, False, False, None)
p3 = Coordinate(381, 804, False, False, None)

listOfPoints = [p1, p2, p3]

p2.unoccupiedNeighbors.remove([4,8])
p2.unoccupiedNeighbors.pop(); p2.unoccupiedNeighbors.pop(); p2.unoccupiedNeighbors.pop(); p2.unoccupiedNeighbors.pop()
# print('wut', p2.unoccupiedNeighbors)
# print('That is all:')
for element in listOfPoints:
	print('values: ', element.x, element.y, element.isAlive, element.isConsumed, element.unoccupiedNeighbors)