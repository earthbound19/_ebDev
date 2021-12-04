# DESCRIPTION
# Calls get_color_sample_grid_sRGB.py for every image file of type $1 in the current directory. Passes to that python script parameters such that the samples are over a number of columns that fit (image width / $2 = cell width) and rows (image height / cell width). (The center of square cells of size determined by image width divided by parameter $3. Captures the outputs of the python script and writes them to ~.hexplt files named after each source file.

# DEPENDENCIES
# python, the library used by the called python script, getFullPathToFile.sh

# USAGE
# Run with these parameters:
# - $1 source image type to scan (e.g. png)
# - $2 number of columns to sample. Number of rows is automatically calculated from this such that row cells have the same height as the width (image width / $2).
# - $3 OPTIONAL. Anything, which will cause this script to operate on image type $1 in all subdirectories under the current directory.
# Example command that will operate on every png file in the current directory, sampling 16 columns for each:
#    get_color_sample_grids_sRGB.sh png 16
# NOTE
# This script will not clobber a pre-existing file that matches (has the same base name as) any source image of type $1. It will print a notice that the target already exists.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (image type to sample) passed to script. Exit."; exit 1; else searchFileType=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (number of columns to sample per image) passed to script. Exit."; exit 1; else sampleNcols=$2; fi

subDirSearchParam='-maxdepth 1'
if [ "$3" ]; then subDirSearchParam=''; fi

# ~+ causes full path to be printed, thanks to a genius breath yonder: https://askubuntu.com/a/1033450/584477
fileNamesArray=( $(find ~+ $subDirSearchParam -iname \*.$searchFileType) )

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
		sampleNrows=$(($srcIMGh / $colWidth))
		echo "Attempting to sample from $fileName at $sampleNcols sample columns and $sampleNrows rows . ."
		python $fullPathToScript $fileName $sampleNcols $sampleNrows > $renderTarget
	else
		echo TARGET EXISTS ALREADY for $renderTarget\; will not clobber. Skip.
	fi
done