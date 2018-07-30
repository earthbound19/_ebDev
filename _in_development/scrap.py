import datetime, random, argparse, ast, os.path
import numpy as np
from PIL import Image
import sys

backgroundColor = [-3,8,267]

arr = np.ones((4, 5, 3)) * backgroundColor
print(arr)


# for a, b in enumerate(arr):
	# for i, j in enumerate(b):
		# arr[a][i] = np.clip(arr[a][i], 0, 255)

arr = np.clip(arr, 4, 50)

print('wat ', arr)

# np.clip(arr, 0, 255)



# newColor = previousColor + np.random.randint(-rshift, rshift+1, size=3) / 2