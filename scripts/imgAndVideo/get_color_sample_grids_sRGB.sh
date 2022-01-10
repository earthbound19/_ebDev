# DESCRIPTION
# Calls get_color_sample_grid_sRGB.py for every image file of type $1 (optionally: all supported image types) in the current directory. Passes to that python script parameters of the same type and position as that script supports, with an option to automatically calculate number of rows to match column width (square sample cells). Captures the outputs of the python script and writes them to `.hexplt` files named after each source file.

# DEPENDENCIES
# python, `get_color_sample_grid_sRGB.py` and the Python librar(ies) it requires, and, `getFullPathToFile.sh`, `printAllIMGfileNames.sh`.

# USAGE
# Run with these parameters:
# - $1 source image type to scan (e.g. 'png', typed with or without single or double quote marks). To scan all supported image types, pass the word 'ALL' for this parameter.
# - $2 number of columns to sample.
# - $3 OPTIONAL. Number of rows to sample. If omitted, it is automatically calculated to get the number of rows such that row heights are the same as column widths.
# - $4 OPTIONAL. X percent offset to sample from left edge of cells. If omitted the called Python script uses a default.
# - $5 OPTIONAL. Y percent offset to sample from top edge of cells. If omitted the called Python script uses a default.
# Example command that will operate on every png file in the current directory, sampling 16 columns for each, with an automatically calculated number of rows to :
#    get_color_sample_grids_sRGB.sh png 16

# NOTES
# - Colors in image for sampling are assumed to be all one one row--multiple rows are not supported.
# - This script will not clobber a pre-existing file that matches (has the same base name as) any source image of type $1. It will print a notice that the target already exists.

# TO DO: don't auto-calculate rows
# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (image type to sample) passed to script. Exit."; exit 1; else searchFileType=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (number of columns to sample per image) passed to script. Exit."; exit 1; else sampleNcols=$2; fi

subDirSearchParam='-maxdepth 1'
if [ "$6" ]; then subDirSearchParam=''; fi

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