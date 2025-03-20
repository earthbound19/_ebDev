# DESCRIPTION
# calls SVGrandomColorReplace.sh $1 times with additional parameters to be passed on to that script (see USAGE), but creating copies of the source svg (named after pattern Y_m_d__H_M_S__N), and in a subfolder named after the original file plus random characters) before calling that script to modify the copies. See also SVGsRandomColorReplace.sh, which calls this repeatedly for every SVG file in the current directory. See NOTES under USAGE for another script to use instead of or with this.

# USAGE
# Run with these parameters:
# - $1 REQUIRED. Source SVG file name.
# - $2 REQUIRED. How many copies of the svg to make with random color replacements.
# - $3 OPTIONAL. hexplt (palette) file to use. See parameter $2 in SVGrandomColorReplace.sh. Note that this uses $2 there as $3 here. If $3 is omitted, the script will select a random production palette from a local _ebPalettes repository via `printContentsOfRandomPalette_ls.sh`. If you want to use $4 but not specify any pallette file here with $3 (and have randomly select one), pass the word RANDOM for $3.
# - $4 OPTIONAL. hex color to do random replacements of from hexplt file. See parameter $3 in SVGrandomColorReplace.sh. Note that this uses $3 there as $4 here.
# Example that will create 38 copies of `2021-09-13-zb_v5.svg` with random color replacements via optional parameter $3 (a source .hexplt file, `earth_pigments_dark.hexplt`), replacing hex color 000000 via optional parameter $4:
#    SVGrandomColorReplaceCopies.sh 2021-09-13-zb_v5.svg 38 earth_pigments_dark.hexplt 000000
# NOTES
# - If you call this script from another script a certain way (which, I know, this script calls another script in turn), the $subDirForRenders variable which this script sets will be available (as a new global or environment variable) in the shell that called this script. The way to set that variable in the calling environment is to use `source` before calling this script, like this:
#    source SVGrandomColorReplaceCopies.sh <script parameters>
# -- which may be handy for use of this script in a "recipe" to do multiple passes of replacing specific colors with random selections from palettes. Handy, because if you know the name of the random subfolder it made, you can cd into it to list svg files into an array and modify the files with additional passes.
# - See also SVGsRandomColorReplace.sh, which calls this repeatedly for every SVG file in the current directory. You can for example use this to randomly create many copies of an SVG with random color fills replacing one color, then that to randomly replace another color in all the result files, thereby having two different colors randomly replaced with two different palettes.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (svg file to make color-replaced copies of) passed to script. Exit."; exit 1; else svgFileName=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (how many copies of the svg to make with random color replacements) passed to script. Exit."; exit 2; else howManySVGcopies=$2; fi
# If no $3 (source palette file) passed to script OR $3 is "RANDOM", retrieve a random production palette from _ebPalettes, and use that for colors. Otherwise, create the array from the list in the filename specified in $2.
if [ ! "$3" ] || [ "$3" == "RANDOM" ]
then
	echo "no parameter \$3 passed to script, OR passed as RANDOM; selecting random production palette from _ebPalettes  . . ."
	# calling this with `source` because that script sets a variable retrievedPaletteFileName with just that:
	# using a temp file for memory because if I do command substitution with source, I lose the assignment to retrievedPaletteFileName in the discared subshell:
	source printContentsOfRandomPalette_ls.sh > tmpFile_75JbuqBTN.txt
	rndHexColors=( $(<tmpFile_75JbuqBTN.txt) )
	rm tmpFile_75JbuqBTN.txt
	# modify $retrievedPaletteFileName to just the file name without the path:
	retrievedPaletteFileName="${retrievedPaletteFileName##*/}"
	paletteFile=$retrievedPaletteFileName
else
	paletteFile=$3
fi
paletteFileBaseName=${paletteFile%.*}

if [ "$4" ]; then replaceThisHexColor=$4; fi

rndString=$(cat /dev/urandom | tr -dc 'a-hj-km-np-z2-9' | head -c 7)
subDirForRenders=_${svgFileName%.*}_rndColor_run_"$rndString"

#notwithstanding the chance it exists is extremely low:
if [ ! -d $subDirForRenders ]
then
	mkdir $subDirForRenders
else
	echo "run the script again. The subdirectory already exists (which, what--the chances of that should be extremely low?!)"
	exit 72150
fi

for i in $(seq $howManySVGcopies)
do
	echo Generating variant $i of $generateThisMany . . .
	timestamp=$(date +"%Y%m%d_%H%M%S_%N")
	tmpRenderFileName=_colorSwapping_"$timestamp"_rndColorFill_"$paletteFileBaseName"_$svgFileName
	moveToFileAfterRender="$subDirForRenders"/"$timestamp"_rndColorFill_"$paletteFileBaseName"_$svgFileName
	cp $svgFileName $tmpRenderFileName
echo ----------------------------------
	SVGrandomColorReplace.sh $tmpRenderFileName $paletteFile $replaceThisHexColor
	mv $tmpRenderFileName $moveToFileAfterRender
done

echo ""
echo "CREATED $howManySVGcopies random color replace copies of $svgFileName, in subdirectory $subDirForRenders. If a palette and color to replace were specified, they are ($paletteFile) and ($replaceThisHexColor)."