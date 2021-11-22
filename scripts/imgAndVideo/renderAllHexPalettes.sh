# DESCRIPTION
# Runs renderHexPalette.sh for every .hexplt file in the path (non-recursive) from which this script is run. Result: all hex palette files in the current path are rendered. Also optionally recurses into subdirectories. Also has cooldown (no work) periods after every N renders.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Anything, for example the word 'YORP,' which will cause the script to search for palette files only in the current directory. If not provided, script searches subdirectories (recursive search) by default. To use other positional parameters but override the the recursive default (and only search the current directory), pass the word 'NULL' for $1.
# EXAMPLES
# To render all palettes in the current directory, run the script without any argument:
#    renderAllHexPalettes.sh
# To recurse into all subdirectories and render all palettes in them, pass any parameter for $1:
#    renderAllHexPalettes.sh YORP
# To pass additional parameters, examine the positional parameters in renderHexPalette.sh and position them the same here, but don't use $1 for that script here, because $1 is provided by this script as $element in a loop repeatedly calling renderHexPalette.sh (while also, confusingly, $1 is something else to THIS script (ANYWORD or NULL for subdirectory search or not).
# To NOT recurse into subdirectories but also use additional parameters, pass the keyword NULL for $1, e.g.:
#    renderAllHexPalettes.sh NULL 250 NULL 5
# NOTES
# - Like renderHexPalette.sh, this script checks if the render target exists before it enters the cool-down period. It only enters the cool-down period if the render target does not exist (and therefore heavier computing work would be performed).
# - The script has an optinoal cool-down period where it pauses between renders every N render, because if you run this script against thousands of palettes, it cooks your CPU perhaps more constantly and via harder and more continuous work than a CPU should do. To enable this option, find the comment block labeled OPTIONAL COOLDOWN PERIOD, and uncomment it.


# CODE
if [ "$1" ] && [ "$1" != "NULL" ]
then
	# no -maxdepth 1 switch; recurse through subdirectories
	hexpltFilesArray=( $(find . -type f -iname \*.hexplt -printf "%P\n") )
else
	# -maxdepth 1 switch restricts search to current directory
	hexpltFilesArray=( $(find . -maxdepth 1 -type f -iname \*.hexplt -printf "%P\n") )
fi
# for progress feedback print:
hexpltFilesArrayLen=${#hexpltFilesArray[@]}

coolDownEveryNrenders=23
coolDownCounter=0
coolDownSleepSeconds=27
for hexpltFileName in ${hexpltFilesArray[@]}
do
	# I duplicate no-clobber target file check here (same as in (renderHexPalette.sh); if it already exists, no point loading that script which checks if it exists; that's just an extra operation (slowdown). This also sidesteps the problem of a sleep period in between lighter weight work (only a file existence check), which would be mostly a waste of time:
	renderTargetFileName=${hexpltFileName%.*}.png
	if [ -f $renderTargetFileName ]
	then
		printf "\nRender target $renderTargetFileName already exists (check from renderAllHexPalettes.sh). Will skip render attempt."
		# (else block isn't run; nothing more is done in this loop in this case.)
	else
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
		printf "\nRender target $renderTargetFileName does not exist (check from renderAllHexPalettes.sh)\nWill run render command:\n$renderCommand"
		# Run the actual render command:
		$renderCommand
	fi
done

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path for which there was not already a corresponding .png image. Palette images are named after the source *.hexplt files. If you passed any parameter to this script, this has been done recursively through all subfolders also."