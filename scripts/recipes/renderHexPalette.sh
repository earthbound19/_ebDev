# DESCRIPTION
# Takes a list of hex color codes, one per line, and renders a PNG image composed of tiles of those colors (a palette image), via other scripts.

# DEPENDENCIES
# - graphicsmagick, hexplt2ppm.sh, img2imgNN.sh
# - Optionally a file `~/palettesRootDir.txt` (in your home folder) which contains one line, which is a Unix-style path to the folder where you keep hex palette (`.hexplt`) files. If this file is not found, the script searches for palette files in the current directory.

# USAGE
# Run this script with the following parameters:
# - $1 A palette file in `.hexplt` format, which is a list of RGB colors expressed as hexadecimal (hex color codes), one color per line. If this file is in the directory you run this script from, it will be used. If the file is not in the current directory, it may be anywhere in a directory tree in a path given in a file `~/palettesRootDir.txt`, and the script will find the palette in that directory tree and render from it.
# - $2 OPTIONAL. Edge length of each square tile in final image. (Image width will be this X columns; image height will be this X rows.) If not provided a default is used. To use additional parameters and use the default for this, provide the string 'NULL' for this.
# - $3 OPTIONAL. If not provided, or provided as string 'NULL', the order of elements in the palette will be preserved. If provided and anything other than NULL (for example 2 or foo or 1 or 3), the script will randomly shuffle the hex color files before compositing them to one image. I have gone back and forth on requiring this in the history of this script :/
# - $4 OPTIONAL. Columns. If omitted, the script will try to come up with a number of columns that will best fit color tiles with minimal wasted gray "no color" remaining tiles. AND/OR, if columns and rows syntax is found in the source hexplt file (see NOTES) and you omit $4, it will use the columns and rows specified in the source hexplt.
# - $5 OPTIONAL. Rows. If omitted, the script will do math to make sure the needed number of rows are used to render all tiles with the given number of columns. At one point I wrote that if $5 was omitted, the script might do wrong math for the number of rows, but I don't see that being the case. If $5 is provided and is too small, the collage will be split vertically into truncated, numbered collages. I don't know why. Also, you can't use $5 unless you use $4.
# EXAMPLE COMMAND; create a palette image from the hex color list RGB_combos_of_255_127_and_0_repetition_allowed.hexplt, where each tile is a square 250px wide, the palette is 5 columns wide and 6 rows down, and tiles in the palette are rendered in random order:
#    renderHexPalette.sh RGB_combos_of_255_127_and_0_repetition_allowed.hexplt 250 foo 5 6
# ANOTHER EXAMPLE COMMAND; create a palette image from tigerDogRabbit_many_shades.hexplt, with each tile 300 pixels wide, no shuffling, the script deciding how many across and down to make the tiles:
#    renderHexPalette.sh tigerDogRabbit_many_shades.hexplt 300 tigerDogRabbit_many_shades.hexplt
# ANOTHER EXAMPLE COMMAND; use the same palette and let the script use all defaults, including any number of tiles (columns) accross and down specified in the source hexplt:
#    renderHexPalette.sh tigerDogRabbit_many_shades.hexplt
# NOTES
# - This script will work with many kinds of other information present in a .hexplt source file other than RGB hex codes. You can probably have any other arbitrary text, anywhere in the file, including on the same line as RGB hex codes, and it will extract and use only the RGB hex code information. However, no kinds of comments (like # or // at the start of lines) are supported.
# - Source hexplt files may contain syntax to define the desired number of columns and rows to render them with. The syntax is to write the word "columns" followed by a number on any line of the file, and optionally also the word "rows" followed by a number on any line of the file, like this:
#    columns 7 rows 8
# -- or like this:
#    #D29B7D columns 7, rows 8
# All that matters is that the word 'columns' appears followed by a number. You can specify columns only, and this script will figure out the needed number of rows. You can also specify rows (in which case the syntax is the keyword 'rows' followed by a number), and the script will use that number of rows, with the same conditions as for the number of tiles (rows) down parameters to this script.
# - I RECOMMEND that you specify the columns and rows as a comment after the first color in the palette, on the same line. This way, the `allRGBhexColorSort`~ scripts may be able to sort colors in palettes (it may not work if the columns and rows are specified on their own line).
# - If in a source hexplt file you specify (for example) "rows 4" but don't specify any columns, the script will interpret rows as the number of columns, and it may cut off tiles (not all color tiles will render). You must specify columns in the source hexplt file if you specify rows.


# CODE
# TO DO
# - implement e.g. -tile 8x40 flag depending on desired aspect, etc. (will determine values of $columns and $rows depending on desired aspect)?
# - UM. WOULDN'T THIS BE A TON FASTER creating a ppm and then upscaling it by nearest neighbor method?! Redo script (or make variant method script) for that?! -- trying that in hexplt2ppm.sh.
# - Math to determine tile size dynamically for a target total image resolution?

# BEGIN SETUP GLOBAL VARIABLES
paletteFile=$1
# IF RENDER TARGET already exists, abort script with error 2. Otherwise continue.
PPMrenderTarget=${paletteFile%.*}.ppm
PNGrenderTarget=${paletteFile%.*}.png
if [ -f ./$PNGrenderTarget ]
then
	echo Render target $PNGrenderTarget already exists\; SKIPPING render.
	# exit with error code
	exit 2
