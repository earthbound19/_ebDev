# DESCRIPTION
# Creates tweaked copies of all hexplt files in the current directory, with the possible changes including chroma (c), and/or hue (h), and/or lightness (l). Accomplishes this via repeat calls and capture of output from print_altered_hexplt_OKLAB.js. Modded hexplt files are named after the original, but adding _mod to the file name.

# WARNING
# If you already have hexplt files modified from originals but with _mod.hexplt in the file name, this script will clobber (overwrite) them without warning.

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
echo "full path to script to call repeatedly is: $pathToJSfile"

allHexpltFiles=( $(find ~+ -maxdepth 1 -type f -iname "*.hexplt") )

for hexpltFile in ${allHexpltFiles[@]}
do
	echo "obtaining changed values for:"
	echo $hexpltFile . . .
	changedValues=( $(node $pathToJSfile -i $hexpltFile $parameters) )
	# ${hexpltFile%.*} gets the full path to the hexplt file, minus the extension:
	printf '%s\n' "${changedValues[@]}" > ${hexpltFile%.*}_mod.hexplt
done

echo "DONE. Modified files are named after the originals, but add _mod to the file name."