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
# - $5 OPTIONAL. IF $4 IS PROVIDED, you probably want to provide this also, as the script does math you may not want if you don't provide $5. Number of tiles down of tiles-assembled image (rows).
# EXAMPLE COMMAND; create a palette image from the hex color list RGB_combos_of_255_127_and_0_repetition_allowed.hexplt, where each tile is a square 250px wide, the palette image being 5 columns wide and 6 rows down, with squares in the palette rendered in random order:
#    renderHexPalette.sh RGB_combos_of_255_127_and_0_repetition_allowed.hexplt 250 foo 5 6
# ANOTHER EXAMPLE COMMAND; create a palette image from tigerDogRabbit_many_shades.hexplt, with each tile 300 pixels wide, no shuffling, the script deciding how many across and down to make the tiles:
#    renderHexPalette.sh tigerDogRabbit_many_shades.hexplt 300 tigerDogRabbit_many_shades.hexplt
# ANOTHER EXAMPLE COMMAND; use the same palette and let the script use all defaults:
#    renderHexPalette.sh tigerDogRabbit_many_shades.hexplt


# CODE
# TO DO
# - UM. WOULDN'T THIS BE A TON FASTER creating a ppm and then upscaling it by nearest neighbor method?! Redo script (or make variant method script) for that?! -- trying that in hexplt2ppm.sh.
# - Adapt this to do double-wide half-down ratios by multiples of two, e.g. 4:2, 8:4, 16:8 etc. (not just 2:1).
# - Allow handling of a hex color on any line with or without # in front of it.
# - Allow comments in .hexplt files (decide on a parse marker for them and ignore all whitespace before that marker, and also ignore the marker itself and everything after it on the line).
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

# WHETHER NUM tiles across (and down) is specified; if so, use as specified, if not so, do some math to figure for a 2:1 aspect;
# $4 is across. If $4 is not specified, do some math. Otherwise use $4:
if [ ! $4 ]
then
	# Get number of lines (colors). The following awk command works around potential incorrect line count; re: https://stackoverflow.com/a/28038682/1397555 :
	numColors=$(awk 'END{print NR}' $hexColorSrcFullPath)
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
	# Get number of lines (colors, yes again, if so). Square root of that / 2 will be the number of rows in the rendered palette.
# TO DO: Update all scripts that count lines with the following form of fix:
	numColors=$(awk 'END{print NR}' $hexColorSrcFullPath)
			# echo numColors is $numColors\.
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

# COMMENT out these test echoes and exit statement in production:
# echo "values:"
# echo "paletteFile $paletteFile"
# echo "tileEdgeLen $tileEdgeLen"
# echo "shuffleValues $shuffleValues"
# echo "numColors $numColors"
# echo "sqrtOfColorCount $sqrtOfColorCount"
# echo "tilesAcross $tilesAcross"
# echo "tilesDown $tilesDown"
# exit
# END SETUP GLOBAL VARIABLES
# =============

if [ -d ./$paletteFile.colors ]
then
# TO DO
# Add a yes/no delete prompt here?
	rm -rf $paletteFile.colors
fi

if [ ! -d ./_hexPaletteIMGgenTMP_2bbVyVxD ]
then
	mkdir ./_hexPaletteIMGgenTMP_2bbVyVxD
else
	rm -rf _hexPaletteIMGgenTMP_2bbVyVxD
	mkdir ./_hexPaletteIMGgenTMP_2bbVyVxD
fi

# this here complexity solves a problem of not reading a last line if it doesn't end with a new line; dunno how but magic says OK re http://stackoverflow.com/a/31398490 ;
# make directory of color tiles from palette:
while IFS= read -r line || [ -n "$line" ]
do
	# IF A SCRIPT THAT I DEVELOPED WORKED ONCE UPON A TIME BUT DOESN'T ANYMORE, it is because sed on windows is inserting $#@! windows newlines into stdin/out! &@*(@!! FIXED with tr -d '\15\32':
	hexNoHash=$(echo $line | sed 's/\#//g' | tr -d '\15\32')
	echo "running command: magick convert -size "$tileEdgeLen"x"$tileEdgeLen" xc:\#$hexNoHash _hexPaletteIMGgenTMP_2bbVyVxD/$hexNoHash.png"
	magick convert -size "$tileEdgeLen"x"$tileEdgeLen" xc:\#$hexNoHash _hexPaletteIMGgenTMP_2bbVyVxD/$hexNoHash.png
done < $hexColorSrcFullPath

# TO DO? : implement e.g. -tile 8x40 flag depending on desired aspect, etc. (will determine values of $tilesAcross and $tilesDown depending on desired aspect?)

# make the actual montage image. Example command: magick montage colors/5A6D40.png colors/757F26.png colors/C68C15.png colors/8F322F.png colors/954B29.png out.png
# make temporary script to create a grid montage of the colors:
echo "magick montage -tile $tilesAcross"x"$tilesDown -background '#919191' -geometry $tileEdgeLen"x"$tileEdgeLen+0+0 \\" > mkGridHead.txt

  # convert hex color scheme text list file to parameter list for ~magick; AGAIN WITH THE NEED to unbork windows newlines (via tr):
sed 's/.*#\(.*\)$/_hexPaletteIMGgenTMP_2bbVyVxD\/\1.png \\/' $hexColorSrcFullPath | tr -d '\15\32' > ./mkGridSRCimgs.txt
# IF $shuffleValues is nonzero, randomly sort that list:
	if [ $shuffleValues -ne 0 ]; then shuf ./mkGridSRCimgs.txt > ./tmp_3A7u2ZymRgdss4rsXuxs.txt; rm ./mkGridSRCimgs.txt; mv ./tmp_3A7u2ZymRgdss4rsXuxs.txt ./mkGridSRCimgs.txt; fi
echo $renderTarget > mkGridTail.txt
cat mkGridHead.txt mkGridSRCimgs.txt mkGridTail.txt > mkColorPaletteGrid.sh

rm mkGridHead.txt mkGridSRCimgs.txt mkGridTail.txt
chmod 777 ./mkColorPaletteGrid.sh

./mkColorPaletteGrid.sh
# mv ./mkColorPaletteGrid.sh ./$paletteFile-mkColorPaletteGrid.sh.txt
	# OR, to delete that if you've no permanent need of it:
	rm ./mkColorPaletteGrid.sh
mv _hexPaletteIMGgenTMP_2bbVyVxD $paletteFile.colors
	# OR, to delete that dir if it annoys you ;)  :
	rm -rf _hexPaletteIMGgenTMP_2bbVyVxD
	# AND, if it annoys you, also delete:
	rm -rf $paletteFile.colors

# The next four code lines are optional but I leave them uncommented, as they can dramatically reduce file size:
# echo ""
# echo OPTIMIZING rendered png . . .
# pngquant --skip-if-larger --ext=.png --force --quality 100 --speed 1 --nofs --strip --verbose $renderTarget
# optipng -o7 $renderTarget

echo ""
echo DONE--created color palette image is $renderTarget

# TO DO? : make the following statement optionally true (via parameter), and echo it: "You will also find color swatch images from the palette in the folder $paletteFile.colors."