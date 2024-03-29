# DESCRIPTION
# Calls get_color_sample_grid_sRGB.py for every image file of type $1 (optionally: all supported image types) in the current directory. Passes to that python script parameters of the same type and position as that script supports, with an option to automatically calculate number of rows to match column width (square sample cells). Captures the outputs of the python script and writes them to `.hexplt` files named after each source file.

# DEPENDENCIES
# python, `get_color_sample_grid_sRGB.py` and the Python librar(ies) it requires, and, `getFullPathToFile.sh`, `printAllIMGfileNames.sh`.

# USAGE
# Run with these parameters:
# - $1 source image type to scan (e.g. 'png', typed with or without single or double quote marks). To scan all supported image types, pass the word 'ALL' for this parameter.
# - $2 number of columns to sample.
# - $3 OPTIONAL. Number of rows to sample. If omitted or provided as the keyword 'AUTO', it is automatically calculated to get the number of rows such that row heights are the same as column widths.
# - $4 CONDITIONALLY OPTIONAL. X percent offset to sample from left edge of cells, expressed as decimal (e.g. fourteen percent would be 0.14). If omitted or provided as keyword 'DEFAULT', the called Python script uses a default. If you use $5 (read on), you will want to specify this (and not use DEFAULT), or this script will pass $5 as $4 to the Python script.
# - $5 OPTIONAL. Y percent offset to sample from top edge of cells, also expressed as decimal. If omitted the called Python script uses a default.
# - $6 OPTIONAL. Anything, for example the word WHEALHALM, which will cause this script to sample colors from all images in all subdirectories (under the directory you run this script from) also. Respective resultant palettes will be in the same directory as sampled images, alongside them. If you want to use $7 (read on) but not this, pass NULL for this.
# - $7 OPTIONAL. I KNOW! Too many options! Any string, which this script will write after the first color in the rendered hexplt file as a comment. If you need to include spaces in this string, surround it with quote marks. Again, if you want to use this ($7) but not $6, pass the word NULL for $6.
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
# - This script has commented code that reformats the default output hexplt files to arrange colors in columns by number of sampled columns. In my opinion this helps with examining palettes sampled from images in a text editor. This commented functionality is redundant however; the python script this calls does that already (I coded the latter after I realized it better belongs there, after I coded the former). Search the later code for comments that say "OPTIONAL" to see that.

# CODE
# -- START PARAMETER CHECKING AND SETTINGS SETUP THEREFROM
if [ ! "$1" ]; then printf "\nNo parameter \$1 (image type to sample) passed to script. Exit."; exit 1; else searchFileType=$1; fi
# NOTE: if the keyword 'ALL' was passed for $1, the value of $searchFileType there will have been set to 'ALL'!

if [ ! "$2" ]; then printf "\nNo parameter \$2 (number of columns to sample per image) passed to script. Exit."; exit 2; else sampleNcols=$2; fi

if [ ! "$3" ] || [ "$3" == "AUTO" ]; then sampleNrows="AUTO"; else sampleNrows=$3; fi

# These will be undefined if not provided to script or provided as DEFAULT, which is intended -- in both those cases attempt to pass $xPercentOffset will pass nothing, which will cause the called Python script to use default:
# I needed "do nothing" logic here; it's no-op command ':' -- re https://stackoverflow.com/a/17583599/1397555
if [ ! "$4" ] || [ "$4" == "DEFAULT" ]; then :; else xPercentOffset=$4; fi
if [ ! "$5" ] || [ "$5" == "DEFAULT" ]; then :; else yPercentOffset=$5; fi

# By default set `find` switch to search only the current directory; overide to all (not specifed; defaults to all subdirectories) if $6 is provided:
subDirSearchParam='-maxdepth 1'
if [ "$6" ] && [ "$6" != "NULL" ]; then subDirSearchParam=''; fi

# Default blank comment string (script will not use if empty); may override by passing a comment string as parameter $7:
hexpltCommentString=""
if [ "$7" ]; then hexpltCommentString="$7"; fi

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

# if array length of source files to sample is 0, warn and exit.
if [[ ${#fileNamesArray[@]} == 0 ]]; then printf "\nWARNING: no source files to sample were found by using search parameter:\n\t$searchFileType\n--in current directory/ies. Exit.\n" exit 3; fi

fullPathToScript=$(getFullPathToFile.sh get_color_sample_grid_sRGB.py)

for fileName in ${fileNamesArray[@]}
do
	renderTarget=${fileName%.*}_palette.hexplt
	if [ ! -f $renderTarget ]
	then
		# get image width and height into variables:
		srcIMGw=$(gm identify $fileName -format "%w")
		srcIMGh=$(gm identify $fileName -format "%h")
		colWidth=$(($srcIMGw / $sampleNcols))
		# if parameter instructed to, calculate sample rows such that sample cells will be square. Otherwise do nothing, as $sampleNrows was already set to N specified by parameter:
		if [ "$sampleNrows" == "AUTO" ]
		then
			sampleNrows=$(($srcIMGh / $colWidth))
		fi
		echo "Attempting to sample from $fileName at $sampleNcols sample columns and $sampleNrows rows . ."
		# passing along xPercentOffset yPercentOffset with everything else:
		python $fullPathToScript $fileName $sampleNcols $sampleNrows $xPercentOffset $yPercentOffset > $renderTarget
		echo ""

		# OPTIONAL HEXPLT REFORMATTING  -- reworked source Python script with just a few bytes to accomplish the same! :facepalm:
		# Reformat lines to $sampleNcols per line; re: https://docstore.mik.ua/orelly/unix3/upt/ch21_15.htm
		# backup IFS and set it to "" else the variable assignment from command substitution eliminates intended newlines on print:
#		OIFS="$IFS"
#		IFS=$''
		# tr -d: windows newlines interfere with intended formatting here otherwise! :
#		reformatted=$(pr -l1 -3 --across --separator=' ' $renderTarget | tr -d '\15\32')
#		echo $reformatted > $renderTarget
#		IFS="$OIFS"
		# COMMENT PARAMETER USE
		# paste comment at end of first line of file if parameter to script provided for that (if $hexpltCommentString is non-empty) :
		if [ "$hexpltCommentString" ]
		then
			sed -i -e "1s/$/ $hexpltCommentString/" $renderTarget
		fi
	else
		echo TARGET EXISTS ALREADY for $renderTarget\; will not clobber. Skip.
	fi
done