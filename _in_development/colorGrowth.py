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

parser = argparse.ArgumentParser(description='Renders an image like colored horizontal plasma fibers via python\'s numpy and PIL modules. Output file names are random. Horked and adapted from https://scipython.com/blog/computer-generated-contemporary-art/')
parser.add_argument('-n', '--numimages', type=int, default=7, help='How many images to generate. Default 7.')
parser.add_argument('-w', '--width', type=int, default=1200, help='Width of output image(s). Default 1200.')
parser.add_argument('-t', '--height', type=int, default=600, help='Height of output image(s). Default 600.')
parser.add_argument('-r', '--rshift', type=int, default=4, help='Vary R, G and B channel values randomly in the range negative this value or positive this value. Note that this means the range is rshift times two. Defaut 4. Ripped or torn looking color streaks are more likely toward 6 or higher.')
parser.add_argument('-c', '--colorbase', default='[157, 140, 157]', help='Base color that the image is initialized with, expressed as a python list or single number that will be assigned to every RGB value. If a list, put the parameter in quotes and give the RGB values in the format e.g. \'[256, 70, 70]\' for a deep red (Red = 256, Green = 70, Blue = 70). If a single number e.g. just 150, it will result in a medium-light gray of [150, 150, 150] where 150 is assigned to every Red, Green and Blue channel in every pixel in the first column of the image. All RGB channel values must be between 0 and 256. Default [157, 140, 157] (a medium-medium light, slightly violet gray). NOTE: unless until the color tearing problem is fixed, you are more likely to get a look of torn dramatically different colors the further away from nuetral gray your base color is.')

args = parser.parse_args()		# When this function is called, if -h or --help was passed to the script, it will print the description and all defined help messages.

numIMGsToMake, rshift, width, height = args.numimages, args.rshift, args.width, args.height
# Interpreting -c (or --colorbase) argument as python literal and assigning that to a variable, re: https://stackoverflow.com/a/1894296/1397555
colorbase = ast.literal_eval(args.colorbase)

print('Will generate ', numIMGsToMake, ' image(s).')

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

	# delete list elements by index, re: https://campus.datacamp.com/courses/intro-to-python-for-data-science/chapter-2-python-lists?ex=15
	# x = ["a", "b", "c", "d"]
	# del(x[1])
	# remove list item by index re: https://www.quora.com/How-do-I-remove-an-item-from-a-python-list
	# The cleanest one might be your_list.remove(item), quite close to your_list.pop(item_index). -- remove item removes any (all?) matching elements: https://www.tutorialspoint.com/python/list_remove.htm
	# aList = [123, 'xyz', 'zara', 'abc', 'xyz'];
	# aList.remove('xyz');
	# print "List : ", aList
	# aList.remove('abc');
	# print "List : ", aList
	# elucidated more simply here: https://stackoverflow.com/questions/2793324/is-there-a-simple-way-to-delete-a-list-element-by-value

	# ADVANCED ALGO will spawn coordinates that spawn other coordinates until they die (and iterate all existing living coordinates at once in the loop.


# BEGIN REDEVELOPMENT (NEW ALGORITHM).

# - init list of lists of lists with RGB triplet ALREADY DONE, ABOVE.
# - initialize an unused coordinates flat list for desired size of image. make it mappable to that list of lists of lists of RGB triplets
unusedCoords = []
		# list funtions I'll use are unusedCoords.append and unusedCoords.remove([1,2]) (where the parameter to .remove is a list to match and remove.
for yCoord in range(0, width):
	for xCoord in range(0, height):
		# print('yCoord ', yCoord, ' xCoord ', xCoord)
		unusedCoords.append([yCoord, xCoord])
# - initialize empty used coords list
usedCoords = []
# - initialize base color from script param
color = colorbase
# - initialize "previous" base color from script param
previousColor = color
# - check if unused coordinates list still has anything in it.
while unusedCoords:
# - .. if it does:
# - get a random coordinate:
	unusedCoordsListSize = len(unusedCoords)
	# The next two lines should be moved outside the while loop when coordinate mutation is working (or else the mutation will be effectively destroyed):
	randomIndex = np.random.randint(0, unusedCoordsListSize)	# range is zero to unusedCoordsListSize-1 (not inclusive, and for zero-indexing we need that).
	chosenCoord = unusedCoords[randomIndex]
	# - TO DO: mutate coordinate . .
		# - check if coordinate is in unused coordinates list
		# - if so return to mutate color step
		# - if not mutate again
		# - if mutate fails N times return to get a random coordinate from that list step
	# - TO DO: on mutate coordinate success:
	# - write that coordinate to list of used coordinates
	usedCoords.append(chosenCoord)
	# - IN PROGRESS: mutate color		(by rnd and avg rnd with prev. coord. color):
	arrYidx = chosenCoord[0]
	arrXidx = chosenCoord[1]
	newColor = previousColor + np.random.randint(-rshift, rshift+1, size=3) / 2
	# - write that color data to corresponding datum in list of lists of lists of RGB triplets
	arr[arrYidx][arrXidx] = newColor
	# - set prev color to that new color
	previousColor = newColor
	# - REMOVE that coordinate from the unused coordinates list
	unusedCoords.remove(chosenCoord)

print('usedCoords array contains: ', usedCoords)
print('unusedCoords array contains: ', unusedCoords)

print('painting array is:\n', arr)

# Create unique, date-time informative image file name.
now = datetime.datetime.now()
timeStamp=now.strftime('%Y_%m_%d__%H_%M_%S__%f')
rndStr = ('%03x' % random.randrange(16**3)).lower()
imgFileName = timeStamp + '-' + rndStr + '-colorGrowth-Py-rshift' + str(rshift) + '.png'

im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
im.save(imgFileName)

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