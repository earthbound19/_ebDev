# DESCRIPTION
# Creates a sort of "pixel sort" palette from all palettes in a directory, this way:
# - collates them all to one palette. Assumes that they all have the same number of colors which will evenly divide over $1 columns (and things may go wonky if they don't).
# - sorts colors in columns by next-nearest perceptual, either to the first color (top of column) by default, or optionally compares starting with an arbitrary sRGB hex format color $2, and sorts them in the column in that order. The comparisons to sort are done in the Oklab color space.
# - writes that result to a new palette in a subdirectory, named partly after the directory you run this script from, arranged in $1 columns and with a layout comment so that render scripts that make use of the comment will lay out colors in a grid such that the color sorting by column will hopefully be visually apparent.
# - optionally also dividing columns into sorted hue bands.
# - optionally with a starting sort arbitrary color for the hue bands.
# - renders the result palette with a renderer that will make use of the layout comment
# - also places a comment in the palette giving the script parameters (from this script call) that created the palette

# DEPENDENCIES
# A lot of things. `allRGBhexColorSortInOkLab.sh`, `reformatAllHexPalettes.sh`, `reformatHexPalette.sh`, `hexplt_split_to_channel_ranges_OKLAB.js`, `rgbHexColorSortInOkLab.js`, `filterExcludedWords.sh`, `renderAllHexPalettes.sh`, and their dependencies.

# USAGE
# I acknowledge that the options for this (including options passed to other scripts it calls) are very complex.
# Run with these parameters:
# - $1 REQUIRED. number of columns that all the palettes in this directory will evenly divide into. This is expected to be the same for every palette, and things may go wonky if they are not. Palettes are also expected to all have the same number of colors (no tests without that have been done).
# - $2 OPTIONAL. Any parameter(s) usable by `allRGBhexColorSortInOkLab.sh`, surrounded by quote marks. This gets hairy, because that script passes it on to `rgbHexColorSortInOkLab.js`, and while it's technically one parameter it can be a group of parameters surrounded by quote marks. (I even internally named the variable that receives this parameter parametricHairball.) See the parameter documentation comments in `allRGBhexColorSortInOkLab.sh` and maybe the script it calls.
# - $3 OPTIONAL. Number of hue divisions for `hexplt_split_to_channel_ranges_OKLAB.js`, which, if provided, will cause split of colors per column into hue ranges via that script. (for example groups like red, orange, yellow, green, cyan, blue, violet, and magenta if you pass 8.) Note that this will result in an override of any first -f sort color in $2 (for `allRGBhexColorSortInOkLab.sh`)
# - $4 OPTIONAL, and recommended if you use $3: sRGB hex color code to start sorting of the `hexplt_split_to_channel_ranges_OKLAB.js` hue division ranges of $3 on (sorting them via `rgbHexColorSortInOkLab.js` custom calls sorting those ranges). This will result in the hue groups each being sorted by next nearest perceptually similar color, starting on this color. You might try 000000 (black) or ffffff (white) for example.
# Example with 5 columns for every palette in the directory, and default keeping any duplicate colors (no parameters for $2 / `allRGBhexColorSortInOkLab.sh`):
#    palettesColumnsOklabSortGrid.sh 5
# Example with 5 columns for every palette in the directory, keeping any duplicate colors, and starting sort on a vivid brick red sRGB color (via an available parameter -f for `allRGBhexColorSortInOkLab.sh` at this writing) :
#    palettesColumnsOklabSortGrid.sh 5 '-k'
# Example that has 5 columns, keeps duplicates, splits into 8 hue ranges, and sortes hue ranges starting on next most similar to an almost black red-red-orange:
#    palettesColumnsOklabSortGrid.sh 5 '-k' 8 0c0001
# NOTES
# - The way that sRGB color code for the last example was contrived is: started with OKHSV S (saturation) 100 and value (non-black) 5, then H (hue) that lies in the middle of the boundaries of red and orange in the okHSV hue angle 360/8, so that the hue ranging in the logic will capture everything between red and orange at intervale of 360/8; or 360/8/2 = 22 (from 22.5). The division by 8 is for the 8 parameter for number of hue divisions (groups).
# - The path and name of the result file is in the format: ./_palettesColumnsOklabSortGrids/_<host_directory_name>_palettesColumnsOklabSortGrid_<a few random characters>.hexplt


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (number of columns that palettes are organized into) passed to script. Exit."; exit 1; else columns=$1; fi
parametricHairball='-k'
if [ "$2" ]; then parametricHairball=$2; fi
# Override that to nothing if the keyword NULL was passed:
if [ "$parametricHairball" == 'NULL' ]; then parametricHairball= ; fi
if [ "$3" ]; then hueDivisionRangesCount=$3; fi
if [ "$4" ]; then hueDivisionRangeSRGBcompare=$4; fi
# echo columns is $columns, parametricHairball is $parametricHairball, hueDivisionRangesCount is $hueDivisionRangesCount, hueDivisionRangeSRGBcompare is $hueDivisionRangeSRGBcompare

# get directory name without path:
currentDirNoPath=$(basename $(pwd))
# build target file name from that; add script parameter details to it:
outputFileName="$currentDirNoPath"_palettesColumnsOklabSortGrid_n"$hueDivisionRangesCount"_s"$hueDivisionRangeSRGBcompare".hexplt

# delete any temp files from any previous interrupted or otherwise erred run:
rm -rf _palettesColumnsGrid_temp*
mkdir _palettesColumnsGrid_temp

# write first temp file of reformatted temp palettes collated into one, into temp dir:
reformatAllHexPalettes.sh "-c"$columns" -n -p" > ./_palettesColumnsGrid_temp/temp1.txt

