# DESCRIPTION
# Takes a list of hex color codes, one per line, and renders a palette image composed of those colors via GraphicsMagick.

# DEPENDENCIES
# GraphicsMagick e.g. for:
# gm convert
# A file ~/palettesRootDir.txt (in your home folder) which contains one line, being a unixy path to the folder where you keep hex palette (.hexplt) files.

# USAGE
# Invoke this script with the following parameters:
# $1 hex color palette flat file list (input file).
# $2 edge length of each square tile to be composited into final image.
# $3 OPTIONAL. If not provided, the order of colors copied from source file will be left alone. If provided and zero, the order will be left alone. If nonzero, the order will be randomly shuffled.
# $4 OPTIONAL. Number of tiles accross of tiles-assembled image (columns). A string will be considered nonzero, so for scripting clarity you can pass this parameter as foo instead of 1, 4, or 50000 or whatever.
# $5 OPTIONAL. IF $4 IS PROVIDED, you probably want to provide this also, as the script may otherwise do math you don't want.
# EXAMPLE COMMAND; create a palette image from the hex color list RGB_combos_of_255_127_and_0_repetition_allowed.hexplt, where each tile is a square 250px wide, the palette image being 5 columns wide and 6 rows down, with squares in the palette rendered in random order:
# renderHexPalette-gm.sh RGB_combos_of_255_127_and_0_repetition_allowed.hexplt 250 foo 5 6

# KNOWN ISSUES
# Sometimes Cygwin awk throws errors as invoked by this script. Not sure why. I run it twice and one time awk throws an error, another it doesn't.

# TO DO
# Adapt this to use new script findHEXPLT.sh to retrieve .hexplt file path.
# UM. WOULDN'T THIS BE A TON FASTER creating a ppm and then upscaling it by nearest neighbor method?! Redo script (or make variant method script) for that?! -- trying that in hexplt2ppm.sh.
# Adapt this to do double-wide half-down ratios by multiples of two, e.g. 4:2, 8:4, 16:8 etc. (not just 2:1).
# Allow handling of a hex color on any line with or without # in front of it.
# Allow comments in .hexplt files (decide on a parse demarker for them and ignore all whitespace before that demarker, and also ignore the demarker itself and everything after it on the line).
# Math to determine tile size dynamically for a target total image resolution?


# CODE
# =============
# BEGIN SETUP GLOBAL VARIABLES
paletteFile=$1

# Search current path for $1; if it exists set hexColorSrcFullPath to just $1 (we don't need the full path). If it doesn't exist in the local path, search the path in palettesRootDir.txt and make decisions based on that result:
if [ -e ./$1 ]
then
	hexColorSrcFullPath=$1
else	# Search for specified palette file in palettesRootDir (if that dir exists; if it doesn't, exit with an error) :
	if [ -e ~/palettesRootDir.txt ]
	then
		palettesRootDir=$(< ~/palettesRootDir.txt)
				echo palettesRootDir.txt found\;
				echo searching in path $palettesRootDir --
				echo for file $paletteFile . . .
						# FAIL:
						# hexColorSrcFullPath=`gfind "$palettesRootDir" -iname *$paletteFile`
		hexColorSrcFullPath=`gfind $palettesRootDir -iname "$paletteFile"`
		echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
		if [ "$hexColorSrcFullPath" == "" ]
			then
				echo No file of name $paletteFile found in the path this script was invoked from OR in path \"$palettesRootDir\" \! ABORTING script.
				exit
			else
				echo File name $paletteFile found in the path this script was invoke from OR in path \"$palettesRootDir\" \! PROCEEDING. IN ALL CAPS.
		fi
	else
		echo !--------------------------------------------------------!
		echo file ~/palettesRootDir.txt \(in your root user path\) not found. This file should exist and have one line, being the path of your palette text files e.g.:
		echo
		echo /cygdrive/c/_ebdev/scripts/imgAndVideo/palettes
		echo
		echo ABORTING script.
		echo !--------------------------------------------------------!
		exit
	fi
fi


tileEdgeLen=$2

# Whether to shuffle colors; if parameter three was passed, shuffle colors if $3 is nonzero.
# If it is not provided or is provided but is zero, do not shuffle colors.
# Accomplished by setting default 0 and overriding only on condition $3 exists and is nonzero:
shuffleValues=0
if [[ "$3" ]]
then
	if [[ "$3" != 0 ]]
	then
		shuffleValues=1
		echo echo Value of paramater \$3 is NONZERO\; WILL SHUFFLE read values.
	fi
fi

# WHETHER NUM tiles across (and down) is specified; if so, use as specified, if not so, do some math to figure for a certain aspect;
# $4 is across. If $4 is not specified, do some math. Otherwise use $4:
if [ "$4" ]
then
	tilesAcross=$4
