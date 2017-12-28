# IN DEVELOPMENT. Will get the same result as hexplt2ppm.sh far more efficiently (I hope) by creating a ppm (text file, not slowly rendered and slowly composited images), which can be quickly blown up by nearest neighbor method to a .png.


# USAGE
# Invoke this script with the following parameters:
# $1 hex color palette flat file list (input file).
# $2 edge length of each square tile to be composited into final image.
# $3 MUST HAVE VALUE 0 or nonzero (anything other than 0). If nonzero, the script will randomly shuffle the hex color files before compositing them to one image. PREVIOUSLY WAS $5, PREVIOUSLY WAS OPTIONAL; NOW REQUIRED. OVERWRITES different previous parameter position (from a prior version of this script).
# $4 OPTIONAL. number of tiles accross of tiles-assembled image (columns). PREVIOUSLY WAS $3.
# $5 OPTIONAL. IF $4 IS PROVIDED, you probably want to provide this also, as the script does math you may not want if you don't provide $5. Number of tiles down of tiles-assembled image (rows). PREVIOUSLY WAS $4.
# EXAMPLE COMMAND; create a palette image from the hex color list RGB_combos_of_255_127_and_0_repetition_allowed.hexplt, where each tile is a square 250px wide, the palette image being 5 columns wide and 6 rows down, with squares in the palette rendered in random order:
# renderHexPalette-gm.sh RGB_combos_of_255_127_and_0_repetition_allowed.hexplt 250 foo 5 6

# KNOWN ISSUES
# Sometimes Cygwin awk throws errors as invoked by this script. Not sure why. I run it twice and one time awk throws an error, another it doesn't.

# TO DO
# Rename confused (is it?) variable name tilesToRender? Should it be columns something something?


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
		hexColorSrcFullPath=`find $palettesRootDir -iname "$paletteFile"`
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

# Do whitespace / extraneous lines cleanup of .hexplt source file (saving result to temp file which we will operate from) :
			# commands iterated through in development:
			# replaces whitespace with ____:
			# sed -e "s/\s/____/g" ColorSchemeHexBurntSandstone.hexplt
			# isolates six-character hex:
			# sed -e "s/#\([0-9a-fA-F]\{6\}\)/\1/g" ColorSchemeHexBurntSandstone.hexplt
			# combines stripping leading whitespace and isolating sextuple hex strings:
			# sed -e "s/^\s\{1,\}//g" -e "s/#\([0-9a-fA-F]\{6\}\).*/\1/g" ColorSchemeHexBurntSandstone.hexplt
# I don't know *how* this combination of flags works; it was a shot in the dark (!), but it works; hints from https://stackoverflow.com/a/1665574/1397555 ; ALSO, the \L converts all preceding characters which are uppercase to lowercase :
sed -n -e "s/^\s\{1,\}//g" -n -e "s/#\([0-9a-fA-F]\{6\}\).*/\L\1/p" $hexColorSrcFullPath > tmp_djEAM2XJ9w.hexplt
# Reassign name of that temp file to hexColorSrcFullPath to work from:
hexColorSrcFullPath=tmp_djEAM2XJ9w.hexplt


tileEdgeLen=$2
# Whether to shuffle colors:
if [[ $3 == 0 ]]
then
	shuffleValues=0
	echo Value of paramater \$3 is zero\; will not shuffle read values.
else
	shuffleValues=1
	echo echo Value of paramater \$3 is NONZERO\; WILL SHUFFLE read values.
fi
# WHETHER NUM tiles across (and down) is specified; if so, use as specified, if not so, do some math to figure for a 2:1 aspect;
# $4 is across. If $4 is not specified, do some math. Otherwise use $4:
if [ -z ${4+x} ]
then
	# Get number of lines (colors). Square root of that x2 will be the number of columns in the rendered palette:
	# Works around potential incorrect line count; re: https://stackoverflow.com/a/28038682/1397555 :
