# DESCRIPTION
# Makes modified copies of SVG $1, replacing the color $2 in each copy with every respective color from source palette $3, in a subfolder. I asked Mr. Spock for a way to say that succinctly, and he warned me that "respective" would not be understood by some. I don't care. Oh, he just also warned me that not everyone knows what "succinctly" means. Result files are put in a subfolder and in file named after the source file, zero-padded color number in the palette (01, 02, 03 etc.), and the source palette.

# DEPENDENCIES
# findPalette.sh and the _ebPalettes repository configured so that palettes are findable in its PATH (see). Optionally also getRandomPaletteFileName.sh.

# USAGE
# Run with these parameters:
# - $1 REQUIRED. Source SVG file name.
# - $2 OPTIONAL. RGB hex color code in format f800fc (six hex digits, no starting # symbol) to search and replace with colors from palette file $3 (one new SVG file per color). If omitted, defaults to ffffff.
# - $3 OPTIONAL. Source palette file name findable via findPalette.sh. If omitted, a random palette file name is found from the _ebPalettes repository and used (via getRandomPaletteFileName.sh)


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (svg file to make color-replaced copies of) passed to script. Exit."; exit 1; else svgFileName=$1; fi

# Set a default that will be overriden in the next check if $3 was passed to script:
replaceThisHexColor='ffffff'
if [ "$2" ]
then
	# check that $3 is in hex color code format; if so use it, if not exit with error.
	echo ""
	echo "Attempt RGB hex color code from parameter \$2, $2 . . ."
	replaceThisHexColor=$(echo $2 | grep -i -o "[0-9a-f]\{6\}")
	# The result of that operation will be that $replaceThisHexColor will be empty if no match was found, and not empty if a match was found. This check uses that fact:
	if [ "$replaceThisHexColor" != "" ]
	then
		echo "Will attempt to replace color $replaceThisHexColor in copies of $svgFileName."
	else
		echo "PROBLEM: parameter \$2 nonconformant to sRGB hex color code format. Exit."
		exit 2
	fi
fi

# If no $3 (source palette file) passed to script OR $3 is "RANDOM", retrieve a random production palette from _ebPalettes, and use that for colors. Otherwise, create the array from the list in the filename specified in $3.
if [ ! "$3" ]
then
	paletteFile=$(getRandomPaletteFileName.sh)
	# undesired redundancy I'd like to mitigate maybe by changing that script: that doesn't have the full path. Get it this way:
	paletteFile=$(find $EB_PALETTES_ROOT_DIR -iname "$paletteFile")
else
	# Search for palette with utility script; exit with error if it returns nothing:
	paletteFile=$(findPalette.sh $3)
	if [ "$paletteFile" == "" ]
	then
		echo "!---------------------------------------------------------------!"
		echo "No file of name $3 found. Consult findPalette.sh. Exit."
		echo "!---------------------------------------------------------------!"
		exit 3
	fi
fi
echo "File name $paletteFile found or randomly retrieved! PROCEEDING. IN ALL CAPS."

hexColors=( $(grep -i -o '#[0-9a-f]\{6\}' $paletteFile) )
numHexColors=${#hexColors[@]}
digitsToPadTo=${#numHexColors[@]}; digitsToPadTo=${#numHexColors}

paletteFileBaseName="${paletteFile##*/}"
fileNameNoExt=${paletteFileBaseName%.*}

rndString=$(cat /dev/urandom | tr -dc 'a-hj-km-np-z2-9' | head -c 7)
subDirForRenders=_${svgFileName%.*}__"$fileNameNoExt"

if [ ! -d $subDirForRenders ]
then
	mkdir $subDirForRenders
fi

i=0
for color in ${hexColors[@]}
do
	i=$((i + 1))
	countString=$(printf "%0""$digitsToPadTo""d\n" $i)
	echo Generating variant $i of $numHexColors . . .
	# IF we wanted to strip any leading # :
	# color="${color: -6}"
	tmpRenderFileName="$countString"__"${svgFileName%.*}"__"$fileNameNoExt"_"$color".svg
	moveToFileAfterRender="$subDirForRenders"/"$tmpRenderFileName"
	cp $svgFileName $tmpRenderFileName
echo ----------------------------------
	# REPLACE $replaceThisHexColor with $color:
		# DEPRECATED less flexible replace pattern:
		# sed -i "s/fill=\"#$replaceThisHexColor\"/fill=\"$color\"/" $tmpRenderFileName
	# NEW more flexible replace pattern that covers more SVG hex color code formatting options:
	sed -i -E "s/(fill[=:]\s*[\"']?)#?($replaceThisHexColor)([\"']?)/\1$color\3/g" "$tmpRenderFileName"
		# VARIANT of that if $color does NOT include a # character:
		# sed -i -E "s/(fill[=:]\s*[\"']?)(#?)($replaceThisHexColor)([\"']?)/\1\2$color\4/g" "$tmpRenderFileName"
	mv $tmpRenderFileName $moveToFileAfterRender
done

echo ""
echo "CREATED $numHexColors copies of $svgFileName, in subdirectory $subDirForRenders, replacing color $replaceThisHexColor with in each with respective colors from palette $paletteFile.