else
	# Get number of lines (colors). Square root of that X a number will be the number of columns in the rendered palette:
	# Works around potential incorrect line count; re: https://stackoverflow.com/a/28038682/1397555 :
	# echo attempting awk command\:
	# echo "awk 'END{print NR}' $hexColorSrcFullPath"
	# numColors=`awk 'END{print NR}' $hexColorSrcFullPath`
	numColors=`awk 'END{print NR}' $hexColorSrcFullPath`
			echo number of colors found in $paletteFile is $numColors.
	sqrtOfColorCount=`echo "sqrt ($numColors)" | bc`
			# echo sqrtOfColorCount is $sqrtOfColorCount \(first check\)
	# OPTIONS FOR ASPECT; uncomment only one:
	# FOR 2:1 aspect:
	# tilesAcross=$(( $sqrtOfColorCount * 2 ))
	# FOR ~1:1 aspect:
	tilesAcross=$(( $sqrtOfColorCount + 2 ))
			# echo tilesAcross is $tilesAcross\.
fi

# $5 is down. If $5 is specified, use it Otherwise do some math to figure tiles down.
if [ "$5" ]
then
	tilesDown=$5
else
	# Get number of lines (colors, yes again, if so). This / $tilesAcross will be number of rows in the rendered palette.
# TO DO: Update all scripts that count lines with the following form of fix:
	numColors=`awk 'END{print NR}' $hexColorSrcFullPath`
			# echo numColors is $numColors\.
	sqrtOfColorCount=`echo "sqrt ($numColors)" | bc`
			# echo sqrtOfColorCount is $sqrtOfColorCount
	tilesDown=$(( $tilesAcross / $numColors ))
	# If the value of ($tilesAcross times $tilesDown) is less than $numColors (the total number of colors), we will fail to print all colors in the palette; add rows to the print queue for as long as necessary:
	tilesToRender=$(( $tilesAcross * $tilesDown ))
	# echo tilesToRender is $tilesToRender\.
	while [ $tilesToRender -lt $numColors ]
	do
				# echo tilesDown was $tilesDown.
		tilesDown=$(( $tilesDown + 1 ))
		tilesToRender=$(( $tilesAcross * $tilesDown ))
				# TO DO: checking that twice . . . is that a code smell? Rework for more concise/elegant/sensical logic?
				# echo tilesDown is $tilesDown\.
	done
fi
# END SETUP GLOBAL VARIABLES
# =============


# IF RENDER TARGET already exists, abort script. Otherwise continue.
fileNameNoExt=${paletteFile%.*}
renderTarget=$fileNameNoExt.png
if [ -f ./$renderTarget ]
then
	echo Render target $renderTarget already exists\; SKIPPING render.
	# FOR DEVELOPMENT: Comment out the next line if you want to render anyway:
	exit
else
	echo Render target $renderTarget does not exist\; WILL RENDER.
fi

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

# this here complexity solves a problem of not reading a last line if it doesn't end with a new line; dunno how but magic says ok re http://stackoverflow.com/a/31398490 ;
# make directory of color tiles from palette:
while IFS= read -r line || [ -n "$line" ]
do
	# IF A SCRIPT THAT I DEVELOPED WORKED ONCE UPON A TIME BUT DOESN'T ANYMORE, it is because gsed on windows is inserting $#@! windows newlines into stdin/out! &@*(@!! FIXED with tr -d '\15\32':
	hexNoHash=`echo $line | gsed 's/\#//g' | tr -d '\15\32'`
	gm convert -size "$tileEdgeLen"x"$tileEdgeLen" xc:\#"$hexNoHash" _hexPaletteIMGgenTMP_2bbVyVxD/"$hexNoHash".png
done < $hexColorSrcFullPath

# make the actual montage image.
# e.g. gm montage colors/5A6D40.png colors/757F26.png colors/C68C15.png colors/8F322F.png colors/954B29.png out.png

# TO DO? : implement e.g. -tile 8x40 flag depending on desired aspect, etc. (will determine values of $tilesAcross and $tilesDown depending on desired aspect?)

# make temporary script to create a grid montage of the colors:
echo "gm montage -tile $tilesAcross"x"$tilesDown -background gray -geometry $tileEdgeLen"x"$tileEdgeLen+0+0 \\" > mkGridHead.txt

  # convert hex color scheme text list file to parameter list for ~magick:
gsed 's/.*#\(.*\)$/_hexPaletteIMGgenTMP_2bbVyVxD\/\1.png \\/' $hexColorSrcFullPath > ./mkGridSRCimgs.txt
dos2unix ./mkGridSRCimgs.txt
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

echo DONE--created color palette image is $renderTarget

# TO DO? : make the following statement optionally true (via parameter), and echo it: "You will also find color swatch images from the palette in the folder $paletteFile.colors."

# OPTIONAL on cygwin: open palette image:
# cygstart $1.png