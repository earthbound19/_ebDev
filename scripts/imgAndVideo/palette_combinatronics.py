# DESCRIPTION
# Creates all possible combinatations of colors of subset size N from an RGB hex palette file (`.hexplt` format), and writes them to a subfolder and files named after: the palette, the size of the subset (N), and the number for the combination in the sequence of all possible combinations.

# DEPENDENCIES
# Python 3 with itertools module installed.

# WARNING
# This script overwrites any target files that already exist without warning.

# USAGE
# Run this script through a python interpreter, with these parameters:
# - sys.argv[1] the source palette file (hexplt format) to get combinations from
# - sys.argv[2] how many colors to have in the set for each combination
# For example, to calculate and write all possible 3-combinations from the file RAHfavoriteColorsHex.hexplt, run:
#    python path/to_this/palette_combinations.py RAHfavoriteColorsHex.hexplt 3
# NOTES
# - As this produces combinations, order is not considered. For example, ['A', 'B', 'C'] is not ever repeated with the members of the set in a different order, like ['A', 'C', 'B']. In combinations, sets with the same elements but in different orders are considered identical for cobminatorial purposes.
# - If you want permutations (where members of a set in different orders are included), change the itertools.combinations function call (find it in the source code) to be itertools.permutations, but be warned that with increased source set size the result set becomes orders of magnitude larger very quickly.


# CODE
import itertools, sys, re, os

if len(sys.argv) > 1:       # positional parameter 1
    sourcePaletteFileName = sys.argv[1]
else:
    print('\nNo parameter 1 (source .hexplt palette file one) passed to script. Exit.')
    sys.exit(1)
if len(sys.argv) > 2:       # positional parameter 2
    howManyColors = int(sys.argv[2])
else:
    print('\nNo parameter 2 (set size of color combinations to get) passed to script. Exit.')
    sys.exit(1)

f = open(sourcePaletteFileName, "r")
colors_list = list(f.read().splitlines())
f.close()

color_combinations = list(itertools.combinations(colors_list, howManyColors))
zeroPadToDigits = len(str(len(color_combinations)))       # That was interesting :)
strNumPalettesToCreate = str(len(color_combinations))

# subfolder_name structure: = <sourceFileBaseName>_<N>_combo_<CombinationNumber>.hexplt
sourcePaletteFileBaseName = re.sub('\..*', '', sourcePaletteFileName)
subdirName = sourcePaletteFileBaseName + '_' + str(howManyColors) + '_combos'

if not os.path.isdir(subdirName):
    os.mkdir(subdirName)
for idx, data in enumerate(color_combinations):
    # if not idx + 1 it starts at zero:
    comboNumberStr = str(idx + 1).zfill(zeroPadToDigits)
    targetFileName = subdirName + '/' + sourcePaletteFileBaseName + '__' + str(howManyColors) + '_combo_' + comboNumberStr + '.hexplt'
    print("Generating palette " + comboNumberStr + " of " + strNumPalettesToCreate + " . . .")
    paletteList = ''
    for element in data:
        paletteList += element + '\n'
    f = open(targetFileName, "w")
    f.write(paletteList)
    f.close()

print("\n~\nDONE. All possible " + str(howManyColors) + "-color combinations from palette " + sourcePaletteFileName + " (" + strNumPalettesToCreate + " palettes) have been written to folder " + subdirName + ".")