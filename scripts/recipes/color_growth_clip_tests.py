import itertools
import subprocess
import shlex
import numpy as np
import re

# build set of tuples we want to pass to the --GROWTH_CLIP switch of color_growth.py: 
original_set = {-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11}
original_tuples = itertools.permutations(original_set, 2)
clip_tuples = set()
for element in original_tuples:
    if element[0] < element[1] and element[1] > 0:
        clip_tuples.add(element)

# Invoke color_growth.py so many times with those tuples:
for element in clip_tuples:
    print('Attempting to load color_growth.py with:')
    print('  --CLIP_GROWTH', element)
    rgb_color_triplet = np.random.randint(0, 255 + 1, size=3)
    foreground_color = list(rgb_color_triplet)
    background_color = list(255 - rgb_color_triplet)
    # Inverts the color;
    #  subtracts all the elements of the numpy array from 255,
    #  returns that as a numpy array and converts it to a list
    background_color = re.sub(' ', '', str(background_color))
    foreground_color = re.sub(' ', '', str(foreground_color))
    command_string = 'python "C:\_ebDev\scripts\imgAndVideo\color_growth.py" --WIDTH 260 --HEIGHT 120 -q 1 -a 1 -b ' + background_color + ' -c ' + foreground_color + ' --RSHIFT 12 --GROWTH_CLIP "' + str(element) + '"'
    subprocess.call(shlex.split(command_string))
    print('Subprocess hopefully completed successfully.')