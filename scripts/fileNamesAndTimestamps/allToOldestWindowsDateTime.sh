# DESCRIPTION
# Runs `toOldestWindowsDateTime.sh` for all files in the current directory, and optionally all subdirectories.

# USAGE
# To run `toOldestWindowsDateTime.sh` for all files in the current directory (and not subdirectories), run this script without any parameter:
#    allToOldestWindowsDateTime.sh
# To run `toOldestWindowsDateTime.sh` for all files in the current directory and all subdirectories, run with any parameter, for example the word 'WABYEG':
#    allToOldestWindowsDateTime.sh WABYEG

# CODE
# If no parameter one, maxdepthParameter will be left at default, which causes find to search only the current directory:
maxdepthParameter='-maxdepth 1'
# If parameter one is passed to script, that changes to nothing, and find's default recursive search will be used (as no maxdepth switch will be passed) :
if [ "$1" ]; then maxdepthParameter=''; fi

allFiles=($(find . $maxdepthParameter -type f -printf "%P\n"))

for file in ${allFiles[@]}
do
	echo "Running toOldestWindowsDateTime.sh for file \"$file\" . . ."
	toOldestWindowsDateTime.sh $file
done