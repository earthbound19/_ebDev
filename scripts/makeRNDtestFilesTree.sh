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

howManyBaseDirectories=7
subfolderDepth=4
lengthRangeOfNames='7 12'
# Note that even if you give it 0 for the low range, it will still make at least 1 (limitation of how I'm using 'seq') :
rangeOfRNDfilesPerFolder='1 2'
fileTypesToMake='png tif cgp hexplt mp4 avi JPG PNG MP4 MOV'
rndSTR=''

# ALTERS the global variable rndSTR:
set_rndSTR () {
	rndLen=$(seq $lengthRangeOfNames | shuf | head -n 1)
	if [ "$includeTerminalUnfriendlyCharacters" == "True" ]
	then
		rndSTR=$(cat /dev/urandom | tr -dc "a-km-z2-9'@=~!#$%^&()+[{]};. ,-" | fold -w $rndLen | head -n 1)
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
	mkDir $rndSTR
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
		mkdir $directoryName/$rndSTR
	done
done

printf "\n~\nTest random files generation in progress . . .\n~\n"
# populate the new random test files tree with random files:
allDirectories=$(find . -type d)
for directory in ${allDirectories[@]}
do
	howManyFilesToCreate=$(seq $rangeOfRNDfilesPerFolder | shuf | head -n 1)
	for j in $(seq 0 $howManyFilesToCreate)
	do
		set_rndSTR
		for fileType in ${fileTypesToMake[@]}
		do
			echo "" > "$directory/$rndSTR.$fileType"
		done
	done
done
exit

cd ..

printf "\n~\nDONE. Random folder and files tree is in the testFiles directory.\n~\n"