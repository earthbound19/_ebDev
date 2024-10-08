# DESCRIPTION
# Runs renderHexPalette.sh for every .hexplt file in the path (non-recursive) from which this script is run. Result: all hex palette files in the current path are rendered. Also optionally recurses into subdirectories. Also has cooldown (no work) periods after every N renders.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Anything, for example the word 'YORP,' which will cause the script to search for and render palette files in subdirectories also. If not provided, script only searches and renders files in the current directory (and not subdirectories). To use other positional parameters but not render files in subdirectories, pass the word 'NULL' for $1.
# - ADDITIONAL OPTIONAL PARAMETERS. To pass additional parameters, examine the positional parameters in renderHexPalette.sh and position them the same here, but don't use $1 for that script here, because $1 is provided by this script as $element in a loop repeatedly calling renderHexPalette.sh (while also, confusingly, $1 is something else to THIS script (ANYWORD or NULL for subdirectory search or not).
# EXAMPLES
# To render all palettes in the current directory, run the script without any argument:
#    renderAllHexPalettes.sh
# To recurse into all subdirectories and render all palettes in them, pass any parameter other than the word 'NULL' for $1:
#    renderAllHexPalettes.sh YORP
# To NOT recurse into subdirectories but also use additional parameters, pass the keyword NULL for $1, e.g.:
#    renderAllHexPalettes.sh NULL 250 NULL 5
# NOTES
# - The script has an optinoal cool-down period where it pauses between renders every N render, because if you run this script against thousands of palettes, it cooks your CPU perhaps more constantly and via harder and more continuous work than a CPU should do. To enable this option, find the comment block labeled OPTIONAL COOLDOWN PERIOD, and uncomment it.


# CODE
if [ "$1" ] && [ "$1" != "NULL" ]
then
	# param 1 passed; don't use maxdepth 1 switch; causes recursive search through subdirectories
	hexpltFilesArray=( $(find . -type f -iname \*.hexplt -printf "%P\n") )
else
	# param 1 NOT passed; use -maxdepth 1 switch to restricts search to current directory
	hexpltFilesArray=( $(find . -maxdepth 1 -type f -iname \*.hexplt -printf "%P\n") )
fi

# for optional progress feedback print; see BEGIN OPTIONAL COOLDOWN PERIOD comment:
coolDownEveryNrenders=23
coolDownCounter=0
coolDownSleepSeconds=27
for hexpltFileName in ${hexpltFilesArray[@]}
do
# BEGIN OPTIONAL COOLDOWN PERIOD; uncomment these outdented lines if you want that:
# coolDownCounter=$((coolDownCounter + 1))
# cool down period check, and if it is time, cool down:
# moduloResult=$(echo "scale=0; $coolDownCounter % $coolDownEveryNrenders" | bc)
# if [ "$moduloResult" == "0" ]
# then
#	printf "\nWill sleep script actions for $coolDownSleepSeconds seconds to allow cool-down . . ."
# sleep $coolDownSleepSeconds
# fi
# END OPTIONAL COOLDOWN PERIOD
	# Progress feedback and command log print:
	renderCommand="renderHexPalette.sh $hexpltFileName $2 $3 $4 $5 $6"
	# echo "+RENDERING target $renderTargetFileName, as it does not exist; via command:"
	# echo "$renderCommand"
	# Run the actual render command:
	$renderCommand
done

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path for which there was not already a corresponding .png image. Palette images are named after the source *.hexplt files. If you passed any parameter to this script, this has been done recursively through all subfolders also."