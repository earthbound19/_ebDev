# DESCRIPTION
# Creates a .ppm (plain text file bitmap format) image which is W x H pixels of random colors, then converts it to a blown-up image of a set scale Y with hard edges preserved--a grid of random color tiles. Generates Z such images. See USAGE for script parameters and example.

# USAGE
# Pass this script the following parameters; the last being optional:
# $1 How many pixels wide wide you want a random image grid to be
# $2 How many pixels tall ~
# $3 How many such random images you want to create
# $4 A file list of hex color values to randomly pick from (instead of doing "completely" pseudo-random colors).
# $5 in development -- reads colors sequentially (don't pick at random) from input file.
# $6 in development -- shuffltes the input list randomly, then reads the shuffled list sequentially.

# Example command that will generate one hundred and seventy 16x9 pixel files of colors picked randomly from the color hex code list file rainbowHexColorsByMyEye.txt:
# thisScript.sh 16 9 170 rainbowHexColorsByMyEye.txt

# TO DO: get this using the root hex colors list dir location that summat other script then there used.
# TO DO: as much of this script as possible in-memory instead of on disk, to speed it up dramatically.
# TO DO make the cols / rows paramater input sequence consistent between this and makeBWGridRandomNoise.sh, if they aren't (check).
# TO DO: set default values if no $1 $2 and $3 variables passed to script. Make this take string/switch parameters using em wah dut that testing that.
# TO DO: convert from hex color lists thusly; operating on hex values after list import:
	# hex="ff1200"
	# printf "%d %d %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
	# re: http://stackoverflow.com/a/7254022/1397555
	# -first checking for non-empty $4 and importing from list given by $4 thus:
	# if [ ! -z ${4+x} ]
	# If param $5 passed (can have any value) to script, go through the list sequentially (no randomization).
	# ALSO if $4 then override numRows to include include everything in list.

numCols=$1
numRows=$2
howManyImages=$3

if [ ! -z ${4+x} ]
	then
	mapfile -t hexColorsArray < $4
	sizeOf_hexColorsArray=${#hexColorsArray[@]}
	sizeOf_hexColorsArray=$(( $sizeOf_hexColorsArray - 1))		# Else we get an out of range error for the zero-based index of arrays.
fi

# Outer loop per howManyImages:
for a in $( seq $howManyImages )
do
	# Inner loop which produces each image:
	numbersNeedsPerRow=$(( $numCols * 3 ))
	rowCount=0
	cellCount=0		# count of all colors generated in image (and, if an input color list provided, in that list).
	for i in $( seq $numRows )
	do
					echo Generating row for image number $a . . .
		rowCount=$(( rowCount + 1 ))
				# Pick a random color from a hex color list if such a list is specified (converting to RGB along the way); otherwise pick completely random RGB values.
				if [ ! -z ${4+x} ]
					then
						cellCount=$(( cellCount + 1 ))
						# empty temp.txt before writing new color columns to it:
						printf "" > temp.txt
						for columnsThingCountDerp in $( seq $numCols )
						do
# IN DEVELOPMENT--------------------THIS INDENTED BLOCK--TEST THIS; RIGHT NOW it's generating horizantal stripes--and interesting effect I had wanted a script for. ? hm. but should it?
									# If no param $5 passed to script, pick a random color from the file-imported color list. If param $5 passed to script, pick the next color in that list.
									if [ ! -z ${5+x} ]
									then
										echo cellCount val is $cellCount
										echo Fiver-five-five-five-nine-ninety-five, then. Reading next in sequence. Over.
										pick=$cellCount
									else
										pick=`shuf -i 0-"$sizeOf_hexColorsArray" -n 1`
									fi
							hex="${hexColorsArray[$pick]}"
							printf "%d\n %d\n %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2} >> temp.txt
						done
					else
						shuf -i 1-255 -n $numbersNeedsPerRow > temp.txt
				fi
		tr '\n' ' ' < temp.txt > $rowCount.temp
		echo >> $rowCount.temp
	done

	rm temp.txt
	cat *.temp > grid.ppm
	rm *.temp

	printf "P3
	#the P3 means colors are in ascii, then $1 columns and $2 rows, then 255 for max color, then RGB triplets
	$numCols $numRows
	255
	" > ppmheader.txt

					echo Concatenating generated rows into one new .ppm file . . .
	timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
	cat ppmheader.txt grid.ppm > "$numRows"x"$numCols"gridRND_"$timestamp".ppm
	rm ppmheader.txt grid.ppm

done