# DESCRIPTION
# Creates a grid study of augmented colors from palettes such that:
# - there are $1 colors added between every color (column) in each palette horizontally
# - there are $2 colors added between every row of those augmented palettes vertically
# - all this is concatenated to a grid of combined horizontal and vertical augmentations
# This is done by a process that uses all .hexplt format palettes in the current directory (other than any with output file names made by this script). The result is written to a .hexplt file in a grid and with markup declaring number of columns and rows. The result file is named after the containing folder you run the script from, and the columns x rows. Source palettes may have color codes arranged in any way and include comments; the only requirement is that sRGB hex color codes in the palette are prefixed with a number/hex/pound # symbol and are separated by white space.

# DEPENDENCIES
# - `interpolateTwoSRGBColors_coloraide.py` and its dependencies
# - `getFullPathToFile.sh`
# - GNU datamash (binaries available for various platforms: https://www.gnu.org/software/datamash/) in your PATH
# DEPRECATED DEPENDENCY that could still be used with some hacking:# `get_color_gradient_OKLAB.js` (and nodeJS and the packages that script requires)

# WARNING
# Deletes any pre-exisisting folders and files with the pattern _augmentPalettes* before doing its work.

# USAGE
# - copy palettes you wish to make a multi-augment grid from into their own dedicated operating folder.
# - from that folder, run this script with these parameters:
# - $1 REQUIRED. How many linearly interpolated colors to insert between each color (column) in palette files.
# - $2 REQUIRED. How many linearly interpolated colors to insert between each row of colors, between the $1-interpolated palette files.
# - $3 OPTIONAL. An identifier string for The colorspace through which to interpolate colors. Default 'hct' if omitted. Any colorpsace supported by the coloraide library's steps (interpolation) function may be given. Notable options include 'oklab' and 'oklch'. See https://facelessuser.github.io/coloraide/colors/
# For example, to interpolate 5 colors horizontally and vertically over all .hexplt files in the current directory, run:
#    augmentPalettesGrid.sh 5 5
# Or to insert 3 colors horizonatallybetween columns), and 5 colors vertically (between rows):
#    augmentPalettesGrid.sh 3 5
# Or to do no vertical interpolation (only use the original colors with no added colors in between), and insert 5 colors horizontally between columns:
#    augmentPalettesGrid.sh 5 0
# To interpolate 5 colors horizontally and vertically in oklab space instead of the default hct, run:
#    augmentPalettesGrid.sh 5 5 oklab
# You could pass 0 for both $1 and $2 to make a grid of all palettes, but then you would just want to use `catHexpltsGrid.sh`, which will do that more straightforwardly (and probably more efficiently).
# NOTES
# - you can run this in a directory where you have created palettes from it which have the regex pattern `_Augmented-.*_grid` in their file name, and it will not operate on those files (it will skip them). You can therefore reuse this script in the same directory easily, passing it different parameters each time.
# - the script `paletteRenamedCopiesByNextMostSimilar.sh` may be useful for getting copies of palettes into a dedicated folder for this purpose (with potentially really interesting and beautiful results).
# - to not augment any colors, but create a grid of palettes (e.g. in a folder with copies of them made by the previously mentioned script), see `catHexpltsGrid.sh`.
# An overview of the process of palettes augmentation to a grid:
# - for every .hexplt format palette in the current directory, do linear interpolation in J ($1) steps between each color in it, in the chosen color space. Think of every resulting color as an X-direction set of columns.
# - for every resulting augmented palette, augment colors between the rows (by columns) in K ($2) steps in the chosen color space. Think of that as a Y-direction set of rows.
# This is accomplished with a series of inefficient hacks using repeated calls of other scripts and GNU datamash.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (how many steps to interpolate between each column (color) in the source palettes) passed to script. Exit."; exit 1; else columnsInterpolateOrigParam=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (how many steps to interpolate between each row from one source palette to the next) passed to script. Exit."; exit 2; else rowsInterpolateOrigParam=$2; fi
# Set default color space HCT if no parameter $3 says otherwise:
if [ "$3" ]; then interpolationSpace=$3; else interpolationSpace='hct'; fi

# For a very long time I had a comment which I think offered an explanation with an erred or different conclusion than the following used numbers? But, at least, the understood intent of interpolation in this documentation is _how many additional colors in between_, which means:
#    (start color + inserted colors + end color)
# Which has something to do with setting the following interpolation steps + 2? Maybe because we're going to generate but trim off the start and end colors of the interpolation, as they are the original colors (not the interpolated ones)? Anyway the math is:
colsInterpolationSteps=$(($columnsInterpolateOrigParam + 2))
rowsInterpolationSteps=$(($rowsInterpolateOrigParam + 2))
# (This process will need to tack that last removed color back on after everything is removed.)

# set local environment variable fullPathToInterpolationScript:
	# DEPRECATED, as interpolateTwoSRGBColors_coloraide.py does the same thing but can do it in various color spaces:
	# fullPathToInterpolationScript=$(getFullPathToFile.sh get_color_gradient_OKLAB.js)
fullPathToInterpolationScript=$(getFullPathToFile.sh interpolateTwoSRGBColors_coloraide.py)
# return with error if that's empty:
if [[ "$fullPathToInterpolationScript" == "" ]]; then echo "ERROR: could not find script interpolateTwoSRGBColors_coloraide.py in \$PATH. Exit. From $0"; exit 2; fi

# get directory name without path:
currentDirNoPath=$(basename $(pwd))
# build target file name from that:
outputFileName="$currentDirNoPath"_Augmented-"$interpolationSpace"-"$columnsInterpolateOrigParam"x"$rowsInterpolateOrigParam"-grid.hexplt

# horrifyingly large bash function; augments all .hexplt files in the current directory; REQUIRES TWO PARAMETERS (effectively $1 and $2), which are, respectively, the target file to write all augmented palette lines to, and the number of augmentation steps:
augment_palettes () {
	printf "" > $1
	# excluding any augmented files via ! -path, re: https://superuser.com/a/397325 -- changing to -ipath for case-insensitive search:
	hexplts=($(find . -maxdepth 1 -type f -iname \*.hexplt ! -ipath '*augmented*' -printf "%f\n"))
	for hexplt in ${hexplts[@]}
	do
	# only do things if the file name of the palette doesn't indicate that it is a grid (possibly from augmentation or concatenation) palette; to avoid broken things / unintended work, and to allow re-running this script where such a palette aleady exists, but with different parameters; print any results from grep search to null so as not to distract pointlessly:
	grep '_grid' <<< $hexplt &>/dev/null
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
				$(python $fullPathToInterpolationScript \
				-s $thisElement \
				-e $nextElement \
				-n $2 \
				-l 1 \
				-c $interpolationSpace
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
			# RE: https://github.com/earthbound19/_ebDev/issues/6#issuecomment-683808878 - the doom of needing to trim the windows newline on the next line was had 2024/04/20 02:25:08 :
			color=${color//[$'\t\r\n']}
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
# recreate temp folder:
mkdir _augmentPalettesGrid_temp_dir
# split temp file into that as files, one line each:
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
