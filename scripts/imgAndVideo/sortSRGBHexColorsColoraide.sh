# DESCRIPTION
# Sorts sRGB hex colors in file $1 by next nearest starting on color $2 (optional; default first color in list), in HCT color space, printing to stdout. Can be overriden with other sort options; see URL in USAGE

# DEPENDENCIES
# Python with coloraide_extras library installed (which I believe in turn installs coloraide as a dependency)

# WARNINGS
# 

# USAGE
# Run with these parameters:
# - -i | --inputfile REQUIRED. File name of source hexplt (sRGB hex color flat file list) to sort.
# - [-s | --startcolor] OPTIONAL. sRGB hex color code to begin sorting on, e.g. '#894a5e' or 'f800fc. If omitted, the first color in the source file is used. This may be a color that is not in the source list, e.g. black to start sort on the darkest found color, or white to start sort on the lightest/brightest found color -- even if black or white is not in the original list.
# - [-c | --colorspace] OPTIONAL. coloraide color space keyword to sort in, for example 'hct', 'ok', or '2000'. Defaults to 'hct' if omitted. See the `Name` field for various spaces listed as supported at https://facelessuser.github.io/coloraide/distance/
# - [-k | --keepduplicatecolors OPTIONAL. Keep duplicate colors. Default off (duplicate colors are eliminated).
# - [-w | --overwritesourcefile OPTIONAL. Overwrite source file with result. WARNING: this clobbers it (data loss of initial state). As this permanently alters the source file with no going back (including the possibility of emptying and failing to repopulate it if there's some error), use this option carefully. For example only use this option with disposable, backed up or version-controlled files. Also, with this option the result is not written to stdout, only written back over the source file.
# NOTE: optional short switches MUST (annoyingly) not have a space after them and the parameter. The parameter may be clarified by surrounding it with quote marks; see below examples. Alternately, long options may be used and followed by = before the option value. See examples below for this also.
# EXAMPLES
# For example, to sort a palette file named colors.hexplt in the default color space, and print the result to stdout, run:
#    SortSRGBHexColorsColoraide.sh -i'colors.hexplt'
# To sort that starting on the color black (whether that color is in the palette or not), run:
#    SortSRGBHexColorsColoraide.sh --inputfile=colors.hexplt --startcolor=#000000
# To sort that starting on the color black (whether that color is in the palette or not), and sort in oklab color space, run:
#    SortSRGBHexColorsColoraide.sh -i'colors.hexplt' -s'#000000' -c'ok'
# To do the same but sort on the default color (the first in the source file), omit the -s switch, so run:
#    SortSRGBHexColorsColoraide.sh -i'colors.hexplt' -c'ok'
# To keep any duplicate colors, use -k:
#    SortSRGBHexColorsColoraide.sh -i'colors.hexplt' -k
# To record the result to a file, redirect stdout:
#    SortSRGBHexColorsColoraide.sh -i'colors.hexplt' -k > output.hexplt

# NOTE TO SELF: don't ever write a script that has meta parameter passing like that $searchColor after the Python call again?


# CODE
function print_halp {
	echo "Please read the USAGE comments in this script."
}

function check_space_in_opt_arg {
	if [ "$2" == "" ]; then echo "ERROR: No value or a space (resulting in empty value) passed after optional switch $1. Pass a value without any space after $1 (for example: $1""value""), or if a default is available, don't pass $1, and the default will be used. Exit."; exit 4; fi;
}

PROGNAME=$(basename $0)
OPTS=`getopt -o hi:s::c::kw --long help,inputfile:,startcolor::,colorspace::,keepduplicatecolors,overwritesourcefile -n $PROGNAME -- "$@"`

eval set -- "$OPTS"

# SET DEFAULTS that will or may be overriden here; this is weird territory where we're checking these values as interpretive (bash-printed $) prints from bash:
sourceFileName=
searchColor=
sortingColorSpace='hct'		# or 'ok', or '2000', etc. See the `Name` field for various spaces listed as supported at https://facelessuser.github.io/coloraide/distance/
keepDuplicateColorsBashVal=no
overWriteSourceFile=no
while true; do
  case "$1" in
    -h | --help ) print_halp; exit 0 ;;
    -i | --inputfile ) sourceFileName=$2; shift; shift ;;
    -s | --startcolor ) check_space_in_opt_arg $1 $2; searchColor=$2; shift; shift ;;
    -c | --colorspace ) check_space_in_opt_arg $1 $2; sortingColorSpace=$2; shift; shift ;;
    -k | --keepduplicatecolors ) keepDuplicateColorsBashVal='yes'; shift ;;
    -w | --overwritesourcefile ) overWriteSourceFile='yes'; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done
