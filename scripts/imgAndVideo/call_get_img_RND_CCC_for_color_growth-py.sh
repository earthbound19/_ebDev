# DESCRIPTION
# Calls get_rnd_CCC_for_color_growth.py to get values to pass to color_growth.py's --CUSTOM_COORDS_AND_COLORS for a given image, then does that. The effect is to create a .cgp preset for and run a render to get color_growth.py's effect for so many coordinates of an arbitrary image.

# USAGE
# Run with these parameters:
# - $1 image file name. Should be in same directory script is called from. Paths to other files may work; dunno.
# - $2 number of random coordinates and colors at those coordinates to get and pass to color_growth.py's --CUSTOM_COORDS_AND_COLORS switch.
# - $3 OPTIONAL. Extra parameters in format acceptable to color_growth.py, surrounded by single (and/or double?) quote marks.
# Example command:
#    --RSHIFT 2 --SAVE_EVERY_N 1440 --RAMP_UP_SAVE_EVERY_N True
# If $3 is omitted default hard-coded values may be used (see "$3" parameter handling section of code).
# Example to obtain 2,355 random coordinates and colors from those coordinates from a .png image, with the extra parameters for $3:
#    call_get_rnd_CCC_for_color_growth-py.sh deep-indigo-preset_lost.png 2355 '--RSHIFT 2 --SAVE_EVERY_N 1440 --RAMP_UP_SAVE_EVERY_N True'
# NOTE
# You may hack the additionalParams variable at the start of the script for whatever default purposes you may want, but you might be better off calling this script with another script that customizes that, as it would override the defaults in this script if you change them in this script.


# CODE
if ! [ "$1" ]
then
	printf "\nNo parameter \$1 (image file name) passed to script. Exit."
	exit
else
	inputFile=$1
	printf "\nInput file is $inputFile."
fi
inputFileNoExt=$(echo "${inputFile%.*}")
if ! [ "$2" ]
then
	printf "\n\nNo parameter \$2 (number of rnd coordinates and colors to get) passed to script. Exit."
	exit
else
	numRNDcoordsToGet=$2
	printf "\n\nNumber of random coordinates with their colors to get is $numRNDcoordsToGet.\n\n"
fi
if ! [ "$3" ]
then
	additionalParams='--RSHIFT 2 --SAVE_EVERY_N 1440 --RAMP_UP_SAVE_EVERY_N True'
	printf "\n\nNo parameter \$3 (extra parameters for color_growth.py) passed to script. Defaulted to: $additionalParams"
else
	additionalParams=$3
	printf "\n\nParameter \$3 (extra parameters for color_growth.py) passed to script. Received and will be used as: $additionalParams"
fi

# At this writing, the full path to the script in my setup is the following, and for speed sake I can just uncomment the next line (and comment the line after it) :
# pathToCCCgetterScript='/c/_ebDev/scripts/imgAndVideo/get_img_RND_CCC_for_color_growth.py'
pathToCCCgetterScript=$(getFullPathToFile.sh get_img_RND_CCC_for_color_growth.py)

# ~in my setup I can uncomment the following and comment the line after it:
# pathToColorGrowth_py='/c/_ebDev/scripts/imgAndVideo/color_growth.py'
pathToColorGrowth_py=$(getFullPathToFile.sh color_growth.py)

var_CUSTOM_COORDS_AND_COLORS=$(python $pathToCCCgetterScript $inputFile $numRNDcoordsToGet)

# some parsing error or summat leads to "out of bounds" error if we just run command directly; so write it to temp script, then execute temp script and del temp script.
# ALSO (and before that), because the shell can throw an error if I pass a ridiculous number of characters via the CLI (ha!), but python throws no errors loading so many characters from a file, do this: create an RND temp .cgp preset file name, load that via color_growth.py's --LOAD_PRESET switch in the temp script; then delete the temp preset after (saving the new preset with '--SAVE_PRESET True'):
echo "Writing switches for color_growth.py to temporary .cgp file (it will re-save them with other information via '--SAVE_PRESET True') . . ."
rndStringForTempPreset=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6)
presetFileBaseName=color_growth_py__RND_CCC_"$numRNDcoordsToGet"_from_"$inputFileNoExt"__"$rndStringForTempPreset"
presetFileName="$presetFileBaseName".cgp
echo "$additionalParams --SAVE_PRESET True $var_CUSTOM_COORDS_AND_COLORS" > $presetFileName
tmpScriptFileName=tmp_render_script__"$presetFileBaseName"__cgp__.sh

echo "Writing color_growth.py command (including to load that temp preset) to temp script $tmpScriptFileName . . ."
echo "python $pathToColorGrowth_py --LOAD_PRESET $presetFileName" > $tmpScriptFileName

echo "Executing temp script . . ."
./$tmpScriptFileName

echo "Deleting temp script . . ."
rm ./$tmpScriptFileName

echo "DONE with render run for color_growth.py with preset $presetFileName."