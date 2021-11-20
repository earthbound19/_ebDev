# DESCRIPTION
# Takes a list of hex color codes, one per line, and renders a PNG image composed of tiles of those colors (a palette image), via ImageMagick. This script is inefficient; there are probably much faster ways to make a palette image in the structure/format made by this script (it creates color tile images and then montages them), but at this writing, this script is what I have.

# DEPENDENCIES
# - ImageMagick
# - Optionally a file `~/palettesRootDir.txt` (in your home folder) which contains one line, which is a Unix-style path to the folder where you keep hex palette (`.hexplt`) files. If this file is not found, the script searches for palette files in the current directory.

# USAGE
# Run this script with the following parameters:
# - $1 A palette file in `.hexplt` format, which is a list of RGB colors expressed as hexadecimal (hex color codes), one color per line. If this file is in the directory you run this script from, it will be used. If the file is not in the current directory, it may be anywhere in a directory tree in a path given in a file `~/palettesRootDir.txt`, and the script will find the palette in that directory tree and render from it.
# - $2 OPTIONAL. Edge length of each square tile to be composited into final image. If not provided a default is used.
# - $3 OPTIONAL. If not provided, or provided as string 'NULL' (don't use the single quote marks), the order of elements in the palette will be preserved. If provided and anything other than NULL (for example 2 or foo or 1 or 3), the script will randomly shuffle the hex color files before compositing them to one image. I have gone back and forth on requiring this in the history of this script :/
# - $4 OPTIONAL. Number of tiles across of tiles-assembled image (columns).
# - $5 OPTIONAL. Number of tiles down of tiles-assembled image (rows). At one point I wrote that if $5 was omitted, the script might do wrong math for the number of rows, but I don't see that being the case. If $5 is provided and is too small, the collage will be split vertically into truncated, numbered collages. I don't know why.
# EXAMPLE COMMAND; create a palette image from the hex color list RGB_combos_of_255_127_and_0_repetition_allowed.hexplt, where each tile is a square 250px wide, the palette image being 5 columns wide and 6 rows down, with squares in the palette rendered in random order:
#    renderHexPalette.sh RGB_combos_of_255_127_and_0_repetition_allowed.hexplt 250 foo 5 6
# ANOTHER EXAMPLE COMMAND; create a palette image from tigerDogRabbit_many_shades.hexplt, with each tile 300 pixels wide, no shuffling, the script deciding how many across and down to make the tiles:
#    renderHexPalette.sh tigerDogRabbit_many_shades.hexplt 300 tigerDogRabbit_many_shades.hexplt
# ANOTHER EXAMPLE COMMAND; use the same palette and let the script use all defaults:
#    renderHexPalette.sh tigerDogRabbit_many_shades.hexplt
# NOTE
# This script will work with many kinds of other information present in a .hexplt source file other than RGB hex codes. You can probably have any other arbitrary text, anywhere in the file, including on the same line as RGB hex codes, and it will extract and use only the RGB hex code information. However, no kinds of comments (like # or // at the start of lines) are supported.

# CODE
# TO DO
# - UM. WOULDN'T THIS BE A TON FASTER creating a ppm and then upscaling it by nearest neighbor method?! Redo script (or make variant method script) for that?! -- trying that in hexplt2ppm.sh.
# - Math to determine tile size dynamically for a target total image resolution?

# BEGIN SETUP GLOBAL VARIABLES
paletteFile=$1
# IF RENDER TARGET already exists, abort script with error 2. Otherwise continue.
renderTarget=${paletteFile%.*}.png
if [ -f ./$renderTarget ]
then
	echo Render target $renderTarget already exists\; SKIPPING render.
	# exit with error code
	exit 2
fi
# Effectively, else:
echo Render target $renderTarget does not exist\; WILL ATTEMPT TO RENDER.

# Search current path for $1; if it exists set hexColorSrcFullPath to just $1 (we don't need the full path). If it doesn't exist in the local path, search the path in palettesRootDir.txt and make decisions based on that result:
if [ -e ./$1 ]
then
	hexColorSrcFullPath=$1
	echo File name $paletteFile found in the path this script was run from\! PROCEEDING. IN ALL CAPS.
else	# Search for specified palette file in palettesRootDir (if that dir exists; if it doesn't, exit with an error) :
	if [ -e ~/palettesRootDir.txt ]
	then
		palettesRootDir=$(< ~/palettesRootDir.txt)
				echo palettesRootDir.txt found\;
				echo searching in path $palettesRootDir --
				echo for file $paletteFile . . .
		hexColorSrcFullPath=$(find $palettesRootDir -iname "$paletteFile")
		echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
		if [ "$hexColorSrcFullPath" == "" ]
			then
				echo No file of name $paletteFile found in the path this script was run from OR in path \"$palettesRootDir\" \! ABORTING script.
				exit
			else
				echo File name $paletteFile found in the path \"$palettesRootDir\" \! PROCEEDING. IN ALL CAPS.
		fi
	else
		echo !--------------------------------------------------------!
		echo file ~/palettesRootDir.txt \(in your root user path\) not found. This file should exist and have one line, which is the path of your palette text files e.g.:
		echo
		echo /cygdrive/c/_ebdev/scripts/imgAndVideo/palettes
		echo
		echo ABORTING script.
		echo !--------------------------------------------------------!
		exit
	fi
fi
if [ "$2" ]; then tileEdgeLen=$2; else tileEdgeLen=250; fi

# Set default no shuffle, and only alter if $3 is not equal to 'NULL':
shuffleValues=0
if [ "$3" ] && [ "$3" != "NULL" ]
then
	shuffleValues=1
	echo echo Value of parameter \$3 is NONZERO\; WILL SHUFFLE read values.
