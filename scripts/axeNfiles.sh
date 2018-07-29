# DESCRIPTION
# Splits all files in the current directory of type $1 into subdirectories by multiples of $2 (axe files into folders), with folder prefix name $3. If a IMGlistByMostSimilar.txt file (used by some scripts in _ebDev) is present, splits that into copies in the subfolders, these partitioned text file copies reflecting the files in the subfolders.

# USAGE
# ./thisScript.sh fileExtension numberOfFilesToAxePerFolder _folderPrefixName_


# CODE

# ====
# BEGIN SET GLOBALS
# Parse for parameters and set defaults for missing ones\; if they are present\, use them.
if [ -z ${1+x} ]
then
	echo No file format parameter \$1 passed to script\; setting to default png.
	fileExt=png
else
	fileExt=$1; echo fileExt set to parameter \$1\, $1\.
fi

if [ -z ${2+x} ]
then
	echo No axe by N files paramater \$2 passed to script\; setting to default 8\.
	numberToAxeOn=8
else
	numberToAxeOn=$2; echo numberToAxeOn set to parameter \$2\, $2\.
fi

if [ -z ${3+x} ]
then
	echo No _folderPrefixName parameter \$3 passed to script\; setting to default _toEndFR_.
	folderPrefix=_toEndFR_
else
	folderPrefix=$3; echo folderPrefix set to parameter \$3\, $3\.
fi

# Count number of files so we can figure out how many 0 columns to pad numbers with via printf:
numberOfFiles=$(gfind . -maxdepth 1 -iname "*.$fileExt" | wc -l | tr -d ' ')
		echo Found $numberOfFiles files of type $fileExt.
padToDigits=${#numberOfFiles}
		echo Will pad numbers in folder names to $padToDigits digits.
# ====
# END SET GLOBALS

# MAIN LOGIC
# Adapted from and thanks to a genius breath yon; https://stackoverflow.com/a/29118145 -- for axing files in subdirs into subdirs by count, check another answer there:
n=$((`gfind . -maxdepth 1 -iname "*.$fileExt" | wc -l`/$numberToAxeOn+1))
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
	# WORKS ON CYGWIN:	
	# gfind . -maxdepth 1 -iname "*.$fileExt" | head -n $numberToAxeOn | xargs -i mv "{}" $folderName
	# WORKS ON MAC where the cygwin command *doesn't* work--! will it work on cygwin also? :
	gfind . -maxdepth 1 -iname "*.$fileExt" | head -n $numberToAxeOn | xargs -I {} mv {} $folderName
		# Only do anything with IMGlistByMostSimilar.txt if it exists:
	if [ -f ./IMGlistByMostSimilar.txt ]
	# re: https://unix.stackexchange.com/a/47423/110338
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