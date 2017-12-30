# DESCRIPTION
# Makes a teensy ppm palette image (one pixel per color) from a hex palette .hexplt source file. Result is useable as a basis for a scaled up palette image via e.g.:
# imgs2imgsNN.sh ppm png 640

# USAGE
# Invoke this script with the following parameters:
#  $1 hex color palette flat file list (input file).
#  $2 OPTIONAL. Edge length of each square tile to be composited into final (png) image.
#  $3 OPTIONAL. MUST HAVE VALUE 0 or nonzero (anything other than 0). If nonzero, the script will randomly shuffle the hex color files before compositing them to one image.
#  $4 OPTIONAL. number of tiles accross of tiles-assembled image (columns).
#  $5 OPTIONAL. IF $4 IS PROVIDED, you probably want to provide this also, as the script does math you may not want if you don't provide $5. Number of tiles down of tiles-assembled image (rows).
#  EXAMPLE COMMAND; create a palette image from the hex color list RGB_combos_of_255_127_and_0_repetition_allowed.hexplt, where each tile is a square 250px wide, squares in the palette rendered in random order, and the palette image being 5 columns wide and 6 rows down:
#  ./thisScript.sh RGB_combos_of_255_127_and_0_repetition_allowed.hexplt 250 foo 5 6

# KNOWN ISSUES
# - Sometimes Cygwin awk throws errors as invoked by this script. Not sure why. I run it twice and one time awk throws an error, another it doesn't.
# - ppm files resulting from this may not convert cleanly to png via irfanview CLI, not until I pad any empty space not lined up with columns at the end of the last ppm line (pad it with gray).

# TO DO
# - TO DO reuse vistigal parameter $3 to make image size from edge length * width and * height


# CODE

# =============
# BEGIN SETUP GLOBAL VARIABLES
paletteFile=$1
renderTargetFile=$paletteFile.ppm

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

# Whether to shuffle colors:
if [[ $3 == 0 ]]
then
	echo Value of paramater \$3 is zero\; WILL NOT shuffle read values.
	# Don't do any shuffling of tmp_djEAM2XJ9w.hexplt.
else
	echo Value of paramater \$3 is NONZERO\; WILL SHUFFLE read values.
	# Shuffle the values (lines) in tmp_djEAM2XJ9w.hexplt into a new temp file:
	shuf ./tmp_djEAM2XJ9w.hexplt > ./tmp_NpKH7mFEHg58UsNQ5JX3.txt
	# Assign the name of this new shuffled temp file to hexColorSrcFullPath, and remove the previous temp file:
	hexColorSrcFullPath=tmp_NpKH7mFEHg58UsNQ5JX3.txt
	rm ./tmp_djEAM2XJ9w.hexplt
fi
# WHETHER NUM tiles across (and down) is specified; if so, use as specified, if not so, do some math to figure for a 2:1 aspect;
# $4 is across. If $4 is not specified, do some math. Otherwise use $4:
if [ -z ${4+x} ]
then
	# Get number of lines (colors). Square root of that x2 will be the number of columns in the rendered palette:
	# Works around potential incorrect line count; re: https://stackoverflow.com/a/28038682/1397555 :
		# echo attempting awk command\:
echo "awk 'END{print NR}' $hexColorSrcFullPath"
	# numColors=`awk 'END{print NR}' $hexColorSrcFullPath`
	numColors=`awk 'END{print NR}' $hexColorSrcFullPath`
			# echo number of colors found in $paletteFile is $numColors.
	sqrtOfColorCount=`echo "sqrt ($numColors)" | bc`
			# echo sqrtOfColorCount is $sqrtOfColorCount \(first check\)
	tilesAcross=$(( $sqrtOfColorCount * 2 ))
			# echo tilesAcross is $tilesAcross\.
else
	tilesAcross=$4
fi
# $5 is down. If $5 is not specified, do some math. Otherwise use $5.
if [ -z ${5+x} ]
then
	# Get number of lines (colors, yes again, if so). Square root of that / 2 will be the number of rows in the rendered palette.
# TO DO: Update all scripts that count lines with the following form of fix:
	numColors=`awk 'END{print NR}' $hexColorSrcFullPath`
			# echo numColors is $numColors\.
	sqrtOfColorCount=`echo "sqrt ($numColors)" | bc`
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
	done
			# echo tilesDown is $tilesDown\.
else
	tilesDown=$5
fi
# END SETUP GLOBAL VARIABLES
# =============


# IF RENDER TARGET already exists, abort script. Otherwise continue.
if [ -f ./$renderTargetFile ]
then
	echo Render target $renderTargetFile already exists\; SKIPPING render.
	exit
