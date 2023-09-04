# DESCRIPTION
# Creates tweaked copies of all hexplt files in the current directory, with the possible changes including chroma (c), and/or hue (h), and/or lightness (l). Accomplishes this via repeat calls and capture of output from print_altered_hexplt_OKLAB.js. Modded hexplt files are named after the original, but adding _mod to the file name. If a source file name has the substring "_mod" in it, it will skip modifying it. If a render target file name already exists, it will skip render. In both cases it notifies.

# DEPENDENCIES
# A bash or bash-like environment, nodejs, and print_altered_hexplt_OKLAB.js and the node librarires it requires.

# USAGE
# Run with these parameters:
# - $1 a string with the -l, and/or -c, and/or -h paramaters such as you would pass to print_altered_hexplt_OKLAB.js, encased in single or double quote marks. This script provides the -i parameter to that .js script, each time it calls it, by finding and calling it with the name of every .hexplt format file in the current directory.
# For example:
#    alterAllHexpltsOKLAB.sh '-c 0.018 -l 0.068'


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (string of parameters to pass to print_altered_hexplt_OKLAB.js) passed to script. Exit."; exit 1; else parameters=$1; fi

pathToJSfile=$(getFullPathToFile.sh print_altered_hexplt_OKLAB.js)
# echo "full path to script to call repeatedly is: $pathToJSfile"

allHexpltFiles=( $(find ~+ -maxdepth 1 -type f -iname "*.hexplt") )

for hexpltFile in ${allHexpltFiles[@]}
do
	renderTargetFileName=${hexpltFile%.*}_mod.hexplt
	# check if file name has the string "_mod" in it; if so, skip it (don't mod a mod):
	echo "$hexpltFile" | grep "_mod" &>/dev/null
	# if errorlevel ($?) is 0 after that (if we did found a match for the substring we want to avoid), continue work; also only if render target does not already exist:
	if [ "$?" != "0" ] && [ ! -e $renderTargetFileName ]
	then
		echo
		echo "ATTEMPTING MODIFIED COPY OF:"
		echo $hexpltFile . . .
		changedValues=( $(node $pathToJSfile -i $hexpltFile $parameters) )
		# ${hexpltFile%.*} gets the full path to the hexplt file, minus the extension:
		renderTarget=${hexpltFile%.*}_mod.hexplt
		printf '%s\n' "${changedValues[@]}" > $renderTarget
		echo "Modified values written to $renderTarget."
	else
		echo
		echo "SKIPPING modification of source file name $hexpltFile, as the file name indicates it is a modification already, OR a target modification already exists for it."
	fi
done

echo
echo "DONE. Modified files are named after the originals, but add _mod to the file name."