# DESCRIPTION
# Prints RGB hex code values (in format #dddddd) for colors in hue steps of N, from 0 to 360. N is hard-coded to 16; the color space used is hard-coded to HCT. Hack the script to change those.

# USAGE
# - tweak the `steps` hard-coded variable and the color space name string passed to the Color() function per your wants. See coloriade documentation.
# - Run through a python interpreter without any parameters to this script:
#    python /path/to_this_script/print_color_wheel_steps.py
# NOTES
# - HCT ranges with the original javascript color materials library at npm @material/material-color-utilities were experimentally found by me to be: H: 0 - 360; C: 0 - 113; T: 0 - 100
# --BUT WITH COLORAIDE, they are: h 0 - 360; c 0 - 145; t 0 - 100
# re: https://facelessuser.github.io/coloraide/colors/hct/
# That's also the case with colorjs, re: https://apps.colorjs.io/picker/hct


# CODE
from coloraide_extras.everything import ColorAll as Color
import numpy
# To broaden the range of colors decrease the value of the "step" variable that follows, and conversely to tighten it, increase that value: 
# for a previous HCL experiment: step = 51
steps = 16
# for the way numpy.linspace returns exactly n elements, ask for n + 1 and then remove the last one:
steps = steps + 1
nums = list(numpy.linspace(0, 360, steps))
del nums[-1]
for h in nums:
    # print(h)
    this_color = Color('hct', [h, 145, 50], 1)
    print(this_color.convert('srgb').to_string(hex=True))