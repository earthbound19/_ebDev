# DESCRIPTION
# Splits all files in the current directory of type $1 into subdirectories by multiples of $2 (axe files into folders), with folder prefix name $3. If a IMGlistByMostSimilar.txt file (used by some scripts in _ebDev) is present, splits that into copies in the subfolders, these partitioned text file copies reflecting the files in the subfolders.

# USAGE
# With this script in your PATH, run with these paramters:
# - $1 extension of file to place into numbered subdirectories
# - $2 number of files per folder
# - $3 OPTIONAL. Prefix name for folders. If not provided, defaults to `_toEndFR_`. If you want to use $4 and leave this as the default, pass the word DEFAULT for this parameter.
# - $4 OPTIONAL. Anything, such as the word FLORGULB, which will case the files to be randomly shuffled into subfolders (instead of using the default list order).
# Example command that will axe all files with the extension .hexplt into 80 files per folder, prefixing the numbered folder names with _startN_:
#    axeNfiles.sh hexplt 80 _startN_
# Example command that will do the same thing but using the default folder prefix name, and randomly shuffling the list of files before sorting into folders:
#    axeNfiles.sh hexplt 80 DEFAULT FLORGULB
# NOTE
# If you use parameter $4 in a folder with an accompanying IMGlistByMostSimilar.txt, it will render the generated text file lists useless, because they won't reflect the random (shuffled and not matched) files in the folders.


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
	allFileTypeList=( $(find . -maxdepth 1 -iname "*.$fileExt" -printf "%P\n") )
else
	# if $4 was provided, after file list via find, shuffle it (before put in array) :
	allFileTypeList=( $(find . -maxdepth 1 -iname "*.$fileExt" -printf "%P\n" | shuf) )
fi

for i in ${allFileTypeList[@]}
do
	echo $i
done

exit
# Count number of files so we can figure out how many 0 columns to pad numbers with via printf:
numberOfFiles=$(find . -maxdepth 1 -iname "*.$fileExt" | wc -l | tr -d ' ')
		echo Found $numberOfFiles files of type $fileExt.
padToDigits=${#numberOfFiles}
		echo Will pad numbers in folder names to $padToDigits digits.
# ====
# END SET GLOBALS

# MAIN LOGIC
# Adapted from and thanks to a genius breath yon; https://stackoverflow.com/a/29118145 -- for axing files in subdirs into subdirs by count, check another answer there:
n=$((`find . -maxdepth 1 -iname "*.$fileExt" | wc -l`/$numberToAxeOn+1))
# Variables used in the coming control block to break up lines of a text file (created by and useful for other scripts) into partitioned copies of it in created subfolders:
linesCPmultiplier=1
linesCPStartAtMultiple=1
# For folder name by number zero-padding digits:
highestAxeFolderNumberWillBe=$(($n * $numberToAxeOn))
folderNumberDigitsPadding=${#highestAxeFolderNumberWillBe}
for i in `seq 1 $n`;
do
	zeroPaddedNumber=`printf "%0"$padToDigits"d" $i`
	toEndFrameMultiple=$(($i * $numberToAxeOn))
	paddedToEndFrameMultiple=`printf "%0"$folderNumberDigitsPadding"d" $toEndFrameMultiple`
	folderName=$folderPrefix"$paddedToEndFrameMultiple"
	if [ $i == 1 ]; then helpFirstFolderName=$folderName; fi    # Store first folder name in variable for later help text.
	if [ $i == $n ]; then helpLastFolderName=$folderName; fi    # Store last folder name in variable for later help text.
	if ! [ -d $folderName ]; then mkdir $folderName; fi
	find . -maxdepth 1 -iname "*.$fileExt" | sort -n | head -n $numberToAxeOn | tr -d '\15\32' | xargs -i mv "{}" $folderName
		# Only do anything with IMGlistByMostSimilar.txt if it exists:
	if [ -f ./IMGlistByMostSimilar.txt ]
	# re: https://Unix.stackexchange.com/a/47423/110338
	then
		tail -n+$linesCPStartAtMultiple IMGlistByMostSimilar.txt | head -n$numberToAxeOn > $folderName/IMGlistByMostSimilar.txt
		linesCPStartAtMultiple=$(( ($linesCPmultiplier * $numberToAxeOn) + 1))
		linesCPmultiplier=$(($linesCPmultiplier + 1))
				# echo werf $linesCPmultiplier
				# echo worf $linesCPStartAtMultiple
	fi
done

numeralOneToPadToDigits=`printf "%0"$padToDigits"d" 1`
echo DONE. All files in this folder of type $fileExt have been axed by count $numberToAxeOn into folders named starting $helpFirstFolderName and ending $helpLastFolderName \(if those are both the same folder name\, they are all in that one folder\)\. If the number of files of type $fileExt evenly divided by $numberToAxeOn\, the highest numbered folder will be empty\, so you know.