echo attempting awk command\:
echo "awk 'END{print NR}' $hexColorSrcFullPath"
	# numColors=`awk 'END{print NR}' $hexColorSrcFullPath`
	numColors=`awk 'END{print NR}' $hexColorSrcFullPath`
			echo number of colors found in $paletteFile is $numColors.
	sqrtOfColorCount=`echo "sqrt ($numColors)" | bc`
			echo sqrtOfColorCount is $sqrtOfColorCount \(first check\)
	tilesAcross=$(( $sqrtOfColorCount * 2 ))
			echo tilesAcross is $tilesAcross\.
else
	tilesAcross=$4
fi
# $5 is down. If $5 is not specified, do some math. Otherwise use $5.
if [ -z ${5+x} ]
then
	# Get number of lines (colors, yes again, if so). Square root of that / 2 will be the number of rows in the rendered palette.
# TO DO: Update all scripts that count lines with the following form of fix:
	numColors=`awk 'END{print NR}' $hexColorSrcFullPath`
			echo numColors is $numColors\.
	sqrtOfColorCount=`echo "sqrt ($numColors)" | bc`
			echo sqrtOfColorCount is $sqrtOfColorCount
	tilesDown=$(( $sqrtOfColorCount / 2 ))
	# If the value of ($tilesAcross times $tilesDown) is less than $numColors (the total number of colors), we will fail to print all colors in the palette; add rows to the print queue for as long as necessary:
	tilesToRender=$(( $tilesAcross * $tilesDown ))
	echo tilesToRender is $tilesToRender\.
	while [ $tilesToRender -lt $numColors ]
	do
		echo tilesDown was $tilesDown.
		tilesDown=$(( $tilesDown + 1 ))
		tilesToRender=$(( $tilesAcross * $tilesDown ))
	done
			echo tilesDown is $tilesDown\.
else
	tilesDown=$5
fi
# END SETUP GLOBAL VARIABLES
# =============


# IF RENDER TARGET already exists, abort script. Otherwise continue.
if [ -f ./$paletteFile.png ]
then
	echo Render target $paletteFile.png already exists\; SKIPPING render.
	# FOR DEVELOPMENT: Comment out the next line if you want to render anyway:
	# exit
else
	echo Render target $paletteFile.png does not exist\; WILL RENDER.
	# CODE HERE things magic with tmp_djEAM2XJ9w.hexplt:

	# Make P3 PPM format header:
	echo "P3" > PPMheader.txt
	echo "# P3 means text file, $tilesAcross $tilesDown is cols x rows, ff is max color (hex 255), triplets of hex vals per RGB val." >> PPMheader.txt
	echo $tilesAcross $tilesDown >> PPMheader.txt
	echo "255" >> PPMheader.txt
	
	# each hex color is a triplet of hex pairs (corresponding to 0-255 RGB values) ; concatenate temp hexplt file to uninterrupted hex pairs (no newlines) to parse as one long string into the ppm body:
	ppmBodyHexValues=`tr -d '\n' < tmp_djEAM2XJ9w.hexplt`
			# echo ppmBodyHexValues val\: $ppmBodyHexValues
	# echo $ppmBodyHexValues > tmp_9RBKDG8aUe.txt
			# less efficient route I almost went down; grab the chars I need from that superstring iteratively:
			# hexCharToPrint=${ppmBodyHexValues:6:6}
					# echo hexCharToPrint val is\: $hexCharToPrint
	# Split that superstring with spaces every two hex chars:
	ppmBodyHexValues=`echo $ppmBodyHexValues | sed 's/../& /g'`
	# Convert that to decimal:
	ppmBodyDecimalValues=`echo $((16#"$ppmBodyHexValues"))`
	echo UWTTT is\:
	echo $ppmBodyDecimalValues
	# where e.g. \{6\} would be two hex pairs; the value in \{n\} will be columns times 3:
	hexPairsPerRow=$(( $tilesAcross * 9 ))		# but why is that 9? I'm just seeing that's what it should be.
	echo $ppmBodyDecimalValues | sed "s/.\{$ppmBodyDecimalValues\}/&\n/g" > ppmBody.txt
fi

cat PPMheader.txt ppmBody.txt > oot.ppm

# Cleanup of temp files:
# rm tmp_djEAM2XJ9w.hexplt PPMheader.txt