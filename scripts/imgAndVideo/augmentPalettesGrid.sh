# DESCRIPTION
# Creates a grid study of augmented colors from palettes such that:
# There are $1 colors added between every color (column) in each palette horizontally
# There are $2 colors added between every row of augmented palettes vertically
# This is done by a process that uses all .hexplt format palettes in the current directory (other than any with output file names made by this script). The result is written to a .hexplt file in a grid and with markup declaring number of columns and rows. The result file is named after the containing folder you run the script from, and the columns x rows. Source palettes may have color codes arranged in any way and include comments; the only requirement is that sRGB hex color codes in the palette are prefixed with a number/hex/pound # symbol and are separated by white space.

# DEPENDENCIES
# `get_color_gradient_OKLAB.js` (and nodeJS and the packages that script requires), `getFullPathToFile.sh`
# GNU datamash (binaries available for various platforms: https://www.gnu.org/software/datamash/) in your PATH

# WARNING
# Deletes any pre-exisisting folders and files with the pattern _augmentPalettes* before doing its work.

# USAGE
# - copy palettes you wish to make a multi-augment grid from into their own dedicated operating folder.
# - from that folder, run this script with these parameters:
# - $1 how many linearly interpolated colors to insert between each color (column) in palette files.
# - $1 how many linearly interpolated colors to insert between each row of colors, between the $1-interpolated palette files.
# For example, to interpolate 5 colors horizontally and vertically over all .hexplt files in the current directory, run:
#    augmentPalettesGrid.sh 5 5
# Or to insert 3 colors horizonatallybetween columns), and 5 colors vertically (between rows):
#    augmentPalettesGrid.sh 3 5
# Or to do no vertical interpolation (only use the original colors with no added colors in between), and insert 5 colors horizontally between columns:
#    augmentPalettesGrid.sh 5 0
# You could pass 0 for both $1 and $2 to make a grid of all palettes, but then you would just want to use `catHexpltsGrid.sh`, which will do that more straightforwardly (and probably more efficiently).
# NOTES
# - you can run this in a directory where you have created palettes from it which have the regex pattern `_augmented_.*_grid` in them, and it will not operate on those files (it will skip them). You can therefore reuse this script in the same directory easily, passing it different parameters each time.
# - the script `paletteRenamedCopiesByNextMostSimilar.sh` may be useful for getting copies of palettes into a dedicated folder for this purpose (with potentially really interesting and beautiful results).
# - to not augment any colors, but create a grid of palettes (e.g. in a folder with copies of them made by the previously mentioned script), instead of using this script, from the directory with the palettes, concatenated them to one file with a pipe command, like this:
#    cat *.hexplt > grid.hexplt
# -- and then mark up the result with:
#    columns: [the number of columns], rows: [the number of rows]
# The process of augmentation in detail is:
# - for every .hexplt format palette in the current directory:
# - do linear interpolation in N ($1) steps between each color in it in okLab color space (using CHL coordinates). Think of every resulting color as an X-direction set of columns.
# - do the same for the next palette in the directory
# - for every column between those two palettes, augment colors between them and create new rows with those colors (think of that as a Y-direction).
# - Repeat for last palette and next palette
# This is accomplished with a series of inefficient hacks using repeated calls of other scripts and GNU datamash.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (how many steps to interpolate between each column (color) in the source palettes) passed to script. Exit."; exit 1; else columnsInterpolateOrigParam=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (how many steps to interpolate between each row from one source palette to the next) passed to script. Exit."; exit 2; else rowsInterpolateOrigParam=$2; fi

# Because each new interpolation iteration will start with the same color as the end color of the previous interpolation, we're going to remove the tail color of each interpolation (iteration) via the `-l 1` switch. That means $((N - 1)). ALSO, the understood literal intent of interpolation in this documentation is _how many additional colors in between_, which means (start color + inserted colors + end color), which means $((N + 2)). Summing that, it's $((N - 1 + 2)) = $((N + 3)). SO:
colsInterpolationSteps=$(($columnsInterpolateOrigParam + 2))
rowsInterpolationSteps=$(($rowsInterpolateOrigParam + 2))
# (This process will need to tack that last removed color back on after everything is removed.)

# set local environment variable fullPathToOKLABAugmentationScript:
fullPathToOKLABAugmentationScript=$(getFullPathToFile.sh get_color_gradient_OKLAB.js)
# return with error if that's empty:
if [[ "$fullPathToOKLABAugmentationScript" == "" ]]; then echo "ERROR: could not find script $scriptName in \$PATH. Exit."; exit 2; fi
# echo "Found $scriptName at $fullPathToOKLABAugmentationScript -- will use that."

# get directory name without path:
currentDirNoPath=$(basename $(pwd))
# build target file name from that:
outputFileName="$currentDirNoPath"_augmented_"$columnsInterpolateOrigParam"x"$rowsInterpolateOrigParam"_grid.hexplt

# horrifyingly large bash function; augments all .hexplt files in the current directory; REQUIRES TWO PARAMETERS (effectively $1 and $2), which are, respectively, the target file to write all augmented palette lines to, and the number of augmentation steps:
augment_palettes () {
	printf "" > $1
	hexplts=($(find . -maxdepth 1 -type f -name \*.hexplt -printf "%f\n"))
	for hexplt in ${hexplts[@]}
	do
	# only do things if the file name of the palette doesn't indicate that it is an augmented palette; to avoid broken things / unintended work, and to allow re-running this script where such a palette aleady exists, but with different parameters; print any results from grep search to null so as not to distract pointlessly:
	grep '_augmented_.*_grid' <<< $hexplt &>/dev/null
	if [[ $(echo $?) != 0 ]]
	then
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
			-n $2 \
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
	fi
	done
}

# delete any temp files from any previous interrupted or otherwise erred run:
rm -rf _augmentPalettes*

# first augmentation pass -- "X"; writes to _augmentPalettesGrid_temp_step1.txt; CALL OF augment_palettes FUNCTION:
augment_palettes _augmentPalettesGrid_temp1.txt $colsInterpolationSteps

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
augment_palettes _augmentPalettesGrid_temp3.txt $rowsInterpolationSteps
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
