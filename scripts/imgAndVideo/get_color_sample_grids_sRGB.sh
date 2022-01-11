# DESCRIPTION
# Calls get_color_sample_grid_sRGB.py for every image file of type $1 (optionally: all supported image types) in the current directory. Passes to that python script parameters of the same type and position as that script supports, with an option to automatically calculate number of rows to match column width (square sample cells). Captures the outputs of the python script and writes them to `.hexplt` files named after each source file.

# DEPENDENCIES
# python, `get_color_sample_grid_sRGB.py` and the Python librar(ies) it requires, and, `getFullPathToFile.sh`, `printAllIMGfileNames.sh`.

# USAGE
# Run with these parameters:
# - $1 source image type to scan (e.g. 'png', typed with or without single or double quote marks). To scan all supported image types, pass the word 'ALL' for this parameter.
# - $2 number of columns to sample.
# - $3 OPTIONAL. Number of rows to sample. If omitted or provided as the keyword 'AUTO', it is automatically calculated to get the number of rows such that row heights are the same as column widths.
# - $4 CONDITIONALLY OPTIONAL. X percent offset to sample from left edge of cells. If omitted or provided as keyword 'DEFAULT', the called Python script uses a default. If you use $5 (read on), you will want to specify this (and not use DEFAULT), or this script will pass $5 as $4 to the Python script.
# - $5 OPTIONAL. Y percent offset to sample from top edge of cells. If omitted the called Python script uses a default.
# - $6 OPTIONAL. Anything, for example the word WHEALHALM, which will cause this script to sample colors from all images in all subdirectories (under the directory you run this script from) also. Respective resultant palettes will be in the same directory as sampled images, alongside them.
# --Whew!
# Example command that will operate on every png file in the current directory, sampling 16 columns for each, with an automatically calculated number of rows to :
#    get_color_sample_grids_sRGB.sh png 16
# Example that will sample 16 rows and 2 columns for every png in this directory:
#    get_color_sample_grids_sRGB.sh png 16 2
# Sample 16 rows and 2 columns for every png in this directory, and offest the sample at thirteen percent (0.13) from the left edge of each cell:
# Sample 16 rows, 2 columns, from every png in this directory, offest the sample at thirteen percent (0.13) from the left edge of each cell, and twenty percent (0.2) from the top edge of each cell:
#    get_color_sample_grids_sRGB.sh png 16 2 0.13 0.2
# Do all of that except use the defautl offsets, and sample colors from all png images in all subdirectories:
#    get_color_sample_grids_sRGB.sh png 16 2 DEFAULT DEFAULT WHEALHALM
# Do all of that but automatically calculate the number of rows to sample so that sample cells are square:
#    get_color_sample_grids_sRGB.sh png 16 AUTO DEFAULT DEFAULT WHEALHALM
# Alternately sample all file types:
#    get_color_sample_grids_sRGB.sh ALL 16 AUTO DEFAULT DEFAULT WHEALHALM
# -- Double whew!
# NOTES
# - This script will not clobber any pre-existing created palette file that matches (has the same base name as) any source image of type $1. It will print a notice that the target already exists.

# CODE
# -- START PARAMETER CHECKING AND SETTINGS SETUP THEREFROM
if [ ! "$1" ]; then printf "\nNo parameter \$1 (image type to sample) passed to script. Exit."; exit 1; else searchFileType=$1; fi
# NOTE: if the keyword 'ALL' was passed for $1, the value of $searchFileType there will have been set to 'ALL'!

if [ ! "$2" ]; then printf "\nNo parameter \$2 (number of columns to sample per image) passed to script. Exit."; exit 1; else sampleNcols=$2; fi

if [ ! "$3" ] || [ "$3" == "AUTO" ]; then sampleNrows="AUTO"; else sampleNrows=$3; fi

# These will be undefined if not provided to script or provided as DEFAULT, which is intended -- in both those cases attempt to pass $xPercentOffset will pass nothing, which will cause the called Python script to use default:
# I needed "do nothing" logic here; it's no-op command ':' -- re https://stackoverflow.com/a/17583599/1397555
if [ ! "$4" ] || [ "$4" == "DEFAULT" ]; then :; else xPercentOffset=$4; fi
if [ ! "$5" ] || [ "$5" == "DEFAULT" ]; then :; else yPercentOffset=$5; fi

# By default set `find` switch to search only the current directory; overide to all (not specifed; defaults to all subdirectories) if $6 is provided:
subDirSearchParam='-maxdepth 1'
if [ "$6" ]; then subDirSearchParam=''; fi
# -- END START PARAMETER CHECKING AND SETTINGS SETUP THEREFROM

if [ "$searchFileType" != "ALL" ]
then
# If NOT instructed to search for all file types (for example if 'png' was passed to $1 (and $searchFileType was consequently set to 'png'), then create an array using the find command searching for e.g. png files:
	# ~+ causes full path to be printed, thanks to a genius breath yonder: https://askubuntu.com/a/1033450/584477
	fileNamesArray=( $(find ~+ $subDirSearchParam -iname \*.$searchFileType) )
else
# Alternately, if instructed via parameter to search for ALL supported image file types, get an array of them via another script:
	if [ "$subDirSearchParam" != "" ]
	# For the intended case of only searching this directory ($subDirSearchParam is '-maxdepth 1'), or not empty:
	then
		fileNamesArray=( $(printAllIMGfileNames.sh NULL 'RETURN OF BROGNALF') )
	else
	# For the intended case of searching all subdirectories:
		fileNamesArray=( $(printAllIMGfileNames.sh BROGNALF 'RETURN OF BROGNALF') )
	fi
fi
# -- OY! So complex!

fullPathToScript=$(getFullPathToFile.sh get_color_sample_grid_sRGB.py)

for fileName in ${fileNamesArray[@]}
do
	renderTarget=$(echo ${fileName%.*})_palette.hexplt
	if [ ! -f $renderTarget ]
	then
		# get image width and height into variables:
		srcIMGw=$(gm identify $fileName -format "%w")
		srcIMGh=$(gm identify $fileName -format "%h")
		colWidth=$(($srcIMGw / $sampleNcols))
# TO DO: don't auto-calculate rows -- or make that optional?
		sampleNrows=$(($srcIMGh / $colWidth))
		echo "Attempting to sample from $fileName at $sampleNcols sample columns and $sampleNrows rows . ."
		python $fullPathToScript $fileName $sampleNcols $sampleNrows > $renderTarget
	else
		echo TARGET EXISTS ALREADY for $renderTarget\; will not clobber. Skip.
	fi
done