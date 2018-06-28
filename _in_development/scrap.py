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

for i, j in enumerate(arr[0]):
	for x, y in enumerate(j):
		print('i[', i, '][', x, '] value: ', j)



# print(arr)



# delete list elements, re: https://campus.datacamp.com/courses/intro-to-python-for-data-science/chapter-2-python-lists?ex=15
x = ["a", "b", "c", "d"]
del(x[1])

# 
# remove list item re: https://www.quora.com/How-do-I-remove-an-item-from-a-python-list
# The cleanest one might be your_list.remove(item), quite close to your_list.pop(item_index). -- remove item removes any (all?) matching elements: https://www.tutorialspoint.com/python/list_remove.htm
# aList = [123, 'xyz', 'zara', 'abc', 'xyz'];
# aList.remove('xyz');
# print "List : ", aList
# aList.remove('abc');
# print "List : ", aList
# elucidated more simply here: https://stackoverflow.com/questions/2793324/is-there-a-simple-way-to-delete-a-list-element-by-value