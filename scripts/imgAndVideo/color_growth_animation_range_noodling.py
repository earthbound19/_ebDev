# this test reads sys.argv[1], which is intended to be how many animation frames to make.
import numpy as np
import sys

animation_frames_n = int(sys.argv[1])

width = 1920
height = 1080

# parameters are: start, end, interval:
divisor = 1 / animation_frames_n
multipliers_range = tuple(np.arange(0, 1, divisor))
# multipliers_range_length = len(multipliers_range)
# print(multipliers_range_length)
# sys.exit()

for multiplier in multipliers_range:
    mod_w = width * multiplier
    mod_h = height * multiplier
    mod_area = mod_w * mod_h
    print(mod_area)