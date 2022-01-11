# DESCRIPTION
# Assists in image organization and color sampling via `get_color_sample_grids_sRGB.sh`. Organizes all images (in the current directory) into subfolders named after the dimensions of the sample grid for which colors will be sampled from them, then repeatedly calls get_color_sample_grids_sRGB.sh with parameters appropriate to those image collections per folder. Presents all images in the current directory one by one and prompts user for the column and row dimensions to sample for each image respectively, then sorts into subfolders to that end (and subsequently samples all images in all subfolders) accordingly.

# DEPENDENCIES
# `printAllIMGfileNames.sh`, `get_color_sample_grids_sRGB.sh`, and their dependencies, irfanView and/or any other default image viewer, and an environment that will open an image to the default image viewer using the `start` command.

# USAGE
# Alter the hard-coded x offset and y offset variables (`xSampleOffset` and `ySampleOffset` at the start of the script (right after the CODE comment) per your want. (See "$4..X percent offset to sample from left edge of cells.." and "$5..Y percent offset.." parameters in `get_color_sample_grids_sRGB.sh` (which in turn map to the Python script that calls).
# Then, run this script without any parameters:
#    get_color_sample_grids_sRGB_assistant.sh
# -- and follow the prompts.


# CODE
xSampleOffset=0.14
ySampleOffset=0.14

allImageFileNames=( $(printAllIMGfileNames.sh) )
for imageFileName in ${allImageFileNames[@]}
do
	start $imageFileName
	echo Image file $imageFileName opened.
	printf "Close the image, and enter the grid dimensions of it (for color sampling). If there is a problem with the image, type something like 'e' to sort it into a folder for editing (sample operations won't happen in any folder that starts with a non-numeral -- such as a letter). Type in the format 'columns <space> rows', e.g.\n4 3\n"
	read -p "n n: " colsXrowsSTR
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
for directory in ${directories[@]}
do
	# Extract columns and rows from directory names! :
	echo --
	echo Directory name is $directory.
	cols=$(sed 's/\([0-9]\{1,\}\).*/\1/g' <<< $directory)
	echo Number of columns from directory name is $cols.
	rows=$(sed 's/\([0-9]\{1,\}\).*\([0-9]\{1,\}\)/\2/g' <<< $directory)
	echo Number of rows from directory name is $rows.
	# USE THAT INFO to get color samples! :
	# save currend directory to directory stack but suppress directory print (redirect to /dev/null) :
	pushd . 1>/dev/null
	# change to that directory:
	cd $directory
	# command that will get color samples for every image in that (this) directory:
	get_color_sample_grids_sRGB.sh ALL $cols $rows $xSampleOffset $ySampleOffset
	popd 1>/dev/null
	# OPTIONAL hard coded render of resultant palettes; comment out if you don't want to do that from this script:
	renderAllHexPalettes.sh
done

echo "DONE sampling colors from all images in all subdirectories. See resultant .hexplt format files in subdirectories."