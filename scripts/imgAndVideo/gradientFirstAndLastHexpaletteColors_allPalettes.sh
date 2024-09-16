# DESCRIPTION
# Repeatedly calls `gradientFirstAndLastHexpaletteColors.sh`, doing this:
# - for every .hexplt format file (hex palette) in the current directory:
# - retrieve the first and last color in the palette
# - interpolate N ($1) colors (to create a gradient) from the first to last color through oklab space
# - write that result over the original palette file

# WARNING
# DESTRUCTIVE. Overwrites the original files, very probably permanently modifying their contents. (The only way it wouldn't be a change is if the operation happens to create the same result as the original file.) Prompts for a given password to verify the operation, or takes the password as a parameter to overwrite files without warning.

# USAGE
# To do the operation in DESCRIPTION for every .hexplt format file in the current directory, run with these parameters:
# - $1 REQUIRED. The number of colors in the intended gradient of each modified .hexplt file
# - $2 OPTIONAL. Any other flags that may be passed to `interpolateTwoSRGBColors_coloraide.py` (see), such as a colorpsace specifier flag. Must be surrounded in quote marks.
# - $3 OPTIONAL. The word SYMBCOZ, which will cause the script to perform operations without warning. If omitted, you are prompted to type this password to continue.
# For example, to run the script and be prompted for this password, run it with only a number of colors parameter:
#    gradientFirstAndLastHexpaletteColors_allPalettes.sh
# To run the script and perform the changes on all files using 256 colors per file without warning, run the script with that password as the second parameter:
#    gradientFirstAndLastHexpaletteColors_allPalettes.sh 256 SYMBCOZ

# CODE
# TO DO
# rewrite and rename or supercede this and the calling script to call a script that uses the coloraide library, with a parameter accepting any valid color space for interpolation; re: https://facelessuser.github.io/coloraide/interpolation/#mixing
if [ "$1" ]; then gradientColorsN=$1; else printf "\nNo parameter \$1 (the number of colors in the intended gradient of each modified .hexplt file) passed to script. Exit."; exit 1; fi

if [ "$2" ]; then additionalSwitches=$2; fi

# if $2 passed and equals SYMBCOZ, bypass check. Otherwise do check.
if [ "$3" != "SYMBCOZ" ]
then
	echo ''
	echo 'WARNING: this script will overwrite every .hexplt format file'
	echo 'in the current directory with changes as given in the'
	echo '"DESCRIPTION" comment in the source code (SEE).'
	echo 'If this is what you want to do, type:'
	echo ''
	echo 'SYMBCOZ'
	echo ''
	echo '-- and then press ENTER.'
	echo "If that is NOT what you want to do, press CTRL+z or CTRL+c,"
	echo " or type something else and press ENTER, to terminate this"
	echo "script."

	read -p "TYPE HERE: " USERINPUT

	if [ $USERINPUT != "SYMBCOZ" ]
	then
		echo "User input does not equal SYMBCOZ. Script will exit without doing anything."
		exit 1
	else
		echo "User input equals pass string. Will proceed."
	fi
fi

# get array of all .hexplt format files in the current directory:
filesArray=( $(find . -maxdepth 1 -type f -iname "*.hexplt" -printf "%P\n") )

for file in ${filesArray[@]}
do
	echo "interpolating $gradientColorsN colors from first to last in file $file and overwriting it . . ."
	# make an array of the interpolation result, because it failed if I tried to pipe that directly back to the file:
	newGradient=( $(gradientFirstAndLastHexpaletteColors.sh $file $gradientColorsN $additionalSwitches) )
	# print that array result (one element per line) back to the file:
	printf '%s\n' "${newGradient[@]}" > $file
done