# DESCRIPTION
# Splits all files in the current directory of type $1 into subdirectories by multiples of $2 (axe files into folders), with folder prefix name $3.

# USAGE
# With this script in your PATH, run with these paramters:
# - $1 extension of file to place into numbered subdirectories
# - $2 number of files per folder
# - $3 OPTIONAL. Prefix name for folders. If not provided, defaults to `_toEndFR_`. If you want to use $4 and leave this as the default, pass the word DEFAULT for this parameter.
# - $4 OPTIONAL. Anything, such as the word FLORGULB, which will cause the files to be randomly shuffled into subfolders (instead of using the default list order).
# Example command that will axe all files with the extension .hexplt into 80 files per folder, prefixing the numbered folder names with _to:
#    axeNfiles.sh hexplt 80 _to
# Example command that will do the same thing but using the default folder prefix name, and randomly shuffling the list of files before sorting into folders:
#    axeNfiles.sh hexplt 80 DEFAULT FLORGULB


# CODE

# ====
# BEGIN SET GLOBALS
# Parse for parameters and set defaults for missing ones\; if they are present\, use them.
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file extension to sort into folders) passed to script. Exit."; exit 1; else fileExt=$1; fi

if [ ! "$2" ]; then printf "\nNo parameter \$1 (number of files to sort into each folder) passed to script. Exit."; exit 1; else numberToAxeOn=$2; fi

if [ ! "$3" ] || [ "$3" == "DEFAULT" ]
then
	folderPrefix=_toEndFR_
	echo "No _folderPrefixName parameter \$3 OR the word DEFAULT passed as parameter 3; folder prefix name set to default $folderPrefix."
else
	folderPrefix=$3; echo folderPrefix set to parameter \$3\, $3\.
fi

if [ ! "$4" ]
then
	# if $4 was not provided, use default sort of find (don't append | shuf) :
	allFilesType=( $(find . -maxdepth 1 -iname "*.$fileExt" -printf "%P\n") )
else
	# if $4 was provided, after file list via find, shuffle it (before put in array) :
	echo "Parameter \$4 provided; shuffling file list before sort into folders."
	allFilesType=( $(find . -maxdepth 1 -iname "*.$fileExt" -printf "%P\n" | shuf) )
fi
# ====
# END SET GLOBALS

# Count number of files so we can figure out how many 0 columns to pad numbers with via printf:
numberOfFiles=${#allFilesType[@]}
		echo Found $numberOfFiles files of type $fileExt.
padToDigits=${#numberOfFiles}
		echo Will pad numbers in folder names to $padToDigits digits.
# MAIN LOGIC
# Figure out how many folders we'll need to create to move $numberToAxeOn into each:
n=$(($numberOfFiles / $numberToAxeOn+1))
# Variables used in the coming control block to break up lines of a text file (created by and useful for other scripts) into partitioned copies of it in created subfolders:
linesCPmultiplier=1
linesCPStartAtMultiple=1
# For folder name by number zero-padding digits:
highestAxeFolderNumberWillBe=$(($n * $numberToAxeOn))
folderNumberDigitsPadding=${#highestAxeFolderNumberWillBe}
i=0			# iterator
for element in ${allFilesType[@]}
do
	zeroPaddedNumber=$(printf "%0"$padToDigits"d" $i)
	if [ $(($i % $numberToAxeOn)) == 0 ]
	then
		toEndFrameMultiple=$(( $toEndFrameMultiple + $numberToAxeOn))
	fi
	paddedToEndFrameMultiple=$(printf "%0"$folderNumberDigitsPadding"d" $toEndFrameMultiple)
	folderName=$folderPrefix"$paddedToEndFrameMultiple"
	if [ $i == 1 ]; then helpFirstFolderName=$folderName; fi    # Store first folder name in variable for later help text.
	if ! [ -d $folderName ]; then mkdir $folderName; fi
	mv $element ./$folderName/
	# increment iterator:
	i=$((i + 1))
done

numeralOneToPadToDigits=$(printf "%0"$padToDigits"d" 1)
echo "DONE. All files in this folder of type $fileExt have been axed by count $numberToAxeOn into folders named starting $helpFirstFolderName and ending $folderName (if those are both the same folder name, there may not have been any point to running this script with the parameters you did: all files ended up in one subfolder only, because you axed the number of files you had to begin with)."