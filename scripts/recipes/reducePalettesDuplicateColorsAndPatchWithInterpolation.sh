# DESCRIPTION
# Think of this as a way to blend or mix colors within a palette. Using other scripts, reduces duplicate colors in all .hexplt palette files in the current directory (and optionally all subdirectories) to total colors count N, then patches duplicate colors in the palettes with a gradient from color A to B at every place in the palette where there are duplicates in between two colors (A and B). The length of the gradient is the same as count N of the duplicate colors between A and B, and the gradient will start with A and end with a color interpolated to N - 1 (a color perceptually nearest to B from A to B over interval N). See USAGE.

# WARNINGS
# - Clobbers existing files with intended modification (overwrites) without warning or backup. Only use this script to operate on files you have backups or a code tracking repository of, or can afford to lose.
# - While this maintains an error log, it erases it before the main functionality of each run to write any new errors to a new file. This is for the intent of a per-run log scope only (not any massive error log buildup).

# DEPENDENCIES
# `getFullPathToFile.sh`, `reduceListByUniqueElementsToCountN.py`, `printPaletteDuplicateColorsInterpolated.py`, and their dependencies (including Python and `interpolateTwoSRGBColors_coloraide.py`)

# USAGE
# Run with these parameters:
# - $1 REQUIRED. Number of total colors to reduce every palette to via use of `reduceListByUniqueElementsToCountN.py`.
# - $2 OPTIONAL. Anything, such as the word SNILFORD, which will cause the script to operate on all .hexplt files in all subdirectories also. Without this, it only modifies palettes in the current directory.
# NOTES
# - Interpolation is done with the default color space used by interpolateTwoSRGBColors_coloraide.py (at this writing, HCT).


# CODE
# set default maxdepth parameter to search only the current directory:
if [ ! "$1" ]; then echo "No parameter \$1 (Number of total colors to reduce every palette to via use of reduceListByUniqueElementsToCountN.py) passed to script. exit."; exit 1; else reduceToCountParameter=$1; fi

maxdepthParameter='-maxdepth 1'
if [ "$2" ]
then
	# param 2 passed; override the val for the maxdepth parameter to nothing (so that it will default to infinite maxdepth):
	maxdepthParameter=
fi

hexpltFilesArray=( $(find . $maxdepthParameter -type f -iname \*.hexplt -printf "%P\n") )

pathToReduceByUniqueElementsScript=$(getFullPathToFile.sh reduceListByUniqueElementsToCountN.py)
if [ "$pathToReduceByUniqueElementsScript" == "" ]; then echo "ERROR: script reduceListByUniqueElementsToCountN.py not found in PATH. exit."; exit 2; fi

pathToPrintPaletteDuplicateColorsInterpolated=$(getFullPathToFile.sh printPaletteDuplicateColorsInterpolated.py)
if [ "$pathToPrintPaletteDuplicateColorsInterpolated" == "" ]; then echo "ERROR: script printPaletteDuplicateColorsInterpolated.py not found in PATH. exit."; exit 2; fi

# erase log from previous runs if it exists
logFileName=reducePalettesDuplicateColorsAndPatchWithInterpolation_sh_log.txt
if [ -e "$logFileName" ]; then rm $logFileName; fi
errorsDuringRun=

for paletteFile in ${hexpltFilesArray[@]}
do
	# Reduce a list of elements with duplicates proportionally per unique element to count N, keeping all elements, via external script $pathToReduceByUniqueElementsScript.
	result=($(python $pathToReduceByUniqueElementsScript -i $paletteFile -r $reduceToCountParameter))
	# python $pathToReduceByUniqueElementsScript -i $paletteFile -r $reduceToCountParameter
	# capture errorlevel to determine any error, and print error if so. Otherwise use the return from that call to do work.
	errorLevelCapture=$?
	if [ "$errorLevelCapture" != "0" ]
	then
		errorsDuringRun=true
		# begin log file if it doesn't exist, or blank it if it does (to start a new log); after this (and on next iterations) it will be appended to (not clobbered) :
		if [ ! -e "$logFileName" ]
		then
			echo "ERROR(S) for run of command: $0 $reduceToCountParameter $maxdepthParameter :" > $logFileName
		fi
		errorMessageFormattedFromArray=$(printf '%s ' "${result[@]}")
		echo ""
		echo "$paletteFile: ERRORLEVEL returned from script call; logging details to $logFileName."
		echo "" >> $logFileName
		echo "$paletteFile: ERRORLEVEL returned from script call: $errorLevelCapture. Message: $errorMessageFormattedFromArray" >> $logFileName
	else
		printf "%s\n" "${result[@]}" > $paletteFile
	fi
	# run script $pathToPrintPaletteDuplicateColorsInterpolated against file to modify it to have gradients instead of duplicates, capture the output, and write it over the original file:
	result2=($(python $pathToPrintPaletteDuplicateColorsInterpolated -i $paletteFile))
	# print array to write over original file, unless there was an error:
	if [ "$errorLevelCapture" != "0" ]
	then
		echo "ERROR running $pathToPrintPaletteDuplicateColorsInterpolated; skipped modify of file $paletteFile."
	else
		printf "%s\n" "${result2[@]}" > $paletteFile
	fi
done

if [ "$errorsDuringRun" ]; then printf "\nTHERE WAS AT LEAST ONE ERROR during the run. They have been written to $logFileName.\n"; fi
