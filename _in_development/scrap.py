import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import sys		# Testing only: DELETE THIS LINE or comment out on commit!

# print('debug output:')
# GLOBAL VARIABLES
rshift = 23
height = 4
width = 7
colorbase = [0, 0, 0]		# A list of three values, or a "triplet" (purple gray)
# ((height, width, rgb_triplet)) :
arr = np.ones((height, width, 3)) * colorbase

# Iterates through every datum in the three-dimensional list (array) :
# for a, b in enumerate(arr):
	# print('arr[', a, ']: ', b)		# [ [0. 0. 0.] [0. 0. 0.] . . ]
	# for i, j in enumerate(b):
		# print(' arr[', a, '][', i, ']: ', arr[a][i])		# [0. 0. 0.]
		# for x, y in enumerate(j):
			# print('  arr[', a, '][', i, '][', x, ']: ', y)

# algorithm description of that reworking in colorGrowth.py:
# - init list of lists of lists with RGB triplet
# - get random start coord (x y) from function that gives that from a range
# - set previous coordinate to current coordinate
# - add current coordinate to used pixels list
# # - in N iterations:
#  - mutate the coordinate
#  - check coordinate against used pixel list; if no match, use it (with mutated color), if match, don't, then repeat
#  - if that check happens N times, get a new random coordinate, then repeat

# speculative descriptive re-working of that algorithm:
# - init list of lists of lists with RGB triplet
# - make an unused coordinates list that's mappable to that list?
# - get a random coordinate from that list
# - set previous coordinate to that new random coordinate
# - REMOVE that coordinate from the unused coordinates list . .



# im = Image.fromarray(arr.astype(np.uint8)).convert('RGB')
# im.save('tst.png')

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