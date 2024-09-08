# DESCRIPTION
# runs paletteCompareColoraide.py repeatedly, for every .hexplt (list of RGB colors in hex format) pair in the current directory, printing the results to paletteDifferenceRankings.txt.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Additional switches to be passed to the called python script. At this writing that could be '-c <name of colorspace>' to use for comparison in the called script, paletteCompareColoraide.py. If omitted, that script uses a default (at this writing, HCT as 'hct', or functionally '-c hct').
# For example, to do comparisons with the default color space (no parameter $1), run:
#    allPalettesCompareColoraide.sh
# To override the default color space for comparison, use the paletteCompareColoraide.py switch for a valid color space name (see documentation referenced from paletteCompareColoraide.py), enclosed in quotes, such as:
#    allPalettesCompareColoraide.sh '-c okhsl'
# NOTES
# This script was adapted from allPalettesCompareCIECAM02.sh, and this my be preferable to that.


# CODE
# set default empty $additionalSwitches:
additionalSwitches=
if [ "$1" ]; then additionalSwitches=$1; fi

hexpltFileNames=($(find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n'))
comparePyScriptFullPath=$(getFullPathToFile.sh paletteCompareColoraide.py)

if [ ! -f paletteDifferenceRankings.txt ]
then
	# create new palette comparisons ranking file:
	printf "" > paletteDifferenceRankings.txt
	# List all possible pairs of file type .hexplt, order is not important, repetition is not allowed (math algorithm N pick 2).
	i_count=0
	for i in ${hexpltFileNames[@]}
	do
		i_count=$(( i_count + 1 ))
		# Remove element i from a copy of the array so that we only iterate through the remaining in the array which have not already been compared; re http://Unix.stackexchange.com/a/68323 :
		allHexplts_innerLoop=("${hexpltFileNames[@]:$i_count}")
				# echo size of arr for inner loop is ${#allHexplts_innerLoop[@]}
		for j in ${allHexplts_innerLoop[@]}
		do
			echo "Comparing $i and $j . . ."
			echo "also passing $additionalSwitches . ." 
			deltaE=$(python $comparePyScriptFullPath --firstpalette $i --secondpalette $j $additionalSwitches)
			# OY! :
			comparisonLogString="$deltaE""|""$i""|""$j"
			printf "$comparisonLogString\n" >> paletteDifferenceRankings.txt
		done
	done
else
	echo "NOTE: comparison rankings file paletteDifferenceRankings.txt already exists. Will not clobber. Skip. If you wish to re-run comparisons, delete that file, and run this script again."
fi