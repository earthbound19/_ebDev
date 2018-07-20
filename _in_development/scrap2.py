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


# Function takes two ints and shifts each up or down one or not at all.
def mutateCoordinate(xCoordParam, yCoordParam):
	xCoord = np.random.randint((xCoordParam - 1), xCoordParam + 2)
	yCoord = np.random.randint((yCoordParam - 1), yCoordParam + 2)
	# if necessary, move results back in range:
	if (xCoord < 0):
		xCoord = 0
	if (xCoord > (width - 1)):
		xCoord = (width - 1)
	if (yCoord < 0):
		print('yCoord < !; is: ', yCoord)
		yCoord = 0
		print('now yCoord ', yCoord)
	if (yCoord > (height - 1)):
		# print('yCoord > !; is: ', yCoord, '(height - 1 is: ', (height - 1), ')')
		yCoord = (height - 1)
		# print('now yCoord ', yCoord)
	return xCoord, yCoord

for i in range(0, 20):
	falf, myeargh = mutateCoordinate(width, height)
	# print(width, ' , ', falf, ' : ', height, ', ', myeargh)

sys.exit()

# CONTINUE loop control examples:
for i in range(0, 10):
	if i == 5:
		continue
	print(i)

var = 10
while var > 0:              
   var = var -1
   if var == 5:
      continue
   print('Current variable value :', var)
print('Good bye!')