# cd to that temp dir for remaining operations:
cd _palettesColumnsGrid_temp
# transpose that result to new file:
datamash transpose --field-separator=' ' < temp1.txt > temp2.txt

# delete trailing whitespace/lines from that result (which would otherwise result in empty split files, maybe augment errors:
sed -i -e :a -e '/[^[:blank:]]/,$!d; /^[[:space:]]*$/{ $d; N; ba' -e '}' temp2.txt

# split temp file into one line palettes:
split --additional-suffix='.hexplt' -l 1 temp2.txt augment_

# if told to (if the variable exists), split each into hueDivisionRangesCount hue clusters using script; get path to script first:
if [ "$hueDivisionRangesCount" ]
then
	splitToChannelRangesScriptPath=$(getFullPathToFile.sh hexplt_split_to_channel_ranges_OKLAB.js)
	# may need to do custom repeat call of `rgbHexColorSortInOkLab.js`; get path to it:
	rgbHexColorSortInOkLabPath=$(getFullPathToFile.sh rgbHexColorSortInOkLab.js)
	# get list of file names of one line palettes:
	allHexpltFileNames=( $(find . -maxdepth 1 -type f -iname "*.hexplt" -printf "%P\n") )
	for hexpltFileName in ${allHexpltFileNames[@]}
	do
		# get basefile name, for more than one reason:
		fileNameNoExt=${hexpltFileName%.*}
		# split it into channel range palettes:
		node $splitToChannelRangesScriptPath -i $hexpltFileName -n $hueDivisionRangesCount
		# rename that which those channel range splits were made from, so it won't be redundantly added in concatenating those; also for later comparison step in case of any colors that literally get lost in the shuffle:
		mv $hexpltFileName _SORTING_BACKUP_$hexpltFileName
		# reformat it to one color per line for future comparison:
		reformatHexPalette.sh -i _SORTING_BACKUP_$hexpltFileName -c1 -n
		# if told to do so (if hueDivisionRangeSRGBcompare exists), sort all those resulting ranges by next most similar starting on the value of that variable:
		if [ "$hueDivisionRangeSRGBcompare" ]
		then
			# get a list of just those files into an array:
			allSplitHexpltFileNames=( $(find . -maxdepth 1 -type f -iname "$fileNameNoExt*" -printf "%P\n") )
			# operate on them for that sorting of each:
			for splitHexplt in ${allSplitHexpltFileNames[@]}
			do
				# store results in tmp array:
				lines=( $(node $rgbHexColorSortInOkLabPath -i $splitHexplt -f $hueDivisionRangeSRGBcompare -k) )
				# write results from array back to file, one color per line, for later file comparison:
				printf "%s\n" ${lines[@]} > $splitHexplt
			done
		fi
		# store the results of these split/group and possible sort operations from files into an array:
		tmpArr=($(cat "$fileNameNoExt"*))
		# write it back to the original split file, not yet formatted with all colors on one line, but instead with one color per line, so we can do comparison and add back any colors that got lost in the shuffle:
		printf "%s\n" ${tmpArr[@]} > _SORTED_$hexpltFileName
		# retrieve all lines from backup that may have gotten lost in shuffling process toward semifinal, and put them in an array:
		lostColors=( $(filterExcludedWords.sh _SORTED_$hexpltFileName _SORTING_BACKUP_$hexpltFileName) )
		# append any lost colors back to ~_SORTED_:
		printf "%s\n" ${lostColors[@]} >> _SORTED_$hexpltFileName
		# reformat that to one line with no layout comments:
		reformatHexPalette.sh -i _SORTED_$hexpltFileName -a -n
		# remove the files that was concatenated from:
		rm "$fileNameNoExt"*
		# rename that to final sorted row (which will be transposed to a column) :
		mv _SORTED_$hexpltFileName $hexpltFileName
		# delete sorting backup else it will be concatenated into the rest and muck things up:
		rm _SORTING_BACKUP_$hexpltFileName
	done
fi

# Call script with parametric hairball; NOTE: surrounding that parametricHairball parameter use with double quote marks was the key to getting the group of parameters in the variable to work with the called script;
# BUT DON'T call it if hueDivisionRangesCount exists:
if [ ! "$hueDivisionRangesCount" ]
then
	allRGBhexColorSortInOkLab.sh "$parametricHairball"
fi

# rejoin those to a semi-semi-final palette handily in one script run and pipe!
reformatAllHexPalettes.sh '-a -n -p' > temp1.txt

# transpose those to semi-final palette!
datamash transpose --field-separator=' ' < temp1.txt > ../$outputFileName

# cd to final dir and reformat final file to include layout comment:
cd ..
reformatHexPalette.sh -i $outputFileName -c"$columns"
# place a comment on the second row of the result giving the script call with parameters that made it; via echo syntax for script name without path, array of parameters to script; construct variable with those values:
appendStr="${0##*/} $@"
# use that variable to append to 2nd line, in place:
sed -i "2 s/\(.*\)/\1  built with command: $appendStr/" $outputFileName

# move it into its own final subfolder (creating it if necessary), to avoid a problem of re-using it should this script be run again:
if [ ! -d _palettesColumnsOklabSortGrids ]; then mkdir _palettesColumnsOklabSortGrids; fi
mv $outputFileName ./_palettesColumnsOklabSortGrids/
# cd into that and render the palette:
cd _palettesColumnsOklabSortGrids
renderAllHexPalettes.sh

# cd out of that and remove temp files:
cd ..
rm -rf _palettesColumnsGrid_temp*

echo "DONE. Final file destination folder and file is ./_palettesColumnsOklabSortGrids/$outputFileName."