# dev debug / help print only, comment out for commit / production:
# echo sourceFileName is $sourceFileName
# echo searchColor is $searchColor
# echo sortingColorSpace is $sortingColorSpace
# echo keepDuplicateColorsBashVal is $keepDuplicateColorsBashVal

# Throw error and exit if mandatory argument(s) missing:
if [ ! $sourceFileName ]; then echo "No sourceFileName -i passed to script. See USAGE in comments in script. Exit."; exit 1; fi

python -c "
import sys, re
from coloraide_extras.everything import ColorAll as Color
from more_itertools import unique_everseen

pattern = r'#[0-9a-fA-F]{6}'
# Load sRGB hex colors from sourcePaletteFileName by pattern match (allows comments and other things in file) :
colors = []
with open(\"$sourceFileName\", \"r\") as file_list:
    for line in file_list:
        match = re.search(pattern, line)
        if match:
            append_str = str(match.group())
            # convert to lowercase, to avoid a \"ValueError: list.remove(x): x not in list error\" if there are mixed cases in the source data:
            append_str = append_str.lower()
            colors.append(append_str)
file_list.close()

# for color in colors:
    # print(color)

# - make an empty intended final list (a list to build)
finalList = []
# - set first color in list as compare color IF no color specified for start
# quasi-import value from bash here, very weirdly; I think this is code smell; it only works if I use escaped double quote marks \" around the bash variable:
if \"$searchColor\" != '':
    pySearchColor = \"$searchColor\"
else:
    pySearchColor = colors[0]
# strip any gunk around that and reduce it to only six hex digits; throw an error and exit if its rong format:
# Regex to match exactly 6 consecutive hex digits (case insensitive)
found = re.search(r'[0-9a-fA-F]{6}', pySearchColor)
# If a match was not found, throw an error and exit. It would be nice to play the Resetty music here.
if not found:
    print(\"\nERROR: -s | --startcolor or first color\", pySearchColor, \"from input file not a valid sRGB hex color code. Exit 2.\n\")
    sys.exit(2)
else:
	pySearchColor = \"#\" + found.group(0)
# only add pySearchColor (start search color) to the final list if it was on the original list, otherwise do not add it:
if pySearchColor in colors:
    finalList.append(pySearchColor)
# - remove search color from original list (if it is in it)
if pySearchColor in colors: colors.remove(pySearchColor)
# - iterating over list; reapeating until the list is empty (as we remove items from it via the following, until it is empty) :
while (len(colors)) > 0:
    # - use the closest function of the compare color, passing list to it (to find nearest color), AND CONVERT THE RESULT BACK TO HEX
    nearest = Color(pySearchColor).closest(colors, method=\"$sortingColorSpace\").to_string(hex=True)
    # - add the matching item to the next element in the final list
    finalList.append(nearest)
    # - compare the found nearest color to the list and remove the matching item
    colors.remove(nearest)
    # - set the search color to this newest nearest found color
    pySearchColor = nearest

# - remove duplicates from result unless a value of 'yes' is set to a variable saying to (effectively a bool taken in from bash) :
# again weirdly import a bash variable; the way this ends up passed to the interpreter, it can be if 'yes' != 'yes':
if \"$keepDuplicateColorsBashVal\" != 'yes':
	finalList = list(unique_everseen(finalList))

# - print the final list, optionally to the original file if told to.
if \"$overWriteSourceFile\" == 'yes':
    # blank and then ovewrite the source file with the modified palette; by not using the 'a' flag, we write nothing to it (empty it) :
    print(\"~\nWill overwrite $sourceFileName with sorted palette.\")
    open(\"$sourceFileName\", \"w\").close()
    # ovewrite it with modified list:
    with open(\"$sourceFileName\", \"a\") as file_list:
        for color in finalList:
            lineToWrite = str(color) + \"\n\"
            file_list.write(lineToWrite)
    file_list.close()
    print(\"Done.\n~\")
else:
    for color in finalList:
        print(color)
"