# DESCRIPTION
# Array search replace for a scenario that's pretty specific and which I might only rarely if ever again use this script for.
# Given source files $1 and $2, for every line in search source file $1, searches for that string in working file $3, replacing it with a string from a random line in replace source file $2.

# USAGE
# Run with these parameters:
# - $1 source file name of a file containing string values to search for, 1 per line.
# - $2 source file name of a file containing string values to randomly select one to replace with (when search values from $1 are found), 1 per line.
# - $3 working file name to perform those search and replaces with.
# For example, to find all instances of colors from source palette file 'USA_Southwest_Vivid.hexplt' and replace them with random selections from palette file tweaks_grayer_darker.hexplt, in working file fvbgnc_2021-09-13-zb_v15_RND_colors.svg, run:
#    arraySearchReplace.sh USA_Southwest_Vivid.hexplt tweaks_grayer_darker.hexplt fvbgnc_2021-09-13-zb_v15_RND_colors.svg
# NOTE every time a match is found for a search source string from $1 in working file $3, this script will replace ALL found instances of that string with a random line from replace source $file 2.


# CODE



if [ "$1" ]; then searchSourceFile=$1; else printf "\nNo parameter \$1 (search source file) passed to script. Exit."; exit 1; fi
if [ "$2" ]; then searchReplaceFile=$2; else printf "\nNo parameter \$2 (replace source file) passed to script. Exit."; exit 2; fi
if [ "$3" ]; then workingFile=$3; else printf "\nNo parameter \$3 (working file) passed to script. Exit."; exit 3; fi

searchSourceFileLines=( $(<$searchSourceFile) )
searchReplaceFiles=( $(<$searchReplaceFile) )

# template code that iterates over the resulting array, printing each item:
for line in ${searchSourceFileLines[@]}
do
	# print the search replace array lines, shuffle them randomly, and show only the 1st (effectively, pick a random line) :
	rndLine=$(printf '%s\n' "${searchReplaceFiles[@]}" | shuf | head -n 1)
	# replace all instances of $line with $rndLine in working file:
	echo "replacing any and all instances of $line with $rndLine in file $workingFile . . ."
	sed -i "s/$line/$rndLine/" $workingFile
done