else
	echo Render target $renderTargetFile does not exist\; WILL RENDER.
	echo Palette will be rendered with $tilesAcross tiles across and $tilesDown tiles down.
	# Make P3 PPM format header:
	echo "P3" > PPMheader.txt
	echo "# P3 means text file, $tilesAcross $tilesDown is cols x rows, 255 is max color, triplets of RGB vals per row." >> PPMheader.txt
	echo $tilesAcross $tilesDown >> PPMheader.txt
	echo "255" >> PPMheader.txt

	# each hex color is a triplet of hex pairs (corresponding to 0-255 RGB values) ; concatenate temp hexplt file to uninterrupted hex pairs (no newlines) to parse as one long string into the ppm body:
	ppmBodyValues=`tr -d '\n' < $hexColorSrcFullPath`
			rm $hexColorSrcFullPath
	# Split that superstring with spaces every two hex chars:
	ppmBodyValues=`echo $ppmBodyValues | sed 's/../& /g'`
	# TO DO for hexplt2ppm.sh: convert that to decimal; first work it up into a string formatted for echo in base-16, e.g.:
	# ppmBodyValues=`echo $((16#"$thisHexString")) $((16#"$thatHexString"))`
	ppmBodyValues=`echo $ppmBodyValues | sed 's/[a-zA-Z0-9]\{2\}/$((16#"&"))/g'`
	# If I echo that\, it prints it literally instead of interpretively. Ach! Workaround: make a temp shell script that echos it interpretively (and assign the result to a variable) :
	printf "echo $ppmBodyValues" > tmp_hsmwzuF64fEWmcZ2.sh
	ppmBodyValues=`./tmp_hsmwzuF64fEWmcZ2.sh`
	rm tmp_hsmwzuF64fEWmcZ2.sh
	echo $ppmBodyValues > ppmBody.txt
			# DEV NOTES
			# including "simulate ? (optionals) with \{0,1\}", re: https://stackoverflow.com/a/6157705/1397555
			# ex. command: echo "a aa a aa aaa a " | gsed "s/ \{0,1\}\(a\)/\1\n/g"
			# (The space needs to be optional because the start of a line isn't going to have a space in our case.)
			# further worked up to break all three-groups of the letter a separated by spaces:
			# echo "aaaaaaa aaaaa a aa aaaa a a a a aaa aa aaaaaaaaaaaaaaaaa" | gsed "s/\( \{0,1\}a\{1,\}\)\{3\}/&\n/g"
			# further worked up to capture digits, not "a"s:
			# echo "8 11 254 4 100 2 36 1 100" | gsed "s/\( \{0,1\}[0-9]\{1,\}\)\{3\}/&\n/g"
	# Because each pixel is three values, each tile (tilesAcross) will be * 3 numeric values:
	splitAtCount=$(( $tilesAcross * 3 ))
	echo $ppmBodyValues | gsed "s/\( \{0,1\}[0-9]\{1,\}\)\{$splitAtCount\}/&\n/g" > ppmBody.txt
	# Strip resultant leading spaces off that, in place (in file):
	gsed -i 's/^ \(.*\)/\1/g' ppmBody.txt
# CONTINUE CODING HERE; NOTE copied from above:
	echo Padding any empty columns on last row of .ppm file with middle gray pixels . . .
	# Fill in any empty columns on the last line with gray:
	# - Count number of value triplets on last line, and subtract that tilesAcross; if the result is nonzero, add that many to the row.
	#  - Isolate last line of ppmBody.txt to count those values; re http://www.theunixschool.com/2012/05/7-different-ways-to-print-last-line-of.html :
	#  - pipe the last line of ppmBody to grep and search for number pattern, then pipe to word count (wc), and store all that in the variable lastLineValuesCount:
	# Because AGAIN windows line endings created by one ported gnu utility are conflicting with unix line endings created by another ported gnu utility:
	dos2unix ppmBody.txt
	lastLineString=`tail -1 ppmBody.txt`
	lastLineValuesCount=`echo $lastLineString | grep -o '[0-9]\{1,\}' | wc -l`
	#  - Divide that result by 3 because each pixel is three numeric values (RGB) :
	lastLineTilesCount=$(( $lastLineValuesCount / 3))
			# echo lastLineTilesCount is\: $lastLineTilesCount
	#  - Which gives is our value to subtract from tilesAcross as described above:
	tilesToAdd=$(( $tilesAcross - $lastLineTilesCount ))
			# echo tilesToAdd is\: $tilesToAdd
	valuesToAdd=$(( $tilesToAdd * "3"))
			# echo valuesToAdd is\: $valuesToAdd
	#  - Alas this can't be done as elegantly as printf "ha "%.0s {1..5} with a variable in the range, re https://stackoverflow.com/questions/19432753/brace-expansion-with-variable :
	for i in $(seq 1 $valuesToAdd)
	do
		lastLineValuesPadString="$lastLineValuesPadString 127"
	done
	lastLineValuesPadString="$lastLineString $lastLineValuesPadString"
	# remove last line from ppmBody.txt, then append the replacement line to it:
	sed -i '$ d' ppmBody.txt
	echo $lastLineValuesPadString >> ppmBody.txt
	# concatenate the header and body to create the final ppm file:
	cat PPMheader.txt ppmBody.txt > $renderTargetFile
	# remove temp files:
	rm PPMheader.txt ppmBody.txt
fi

# If $2 (tile size) parameter passed, blow up the image via mathy math and another script:
if [ ${2+x} ]
then
	tileEdgeLen=$2
	blowupIMGtoXpix=$(( $tileEdgeLen * $tilesAcross ))
irfanView2imgNN.sh $renderTargetFile png $blowupIMGtoXpix
fi