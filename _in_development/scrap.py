import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import sys
import colorpoop as cp	# That's a custom import in this case from a local file.


height = 3; width = 5; allCoordinates = []
mediumPurplishGray = [157, 140, 157]

# init. allCoordinates array:
for xCoord in range(0, width):
	for yCoord in range(0, height):	# RGBcolor can also be initialized with: np.random.randint(0, 255, size=3)
		allCoordinates.append(cp.coordinate(xCoord, yCoord, width, height, np.random.randint(0, 255, size=3), False, False, None))

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

print('moar test prints:')
# print( allCoordinates[3].emptyNeighbors )

thisThing = allCoordinates[3].getRNDemptyNeighbors()
print(thisThing)