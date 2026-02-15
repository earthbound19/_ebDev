# DESCRIPTION
# calls uniformFillColorImage.sh repeatedly to create color swatch images (uniform color images) for every color in a source .hexplt file.

# DEPENDENCIES
# findPalette.sh, uniformFillColorImage.sh

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. The dimensions of color swatch images to create in format NxN, for example 400x400 or 200x100. If not provided, or if provided as the word DEFAULT, a default image size is used. (uniformFillColorImage.sh parameter $1). Smallish resolution strongly recommended.
# - $2 OPTIONAL. Anything, such as the word SRSLY, which will cause the script to operate colors from all palette files in all subdirectories also. If omitted, only palette files in the current directory are used.
# Example that will create 450x450 color swatches for every color from every palette (.hexplt) file in the current directory:
#    allHexplt2swatches.sh 450x450
# Example that will do the same using a default resolution:
#    allHexplt2swatches.sh
# Example that will do the same using a default resolution, also for all palette files in every subdirectory:
#    allHexplt2swatches.sh DEFAULT SRSLY
# Example that will do the same using a dimension of 300x300, also for all palette files in every subdirectory:
#    allHexplt2swatches.sh 300x300 SRSLY

# NOTE
# This script supplies uniformFillColorImage.sh with parameters $1 and $2 for that script for every time it calls it, using a different color from the source .hexplt file, for every hexplt file. It assumes full opacity, so per that script's requirement of specifying that in the hex color code, this script appends ff to each color. (The .hexplt format uses six hex digits, not eight; .hexplts also assume full opacity and don't use the 7th and 8th opacity digits in a hex color code.)


# CODE
# this may be overriden by logic on the line after it:
imageResolution=250x250
if [ "$1" ] && [ "$1" != "DEFAULT" ]; then imageResolution=$1; fi

# init an array of directories with . meaning current directory; we will only "change" to the current directory when iterating over the array of directories, unless the check after this adds subdirectories to that array:
directoriesList=('.')
if [ "$2" ]; then subDirSearchParam="-maxdepth 1"; directoriesList+=( $(find . $subDirSearchParam -type d -printf "%P\n" ) ); fi		

pathToSourcePalette=$(findPalette.sh $srcHexpltFile)
if [ "$pathToSourcePalette" == "" ]; then echo "ERROR: source palette file $srcHexpltFile not found. Exit."; exit 1; fi

for directory in ${directoriesList[@]}
do
	pushd . &>/dev/null
	cd $directory
	printf "\n----\ndirectory is $directory\n"
	
	# get array of all .hexplt file names in the current directory
	allHexplts=( $(find . -maxdepth 1 -type f -iname "*.hexplt" -printf "%P\n") )
	for hexplt in ${allHexplts[@]}
	do
		echo hexlpt is $hexplt
		# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
		colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $hexplt | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array

		# for count (n of n) print feedback:
		colorsArrayLength=${#colorsArray[@]}
		i=0
		for color in ${colorsArray[@]}
		do
			i=$((i + 1))
			echo "creating swatch $i of $colorsArrayLength . ."
			uniformFillColorImage.sh $imageResolution "$color"ff
		done
	done
	popd &>/dev/null
done

printf "\nDONE calling uniformFillColorImage.sh for every color in all palettes in the current directory."
if [ "$3" ]; then echo "\nALSO DONE doing the same for all palettes in all subdirectories."; fi