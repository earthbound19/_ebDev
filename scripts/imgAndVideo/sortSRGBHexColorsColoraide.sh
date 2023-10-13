# DESCRIPTION
# Sorts sRGB hex colors in file $1 by next nearest starting on color $2 (optional; default first color in list), in HCT color space (can be overriden with other sort options; see URL in USAGE)

# USAGE
# Run with these parameters:
# - $1 REQUIRED. File name of source hexplt (sRGB hex color flat file list) to sort.
# - $2 OPTIONAL. sRGB hex color code to begin sorting on, e.g. '#894a5e' (must be surrounded by quote marks). If omitted, the first color in the source file is used. To use $3 but not this, pass the word NULL for this ($2).
# - $3 OPTIONAL. coloraide color space keyword to sort in, for example 'hct', or '2000'. See https://facelessuser.github.io/coloraide/distance/
# For example:
#    SortSRGBHexColorsColoraide.sh colors.hexplt
#

# NOTE TO SELF: don't ever write a script that has meta parameter passing like that $searchColor after the Python call again?


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (File name of source hexplt (sRGB hex color flat file list) to sort) passed to script. Exit."; exit 1; else sourceFileName=$1; fi
if [ "$2" ] && [ "$2" != "NULL" ]; then searchColor="$2"; fi
if [ "$3" ]; then sortingColorSpace="$3"; else sortingColorSpace="hct"; fi
# echo sourceFileName is $sourceFileName
# echo searchColor is $searchColor
# echo sortingColorSpace is $sortingColorSpace

python -c "
import sys, re
from coloraide_extras.everything import ColorAll as Color

pattern = r'#[0-9a-fA-F]{6}'
# Load sRGB hex colors from sourcePaletteFileName by pattern match (allows comments and other things in file) :
colors = []
with open(\"$sourceFileName\", \"r\") as file_list:
    for line in file_list:
        match = re.search(pattern, line)
        if match:
            colors.append(match.group())

# for color in colors:
	# print(color)

# - make an empty intended final list (a list to build)
finalList = []
# - set first color in list as compare color IF no color specified for start
if len(sys.argv) > 1:       # positional parameter 1
    searchColor = str(sys.argv[1])
else:
    searchColor = colors[0]
# only add searchColor (start search color) to the final list if it was on the original list, otherwise do not add it:
if searchColor in colors:
    finalList.append(searchColor)
# - remove search color from compare list
colors.remove(searchColor)
# - iterating over list; reapeating until the list is empty (as we remove items from it via the following, until it is empty) :
while (len(colors)) > 0:
    # - use the closest function of the compare color, passing list to it (to find nearest color), AND CONVERT THE RESULT BACK TO HEX
    nearest = Color(searchColor).closest(colors, method=\"$sortingColorSpace\").to_string(hex=True)
    # - add the matching item to the next element in the final list
    finalList.append(nearest)
    # - compare the found nearest color to the list and remove the matching item
    colors.remove(nearest)
    # - set the search color to this newest nearest found color
    searchColor = nearest

# - print the final list
for color in finalList:
    print(color)
" $searchColor