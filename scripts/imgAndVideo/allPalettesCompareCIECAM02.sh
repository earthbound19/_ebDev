# DESCRIPTION
# runs paletteCompareCIECAM02.py repeatedly, for every .hexplt (list of RGB colors in hex format) pair in the current directory, printing the results to paletteDifferenceRankings.txt.

# USAGE
#    allPalettesCompareCIECAM02.sh


# CODE
hexpltFileNames=($(find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n'))
comparePyScriptFullPath=$(getFullPathToFile.sh paletteCompareCIECAM02.py)

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
			deltaE=$(python $comparePyScriptFullPath $i $j)
			# OY! :
			comparisonLogString="$deltaE""|""$i""|""$j"
			printf "$comparisonLogString\n" >> paletteDifferenceRankings.txt
		done
	done
else
	echo "NOTE: comparison rankings file paletteDifferenceRankings.txt already exists. Will not clobber. Skip. If you wish to re-run comparisons, delete that file, and run this script again."
fi