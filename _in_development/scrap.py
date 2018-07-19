# import datetime, random, argparse, ast, os.path
import numpy as np
# from PIL import Image
import sys
import random

# colorbase = ast.literal_eval(args.colorbase)

# randomIndex = np.random.randint(0, unusedCoordsListSize)	# range is zero to unusedCoordsListSize-1 (not inclusive, and for zero-indexing we need that).

# def mutateCoordinate(xCoordParam):
# 	xCoord = np.random.randint((xCoordParam - 1), xCoordParam + 2)
# 	# yCoord = np.random.randint((yCoordParam - 1), yCoordParam + 2)
# 	return xCoord
# 
# for i in range(0, 26):
# 	thisInt = mutateCoordinate(1)
# 	print('1 ', thisInt)




sys.exit()

print('balf')

for i in range(0, 13):
	print('i is ', i)
	rnd = np.random.randint(0, 12)
	print('loop count i is ', i)
	if (rnd == 5):
		print('rnd == 5: ', rnd)
		break
	else:
		print('rnd != 5: ', rnd)
		continue

print('norf')