fi
# Effectively, else:
echo Render target $PNGrenderTarget does not exist\; WILL ATTEMPT TO RENDER.

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
				exit 2
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
		exit 3
	fi
fi
if [ "$2" ] && [ "$2" != "NULL" ]; then tileEdgeLen=$2; else tileEdgeLen=250; fi

# Set default no shuffle, and only alter if $3 is not equal to 'NULL':
shuffleValues=0
if [ "$3" ] && [ "$3" != "NULL" ]
then
	shuffleValues=1
	echo echo Value of parameter \$3 is NONZERO\; WILL SHUFFLE read values.
fi

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $hexColorSrcFullPath | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array
# Get number of colors (from array):
numColors=${#colorsArray[@]}

# IF NUM TILES ACROSS (AND DOWN) IS SPECIFIED; use it, if not so, do some math to figure for a 2:1 aspect; OR look for instruction syntax in source hexplt (read on) ;
# $4 is across. If $4 is not specified, do some math. Otherwise use $4:
if [ ! $4 ]
then
	# FIRST LOOK FOR SYNTAX IN source hexplt that specifies number of columns, and use it if it's there; set number of render tiles (columns) accross based on any source hexplt file content:
	columnSyntaxSearchResult=$(grep -E -m 1 'columns' $hexColorSrcFullPath)
	# $columnSyntaxSearchResult will be blank if that search failed; use that fact:
	if [ "$columnSyntaxSearchResult" != "" ]
	then
		columns=$(sed 's/.*columns[^0-9]\{0,\}\([0-9]\{1,\}\).*/\1/g' <<< $columnSyntaxSearchResult)
	# OTHERWISE do math to figure out a hopefully good number of tiles accross:
	else
		# If number of colors is above N (12?), try to render a ~2:1 aspect palette (columns will be the square root of the number of colors, x2). If it is N or below, render only one row, with as many columns as there are colors.
		N=12
		if [[ $numColors -le $N ]]
		then
			# printf "\nAt $numColors, number of colors in palette is $N or less; will render only one row of that many colors."
			columns=$numColors
		else
			# printf "\nAt $numColors, number of colors in palette is greater than $N; will calculate rows and columns to try to render a ~2:1 aspect palette."
			sqrtOfColorCount=$(echo "sqrt ($numColors)" | bc)
			columns=$(( $sqrtOfColorCount * 2 ))
		fi
	fi
else
	columns=$4
fi
printf "\ncolumns is $columns.\n"

# SAME LOGIC as for $4 (but relying on $4 being calculated/set first:
# $5 is down. If $5 is not specified, do some math. Otherwise use $5.
if [ ! $5 ]
then
	# FIRST LOOK FOR SYNTAX IN source hexplt that specifies number of rows, and use it if it's there; set number of render tiles (rows) down based on any source hexplt file content:
	rowsSyntaxSearchResult=$(grep -E -m 1 'rows' $hexColorSrcFullPath)
	# $rowsSyntaxSearchResult will be blank if that search failed; use that fact:
	if [ "$rowsSyntaxSearchResult" != "" ]
	then
		rows=$(sed 's/.*rows[^0-9]\{0,\}\([0-9]\{1,\}\).*/\1/g' <<< $rowsSyntaxSearchResult)
	# OTHERWISE do math to figure out the number of rows needed:
	else
		rows=$(( $numColors / $columns ))
		# if this modulo returns nonzero, we need to add a row; do so:
		modulo=$(( $numColors % $columns ))
		if [ $modulo != "0" ]
		then
			rows=$(( $rows + 1 ))
		fi
	fi
else
	rows=$5
fi
printf "rows is $rows.\n"

# END SETUP GLOBAL VARIABLES
# =============

# IF $shuffleValues is nonzero, randomly sort color list (array):
if [ $shuffleValues -ne 0 ]; then colorsArray=( $(shuf -e ${colorsArray[@]}) ); fi

# vestigal tile render reference:
# magick convert -size "$tileEdgeLen"x"$tileEdgeLen" xc:\#$color $tmp_render_dir/$color.png

# convert source hexplt to intermediary ppm format image if it does not already exist; perhaps erroneously assumes it is what we want if it does exist already:
if [ ! -f $PPMrenderTarget ]
then
	ppmDidNotExistBeforeNow="TRUE"
	hexplt2ppm.sh $paletteFile $columns $rows
fi
# convert that ppm to png:
PNGwidth=$(($tileEdgeLen * $columns))
PNGheight=$(($tileEdgeLen * $rows))
# it's not necessary to pass $PNGheight at the end of this:
img2imgNN.sh $PPMrenderTarget png $PNGwidth
# delete the intermediary ppm file if it didn't exist before this script checked for it:
if [ "$ppmDidNotExistBeforeNow" ]; then rm $PPMrenderTarget; fi

# These next three lines will make palette creation take longer, but optimize the palette png. Comment them out if you don't want that delay:
#echo ""
#echo OPTIMIZING rendered png . . .
#optipng -o7 $PNGrenderTarget

echo ""
echo DONE--created color palette image is $PNGrenderTarget

# TO DO? : make the following statement optionally true (via parameter), and echo it: "You will also find color swatch images from the palette in the folder $paletteFile.colors."