# DESCRIPTION
# Makes a directory tree of randomly named folders and possibly subfolders, and random files of certain types (hackable, see NOTES), optionally with terminal unfriendly characters (see USAGE). The result random directory tree is in a subfolder named testFiles. The script deletes that directory tree and re-creates it on each run.
# See also FileTool: https://tools.stefankueng.com/FileTool.html

# USAGE
# Run with an optional parameter:
# - $1 OPTIONAL. Any string (such as 'POLSDERF'), which will cause the script to allow terminal-unfriendly characters (see ftun.sh) in file names. If omitted, the character set used to generate file names (unless hacked by you to something else) is a-km-z2-9 (which excludes characters that can be confused for each other such as lowercase L and 1).
# Example that will generate a tree with randomly named files and folders, without terminal-unfriendly characters in their names:
#    makeRNDtestFilesTree.sh
# Example that will generate a tree with randomly named files and folders, which may also include terminal-unfriendly characters in their names:
#    makeRNDtestFilesTree.sh POLSDERF
# NOTES
# - To alter the characteristics of the randomly generated directory tree, see and alter the global variables immediately under the "CODE" comment.
# - This script makes multiple randomly named files of given types (see the fileTypesToMake variable) with the same base file name, e.g. floofarf.hexplt and floofarf.png, norbwahl.hexplt and norbwahl.png, etc.).


# CODE
if [ "$1" ]; then includeTerminalUnfriendlyCharacters="True"; fi

howManyBaseDirectories=$(shuf -i 3-9 -n 1)
subfolderDepth=4
lengthRangeOfNames='1-4'
# Note that even if you give it 0 for the low range, it will still make at least 1 (limitation of how I'm using 'seq') :
rangeOfRNDfilesPerFolder='1-3'
fileTypesToMake='png tif cgp hexplt mp4 avi JPG PNG MP4 MOV'
rndSTR=''

# ALTERS the global variable rndSTR:
set_rndSTR () {
	rndLen=$(shuf -i $lengthRangeOfNames -n 1)
	if [ "$includeTerminalUnfriendlyCharacters" == "True" ]
	then
		rndSTR=$(cat /dev/urandom | tr -dc "a-km-z2-9'@=~!#$%^&()+[{]};.,-" | fold -w $rndLen | head -n 1)
	else
		rndSTR=$(cat /dev/urandom | tr -dc "a-km-z2-9" | fold -w $rndLen | head -n 1)
	fi
}

printf "\n~\nTest random folder tree generation in progress . . .\n~\n"
# wipe test files subdir tree:
if [ -a testFiles ];
then
	rm -rf testFiles
fi
mkdir testFiles

cd testFiles

# make new test files subdir tree:
for i in $(seq 1 $howManyBaseDirectories)
do
	set_rndSTR
	subDirName="$rndSTR"
	set_rndSTR
	subDirName="$subDirName""$rndSTR"
	mkDir $subDirName
done

nSubDirs=$(echo "scale=0; $howManyBaseDirectories / 2" | bc)
# get random selection of directories and make random subdirectories in them, $subfolderDepth times:
for i in $(seq 1 $subfolderDepth)
do
	subsetOfDirectories=$(find . -type d -printf '%P\n' | shuf | head -n $nSubDirs )
	# Make randomly named subdirectories in those:
	for directoryName in ${subsetOfDirectories[@]}
	do
		set_rndSTR
		subDirName="$rndSTR"
		set_rndSTR
		subDirName="$subDirName""$rndSTR"
		mkdir $directoryName/$subDirName
	done
done

printf "\n~\nTest random files generation in progress . . .\n~\n"
# populate the new random test files tree with random files:
allDirectories=$(find . -type d)
for directory in ${allDirectories[@]}
do
	howManyFilesToCreate=$(shuf -i $rangeOfRNDfilesPerFolder -n 1)
	for i in $(seq 0 $howManyFilesToCreate)
	do
		# construct random file base name which may include a number of spaces or underscores
		# reset base of constructed base file name:
		set_rndSTR
		constructedFileName="$rndSTR"
		numSpacesOrUnderscoresInFiles=$(shuf -i 0-3 -n 1)
		# randomly choose a space or underscore inter-word characer, or no character
		spaceOrNot=$(shuf -i 0-1 -n 1)
		spaceChar=
		if [ $spaceOrNot == 1 ]
		then
			spaceChar=$(cat /dev/urandom | tr -dc "_ " | fold -w 1 | head -n 1)
		fi
		for j in $(seq 0 $numSpacesOrUnderscoresInFiles)
		do
			set_rndSTR
			constructedFileName="$constructedFileName""$spaceChar""$rndSTR"
		done
		# make files of multiple types with that same base name
		for fileType in ${fileTypesToMake[@]}
		do
			echo "" > "$directory/$constructedFileName.$fileType"
		done
	done
done
exit

cd ..

printf "\n~\nDONE. Random folder and files tree is in the testFiles directory.\n~\n"