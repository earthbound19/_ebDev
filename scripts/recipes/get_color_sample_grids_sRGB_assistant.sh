# DESCRIPTION
# Assists in image organization and color sampling via `get_color_sample_grids_sRGB.sh`. Organizes all images (in the current directory) into subfolders named after the dimensions of the sample grid for which colors will be sampled from them, then repeatedly calls get_color_sample_grids_sRGB.sh with parameters appropriate to those image collections per folder. Presents all images in the current directory one by one and prompts user for the column and row dimensions to sample for each image respectively, then sorts into subfolders to that end (and subsequently samples all images in all subfolders) accordingly.

# DEPENDENCIES
# `printAllIMGfileNames.sh`, `get_color_sample_grids_sRGB.sh`, and their dependencies, irfanView and/or any other default image viewer, and an environment that will open an image to the default image viewer using the `start` command.

# USAGE
# Run without any parameter:
#    get_color_sample_grids_sRGB_assistant.sh
# -- and follow the prompts.


# CODE
allImageFileNames=( $(printAllIMGfileNames.sh) )
for imageFileName in ${allImageFileNames[@]}
do
	start $imageFileName
	echo Image file $imageFileName opened.
	printf "Close the image, and enter the grid dimensions of it (for color sampling). If there is a problem with the image, type something like 'error error' to sort it into a folder for editing (sample operations won't happen with the error folder). Type in the format 'columns <space> rows', e.g.\n4 3\n"
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