fi

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -o '#[0-9a-f]\{6\}' $hexColorSrcFullPath | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array
# Get number of colors (from array):
numColors=${#colorsArray[@]}

# WHETHER NUM tiles across (and down) is specified; if so, use as specified, if not so, do some math to figure for a 2:1 aspect;
# $4 is across. If $4 is not specified, do some math. Otherwise use $4:
if [ ! $4 ]
then
	# If number of colors is above N (12?), try to render a ~2:1 aspect palette (columns will be the square root of the number of colors, x2). If it is N or below, render only one row, with as many columns as there are colors.
	N=12
	if [[ $numColors -le $N ]]
	then
		# printf "\nAt $numColors, number of colors in palette is $N or less; will render only one row of that many colors."
		tilesAcross=$numColors
	else
		# printf "\nAt $numColors, number of colors in palette is greater than $N; will calculate rows and columns to try to render a ~2:1 aspect palette."
		sqrtOfColorCount=$(echo "sqrt ($numColors)" | bc)
		tilesAcross=$(( $sqrtOfColorCount * 2 ))
	fi
	printf "\ntilesAcross is $tilesAcross.\n"
else
	tilesAcross=$4
fi

# $5 is down. If $5 is not specified, do some math. Otherwise use $5.
if [ ! $5 ]
then
	sqrtOfColorCount=$(echo "sqrt ($numColors)" | bc)
			# echo sqrtOfColorCount is $sqrtOfColorCount
	tilesDown=$(( $sqrtOfColorCount / 2 ))
	# If the value of ($tilesAcross times $tilesDown) is less than $numColors (the total number of colors), we will fail to print all colors in the palette; add rows to the print queue for as long as necessary:
	tilesToRender=$(( $tilesAcross * $tilesDown ))
	# echo tilesToRender is $tilesToRender\.
	while [ $tilesToRender -lt $numColors ]
	do
		# echo tilesDown was $tilesDown.
		tilesDown=$(( $tilesDown + 1 ))
		tilesToRender=$(( $tilesAcross * $tilesDown ))
				# TO DO: checking that twice . . . is that a code smell? Rework for more concise/elegant/sensical logic?
	done
else
	tilesDown=$5
fi

# END SETUP GLOBAL VARIABLES
# =============

# setup temp swatches / montage render dir:
# prior dir name that meant I can't run this script concurrently: _hexPaletteIMGgenTMP_2bbVyVxD
rndSTR=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 8)
tmp_render_dir=_hexPaletteIMGgenTMP_"$rndSTR"
if [ ! -d $tmp_render_dir ]		# this will only be true in ridiculous circumstances :shrug:
then
	mkdir $tmp_render_dir
else
	rm -rf $tmp_render_dir
	mkdir $tmp_render_dir
fi

# make directory of color tiles from palette:
for color in ${colorsArray[@]}
do
	echo "running command: magick convert -size "$tileEdgeLen"x"$tileEdgeLen" xc:\#$color $tmp_render_dir/$color.png"
	magick convert -size "$tileEdgeLen"x"$tileEdgeLen" xc:\#$color $tmp_render_dir/$color.png
done

# TO DO? : implement e.g. -tile 8x40 flag depending on desired aspect, etc. (will determine values of $tilesAcross and $tilesDown depending on desired aspect?)

# make the actual montage image. Example command: magick montage colors/5A6D40.png colors/757F26.png colors/C68C15.png colors/8F322F.png colors/954B29.png out.png
# make temporary script to create a grid montage of the colors:
echo "magick montage -tile $tilesAcross"x"$tilesDown -background '#919191' -geometry $tileEdgeLen"x"$tileEdgeLen+0+0 \\" > mkGridHead.txt

# IF $shuffleValues is nonzero, randomly sort color list (array):
if [ $shuffleValues -ne 0 ]; then colorsArray=( $(shuf -e ${colorsArray[@]}) ); fi

# convert hex color scheme text list file to parameter list for ~magick:
printf "" > ./mkGridSRCimgs.txt
for color in ${colorsArray[@]}
do
	# escaped escaped \\ in the printf command (to print a backslash \ character),
	printf "$tmp_render_dir"/"$color"".png \\" >> ./mkGridSRCimgs.txt
	# FOLLOWED BY a newline \n	:
	printf "\n" >> ./mkGridSRCimgs.txt
done

echo $renderTarget > mkGridTail.txt
rndSTRtwo=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 8)
tempScriptFileName=mkColorPaletteGrid_tmp_"$rndSTR".sh
cat mkGridHead.txt mkGridSRCimgs.txt mkGridTail.txt > ./$tempScriptFileName

rm mkGridHead.txt mkGridSRCimgs.txt mkGridTail.txt
chmod 777 ./$tempScriptFileName
./$tempScriptFileName
rm ./$tempScriptFileName

# OPTIONALLY leave palette swatched dir behind (by renaming temp dir to it); uncomment these next lines to do that:
# paletteSwatchesDir=${hexColorSrcFullPath%.*}_swatches
# if [ -d ./$paletteFile.colors ]
# then

	# rm -rf $paletteFile.colors
# fi
# mv $tmp_render_dir $paletteSwatchesDir
# OR:
rm -rf $tmp_render_dir

# To optionally reduce the file size a lot (maybe?) uncomment these next lines:
# echo ""
# echo OPTIMIZING rendered png . . .
# pngquant --skip-if-larger --ext=.png --force --quality 100 --speed 1 --nofs --strip --verbose $renderTarget
# optipng -o7 $renderTarget

echo ""
echo DONE--created color palette image is $renderTarget

# TO DO? : make the following statement optionally true (via parameter), and echo it: "You will also find color swatch images from the palette in the folder $paletteFile.colors."