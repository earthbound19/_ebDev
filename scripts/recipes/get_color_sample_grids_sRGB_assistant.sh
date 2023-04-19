# DESCRIPTION
# Assists in image organization and color sampling via `get_color_sample_grids_sRGB.sh`. Organizes all images (in the current directory) into subfolders named after the dimensions of the sample grid for which colors will be sampled from them, then repeatedly calls get_color_sample_grids_sRGB.sh with parameters appropriate to those image collections per folder. If a parameter is provided telling the sample dimensions, samples all images at that dimension; otherwise it presents all images in the current directory one by one and prompts user for the column and row dimensions to sample for each image. Sorts images into subfolders named after the sample dimensions.

# DEPENDENCIES
# `printAllIMGfileNames.sh`, `get_color_sample_grids_sRGB.sh`, and their dependencies, irfanView and/or any other default image viewer, and an environment that will open an image to the default image viewer using the `start` command.

# USAGE
# Alter the hard-coded x offset and y offset variables (`xSampleOffset` and `ySampleOffset` at the start of the script (right after the CODE comment) per your want. (See "$4..X percent offset to sample from left edge of cells.." and "$5..Y percent offset.." parameters in `get_color_sample_grids_sRGB.sh` (which in turn map to the Python script that calls).
# Then, run this script with these parameters:
# - $1 OPTIONAL. The number of columns and rows you wish to sample, as a string parameter surrounded by double or single quote marks, in the format 'columns <space> rows', e.g. '4 3'. If not provided, it will prompt you for such a string for every image. If provided, it will use this same columns and rows string for every image. If you want to use $2 and/or $3 but not this, pass the word 'NULL' for this.
# - $2 OPTIONAL. X percent to offset sample from cell grid edge (from the left), as decimal. e.g. 50 percent would be 0.5. If omitted, a default is used.
# - $3 OPTIONAL. Y percent to offset sample from cell grid edge (from the top), as decimal. e.g. 25 percent would be 0.25. If omitted, a default is used.
# Example that will sample 10 columns and 8 rows for every image:
#    get_color_sample_grids_sRGB_assistant.sh '10 8'
# Example that will prompt you for the columns and rows per image:
#    get_color_sample_grids_sRGB_assistant.sh
# Example that will prompt you for the columns and rows per image and set the X sample offset to 72 percent and the Y sample offset to 50 percent:
#    get_color_sample_grids_sRGB_assistant.sh NULL 0.72 0.5
# NOTE
# To use this from another script and make use of the last resultant sample grid subfolder name, call it with `source`:
#    source get_color_sample_grids_sRGB_assistant.sh '10 8'
# -- and then from the calling script use the variable $sampleDirectoryName, which will be set in your environment if you call this script and return from it that way. However, this may only be consistent and useful if you use parameter $1 of this script to specify the sample grid size (as otherwise it could change if you provide different grid size parameters per image when prompted).


# CODE
# set a global var if $1 exists; otherwise it will not be set:
if [ "$1" ]; then paramColsXrowsSTR=$1; fi
if [ "$2" ]; then xSampleOffset=$2; else xSampleOffset=0.363; fi
if [ "$3" ]; then ySampleOffset=$3; else ySampleOffset=0.363; fi

allImageFileNames=( $(printAllIMGfileNames.sh) )
for imageFileName in ${allImageFileNames[@]}
do
	# check for existence of global var and alter behavior depending:
	if [ ! "$paramColsXrowsSTR" ] || [ "$paramColsXrowsSTR" == 'NULL' ]
	then
		start $imageFileName
		echo Image file $imageFileName opened.
		printf "Close the image, and enter the grid dimensions of it (for color sampling). If there is a problem with the image, type something like 'e' to sort it into a folder for editing (sample operations won't happen in any folder that starts with a non-numeral -- such as a letter). Type in the format 'columns <space> rows', e.g.\n4 3\n"
		read -p "n n: " colsXrowsSTR
	else
		# even though this is redudant to set this repeatedly in this case, as it won't change intra-run of this script:
		colsXrowsSTR="$paramColsXrowsSTR"
	fi
		# read that into array (space is default delimiter) :
		arr=($(echo $colsXrowsSTR))
		cols=${arr[0]}		# element 1
		rows=${arr[1]}		# element 2
		sortDir="$cols"x"$rows"
		if [ ! -d $sortDir ]
		then
			mkdir $sortDir
		fi
		mv $imageFileName ./$sortDir/
done

directories=( $(find . -type d -printf "%P\n") )
for sampleDirectoryName in ${directories[@]}
do
	# Extract columns and rows from directory names! :
	echo --
	echo Directory name is $sampleDirectoryName.
	columns=$(sed 's/\([0-9]\{1,\}\).*/\1/g' <<< $sampleDirectoryName)
	echo Number of columns from directory name is $columns.
	rows=$(sed 's/[0-9]\{1,\}[^0-9]\{1,\}\([0-9]\{1,\}\)/\1/g' <<< $sampleDirectoryName)
	echo Number of rows from directory name is $rows.
	# USE THAT INFO to get color samples! :
	# save currend directory to directory stack but suppress directory print (redirect to /dev/null) :
	pushd . 1>/dev/null
	# change to that directory:
	cd $sampleDirectoryName
	# command that will get color samples for every image in that (this) directory:
	get_color_sample_grids_sRGB.sh ALL $columns $rows $xSampleOffset $ySampleOffset
	# OPTIONAL but hard coded render of resultant palettes; comment out if you don't want to do that from this script:
	renderAllHexPalettes.sh
	popd 1>/dev/null
done

echo "DONE sampling colors from all images in all subdirectories. See resultant .hexplt format files in subdirectories."