# DESCRIPTION
# Calls get_rnd_CCC_for_color_growth.py to get values to pass to color_growth.py's
# --CUSTOM_COORDS_AND_COLORS for a given image, then does that. The effect is
# to create a .cgp preset for and invoke a render to get color_growth.py's
# effect for so many coordinates of an arbitrary image.

# USAGE
# Expects two parameters:
# - $1 image file name. Should be in same directory script is called from. Paths
# to other files may work; dunno.
# - $2 number of random coordinates and colors at those coordinates to get and
# pass to color_growth.py's --CUSTOM_COORDS_AND_COLORS switch.
# Example:
# call_get_rnd_CCC_for_color_growth-py.sh deep-indigo-preset_lost.png 2355
# NOTE: you may wish to hack the additioanlParams variable at the start of the
# script for your purposes.


# CODE
additionalParams='--RSHIFT 2 --SAVE_EVERY_N 1440 --RAMP_UP_SAVE_EVERY_N True'

if ! [ "$1" ]
then
	printf "\nNo parameter \$1 (image file name) passed to script. Exit."
	exit
else
	inputFile=$1
	printf "\nInput file is $inputFile."
fi
if ! [ "$2" ]
then
	printf "\n\nNo parameter \$2 (number of rnd coordinates and colors to get) passed to script. Exit."
	exit
else
	numRNDcoordsToGet=$2
	printf "\n\nNumber of random coordinates with their colors to get is $numRNDcoordsToGet.\n\n"
fi

# CODE
pathToCCCgetterScript=`whereis get_img_RND_CCC_for_color_growth.py | gsed 's/get_img_RND_CCC_for_color_growth: \(.*\)/\1/g'`

var_CUSTOM_COORDS_AND_COLORS=`python $pathToCCCgetterScript $inputFile $numRNDcoordsToGet`

pathToColorGrowth_py=`whereis color_growth.py | gsed 's/color_growth: \(.*\)/\1/g'`

# some parsing error or summat leads to "out of bounds" error if we just run
# command directly; so write it to temp script, then execute temp script and
# del temp script:
echo "Writing command to temp script tmp_call_get_img_RND_CCC_for_color_growth-py-s_script__9MPZWXx2v6Cp.sh . . ."

echo "python $pathToColorGrowth_py $additionalParams $var_CUSTOM_COORDS_AND_COLORS" > tmp_call_get_img_RND_CCC_for_color_growth-py-s_script__9MPZWXx2v6Cp.sh

echo "Executing temp script . . ."
./tmp_call_get_img_RND_CCC_for_color_growth-py-s_script__9MPZWXx2v6Cp.sh

echo "Deleting temp script . . ."
rm ./tmp_call_get_img_RND_CCC_for_color_growth-py-s_script__9MPZWXx2v6Cp.sh

echo DONE.