# DESCRIPTION
# Splits a text file $1, on lines, into smaller files of $2 lines per file, dividing on line breaks. Files may be recombined to form the original file again (see NOTES). Split files will be named after the original and keep the same extension (e.g. `.txt` or `.hexplt`), but with numbering in the file names.

# USAGE
# Run with these parameters:
# - $1 the file name of the text file to split
# - $2 how many lines per file
# Example command that will split a file named aHugoriousTextFile.txt into 4 files:
#    splitTextFile.sh Humanae.hexplt 256
# NOTES
# - If you move the resulting split files into their own folder, you can recombine the files by placing them in their own directory and running the command: `cat .*`


# CODE
# FORMER CODE:
# split ./$1 -C $2K

# NEW CODE:
# parameter-assigned values
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source file name) passed to script. Exit."; exit 1; else sourceFileName=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (number of lines per split file) passed to script. Exit."; exit 2; else linesPerSplitFile=$2; fi

fileNameNoExt=${sourceFileName%.*}
fileExt=${sourceFileName##*.}

originalFileArray=( $(<$sourceFileName) )
linesInSource=${#originalFileArray[@]}

# calc. number of files:
numberOfFiles=$(($linesInSource / $linesPerSplitFile))
# if there's a remainder to division, add one more number to file count:
mod=$(($linesInSource % $linesPerSplitFile))
if [ $mod != 0 ]; then numberOfFiles=$(($numberOfFiles + 1)); fi
digitsToPadFileNumbersTo=${#numberOfFiles}

echo Splitting file in memory and writing on each split completion . . .
echo ""

# check for and clear target files if they exist.
fileCounter=1
for r in $(seq 0 $linesInSource)
do
	paddedNum=$(printf "%0""$digitsToPadFileNumbersTo""d" $fileCounter)
	if [ -f "$fileNameNoExt"_"$paddedNum".$fileExt ]
	then
		rm "$fileNameNoExt"_"$paddedNum".$fileExt
	fi
done

# build target files.
printedLinesCounter=1
fileCounter=1
OIFS="$IFS"
IFS=$'\n'
for r in $(seq 0 $linesInSource)
do
	paddedNum=$(printf "%0""$digitsToPadFileNumbersTo""d" $fileCounter)
	echo ${originalFileArray[$(($printedLinesCounter - 1))]} >> "$fileNameNoExt"_"$paddedNum".$fileExt
	if [[ $(($printedLinesCounter % $linesPerSplitFile)) == 0 ]]
	then
		# echo "-- paddenNum $paddedNum"
		fileCounter=$((fileCounter + 1))
	fi
	printedLinesCounter=$(($printedLinesCounter + 1))
done
IFS="$OIFS"

printf "\nDONE splitting files."
# echo "numberOfFiles $numberOfFiles ?"
# echo that is $digitsToPadFileNumbersTo