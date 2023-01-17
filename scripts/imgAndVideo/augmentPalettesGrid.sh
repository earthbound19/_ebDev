# DESCRIPTION
# Creates a grid study of augmented colors from palettes such that:
# There are N colors added between every color in each palette horizontally
# There are N colors added between every row of augmented palettes.
# This is done with all .hexplt format palettes in the current directory. Writes the result to a .hexplt file in a grid and with markup declaring number of columns and rows. The result file is named after the containing folder you run the script from. Source palettes may have color codes arranged in any way and include comments; the only requirement is that sRGB hex color codes in the palette are prefixed with a number/hex/pound # symbol and are separated by white space.

# DEPENDENCIES
# `get_color_gradient_OKLAB.js` (and nodeJS and the packages that script requires), `getFullPathToFile.sh`
# GNU datamash (binaries available for various platforms: https://www.gnu.org/software/datamash/) in your PATH

# USAGE
# - copy palettes you wish to make a multi-augment grid from into their own dedicated operating folder.
# - from that folder, run this script with these parameters:
# - $1 how many linearly interpolated colors to insert between each color and between rows in palette files.
# For example, to interpolate 5 colors horizontally and vertically over all .hexplt files in the current directory, run:
#    augmentPalettesGrid.sh 5
# NOTE
# The process of augmentation in detail is:
# - For every .hexplt format palette in the current directory:
# - Do linear interpolation in N ($1) steps between each color in it in okLab color space (using CHL coordinates). Think of every resulting color as an X-direction set of columns.
# - Do the same for the next palette in the directory
# - For every column between those two palettes, augment colors between them and create new rows with those colors (think of that as a Y-direction).
# - Repeat for last palette and next palette
# This is accomplished with a series of inefficient hacks using repeated calls of other scripts and GNU datamash.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (how many steps to interpolate between each color in the source palettes and between generated rows) passed to script. Exit."; exit 1; else interpolationStepsOriginalParameter=$1; fi

# Because each new interpolation iteration will start with the same color as the end color of the previous interpolation, we're going to remove the tail color of each interpolation (iteration) via the `-l 1` switch. That means $((N - 1)). ALSO, the understood literal intent of interpolation in this documentation is _how many additional colors in between_, which means (start color + inserted colors + end color), which means $((N + 2)). Summing that, it's $((N - 1 + 2)) = $((N + 3)). SO:
interpolationSteps=$(($interpolationStepsOriginalParameter + 2))
# (This process will need to tack that last removed color back on after everything is removed.)

# set local environment variable fullPathToOKLABAugmentationScript:
scriptName=get_color_gradient_OKLAB.js
fullPathToOKLABAugmentationScript=$(getFullPathToFile.sh $scriptName)
# return with error if that's empty:
if [[ "$fullPathToOKLABAugmentationScript" == "" ]]; then echo "ERROR: could not find script $scriptName in \$PATH. Exit."; exit 2; fi

# echo "Found $scriptName at $fullPathToOKLABAugmentationScript -- will use that."

# get directory name without path:
currentDirNoPath=$(basename $(pwd))
# build target file name from that:
outputFileName="$currentDirNoPath"_augmented_"$interpolationStepsOriginalParameter"_grid.hexplt

# horrifyingly large bash function; augments all .hexplt files in the current directory; REQUIRES PARAMETER (effectively $1), which is the target file to write all augmented palette lines to:
augment_palettes () {
	printf "" > $1
	hexplts=($(find . -maxdepth 1 -type f -name \*.hexplt -printf "%f\n"))
	for hexplt in ${hexplts[@]}
	do
		# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
		colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $hexplt | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array
		# Get number of colors (from array),
		numColors=${#colorsArray[@]}
		# which we will use with a loop counter to stop at second to last element:
		stopLoopAt=$(($numColors -1))
		# -- as we'll be getting the last element then, and if we tried to get a last element (N+1) at the last element, we'd go out of bounds of the array index:
		counter=0
		augmentedPalette=()
		for color in ${colorsArray[@]}
		do
			thisElement=${colorsArray[$counter]}
			nextElement=${colorsArray[$(($counter + 1))]}
				# optional debug print:
				# echo "idx $counter, element \$color $color\: $thisElement, +1 element $nextElement"
			# get the interpolated color list via call of interpolation script -- note the -l 1 parameter, which remove the last color of the augmentation! -- and put it in an array:
			augmentedPaletteSegment=(
			$(node $fullPathToOKLABAugmentationScript \
			-s $thisElement \
			-e $nextElement \
			-n $interpolationSteps \
			-l 1 \
			)
			)
			# add those to master augmented palette:
			for augmentedColor in ${augmentedPaletteSegment[@]}
			do
				augmentedPalette+=($augmentedColor)
			done
			# increment tracking counter:
			counter=$(($counter + 1))
			# break if counter at array size - 1, or stopLoopAt:
			if [ $counter == $stopLoopAt ]; then break; fi
		done
		# tack last color of original palette on to that which would otherwise be missing:
		augmentedPalette+=("#""${colorsArray[-1]}")
		# print completed augmented palette:
		for color in ${augmentedPalette[@]}
		do
			printf "$color " >> $1
		done
		printf "\n" >> $1
	done
}

# delete any temp files from any previous interrupted or otherwise erred run:
rm -rf _augmentPalettes*

# first augmentation pass -- "X"; writes to _augmentPalettesGrid_temp_step1.txt; CALL OF augment_palettes FUNCTION:
augment_palettes _augmentPalettesGrid_temp1.txt

# transpose that result to new file:
datamash transpose --field-separator=' ' < _augmentPalettesGrid_temp1.txt > _augmentPalettesGrid_temp2.txt
# delete trailing whitespace/lines from that result (which would otherwise result in empty split files, maybe augment errors:
sed -i -e :a -e '/[^[:blank:]]/,$!d; /^[[:space:]]*$/{ $d; N; ba' -e '}' _augmentPalettesGrid_temp2.txt
# recreate it:
mkdir _augmentPalettesGrid_temp_dir
# split temp file into it as one line files:
split --additional-suffix='.hexplt' -l 1 _augmentPalettesGrid_temp2.txt ./_augmentPalettesGrid_temp_dir/augment_
# change to temp dir and augment all those resultant transposed line-split palettes into another big palette;
cd _augmentPalettesGrid_temp_dir
# CALL OF augment_palettes FUNCTION:
augment_palettes _augmentPalettesGrid_temp3.txt
# transpose that to our final result, named after the directory:
datamash transpose --field-separator=' ' < _augmentPalettesGrid_temp3.txt > ../$outputFileName
# cd back up and trim trailing whitespace off result palette:
cd ..
sed -i -e :a -e '/[^[:blank:]]/,$!d; /^[[:space:]]*$/{ $d; N; ba' -e '}' $outputFileName
# delete temp files:
rm -rf _augmentPalettes*
# get count of columns:
columns=$(head -n 1 $outputFileName | grep -o '#' | wc -l)
# get count of rows:
rows=$(wc -l < $outputFileName | xargs)
# build columns and rows comment string from that and append it to end of first line:
formatString="  columns: $columns rows: $rows"
sed -i " 1 s/.*/&$formatString/" $outputFileName

echo DONE. Result file is $outputFileName.
