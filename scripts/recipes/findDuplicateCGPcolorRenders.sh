# DESCRIPTION
# This script is for a highly custom and hard-to-describe scenario. It finds all .cgp and .sh format files which contain the transformed RGB color triplet patterns in a .rgbplt file (which was used with a color_growth_hexplt.sh batch run or runs), for the current directory. See USAGE. It is possible I will fix the root scripting / render design problems that lead to the need of this script, and thereby obsolete this script.
# Yes, I could just accept multiple renders from the same origin coordinate color in a batch. But no, it's a creative choice.

# USAGE
# Stated problem: I ran and interuptted and resumed color_growth_hexplt.sh repeatedly, resulting in more than one cgp preset for every color in the converted .rgbplt file. I want to narrow it down to one render per color in the palette, deleting any more than one render per color in the palette, keeping the more favorable ones.
# This script lists all .cgp and .sh files in the current directory which have a color RGB tuple format (e.g. '[212,123,57]', but without single quote marks) transformed from the original .rgbplt format (e.g. '212 123 57' without single quote marks). I can then find the corresponding .png files rendered from those .cgp presets, and delete all but my favorite cgp and corresponding png render (pruneByUnmatchedExtension.sh will help there) files, keeping the one that I like best.
# To get help with that, after you've finished all renders via color_growth_hexplt.sh (after it runs the whole script without doing any more renders, assuming you leave all .rendering stub files intact), invoke this script with one parameter, being the .rgbplt file to run this analysis for, e.g.:
#  findDuplicateCGPcolorRenders.sh collectedColors1.rgbplt
# Results will be stored in findDuplicateCGPcolorRenders_sh__log.txt.


# CODE
if ! [ "$1" ]; then echo "No paramater \$1 (an .rgbplt file). Exit."; exit; fi

presetsAndSHsArray=(`gfind . -maxdepth 1 -type f -name "*.cgp" -printf '%f\n' -o -type f -name "*.sh" -printf '%f\n'`)

# reading file to array with IFS='\n' isn't working here (causes other problems, or I don't know what I'm doing): 
foundItems=()
printf "" > findDuplicateCGPcolorRenders_sh__log.txt
while read element
do
	# NOTE this inserts escape \ characters before the [ and ] else the grep search intended won't work as intended, AND (this is insanity!) those \ won't even be created unless I triple-escape them, \\\\ :
	searchString=`echo $element | gsed 's/\([0-9]\{1,\}\) \([0-9]\{1,\}\) \([0-9]\{1,\}\).*/\\\\[\1,\2,\3\\\\]/g'`
	echo "Searching through files for grep match $searchString . . ."
	# echo "$element -> $searchString"
	for searchFile in ${presetsAndSHsArray[@]}
	do
		grep -q "$searchString" $searchFile
		errorLevelSTR=$?
		if [ "$errorLevelSTR" == "0" ]; then foundItems+=($searchFile); fi
	done
	numFoundItems=${#foundItems[@]}
	if [ $numFoundItems -gt 1 ];
		then
		echo "-- $numFoundItems matches for grep search string $searchString; logging . . ."
		echo " - $numFoundItems matches for grep search string $searchString ( converted from $element ) in these files:" >> findDuplicateCGPcolorRenders_sh__log.txt
		for item in ${foundItems[@]}
		do
			echo "  - $item" >> findDuplicateCGPcolorRenders_sh__log.txt
		done
	fi
	# empty that for next inner loop:
	foundItems=()
done < $1

echo ""
echo "DONE. Results are in findDuplicateCGPcolorRenders_sh__log.txt. If that file is empty, no more than one match was found for converted string from each line in file $1. Note that any .sh scripts may be for the same settins as .cgp files that were saved from re-running them (and that you may then delete those .sh scripts). Also note that .sh scripts NOT listed may need to be run to finish those renders."