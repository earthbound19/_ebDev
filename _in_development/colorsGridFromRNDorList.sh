# DESCRIPTION
# Creates a .ppm (plain text file bitmap format) image which is W x H pixels of random colors OR colors from a list. Generates Z such images. See USAGE for script parameters and examples.

# USAGE
# Pass this script the following parameters; the last being optional:
# $1 How many pixels wide wide you want a random image grid to be
# $2 How many pixels tall ~
# $3 How many such random images you want to create
# $4 A file list of hex color values to randomly pick from (instead of doing "completely" pseudo-random colors). May or may not result in all colors from source list showing up in final image--it depends on psuedo-random "chance."
# $5 any value (e.g. "foo") reads colors sequentially (don't pick at random) from input file.
# $6 any value (e.g. "florghulment") shuffles the input list randomly, then reads the shuffled list sequentially. This guarantees all colors from the list will be in the final image, but in random order. NOTE however that if you provide a source list and numbers too small in parameters $1 and $2, this will not list all colors from the list.
# AFTER RUNNING this script you may wish to run e.g.:
# imgs2imgsNN.sh ppm png 4280 4280
# -- see the comments in imgs2imgsNN for details.

# EXAMPLE COMMANDS
# Generate one hundred and seventy 16x9 pixel files of colors picked randomly from the color hex code list file rainbowHexColorsByMyEye.txt:
# thisScript.sh 16 9 170 rainbowHexColorsByMyEye.txt

# DEBUGGING:
# with params up to how many to make (3) isn't working correctly; hangs.
# with params up to only hex list isn't working; it's drawing colors randomly from list, but uses all 8 slots.

# TO DO: get this using the root hex colors list dir location that summat other script then there used.
# TO DO: as much of this script as possible in-memory instead of on disk, to speed it up dramatically.
# TO DO make the cols / rows paramater input sequence consistent between this and makeBWGridRandomNoise.sh, if they aren't (check).
# TO DO: set default values if no $1 $2 and $3 variables passed to script. Make this take string/switch parameters using em wah dut that testing that.
# TO DO: If param $5 passed (can have any value) to script, go through the list sequentially (no randomization).
# TO DO: if $4 then override numRows to  include everything in list.

numCols=$1
numRows=$2
howManyImages=$3

# if $6 was passed to script, "randomly" shuffle the elements of the source file into a temp file, and generate the array from that. If no $6, just copy the file (without shuffling it) into a temp file, create the array from the temp file, and destroy the temp file.
if [ -z ${6+x} ]
then
	shuf $4 > tmp_feoijwefjojeoo.txt
else
	cp $4 tmp_feoijwefjojeoo.txt
fi

# TO DO: wut? CONTINUE DEVELOPING HERE? :
# sed -i 

# is that ! properly used? it wasn't for $6 above, which I fixed:
if [ ! -z ${4+x} ]
then
	mapfile -t hexColorsArray < tmp_feoijwefjojeoo.txt
	rm tmp_feoijwefjojeoo.txt
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
			# empty temp.txt before writing new color columns to it:
			printf "" > temp.txt
			for columnsThingCountDerp in $( seq $numCols )
			do
						# If no param $5 passed to script, pick a random color from the file-imported color list. If param $5 passed to script, pick the index for the next color in that list.
						cellCount=$(( cellCount + 1 ))
						if [ ! -z ${5+x} ]
						then
							pick=$cellCount
						else
							pick=`shuf -i 0-"$sizeOf_hexColorsArray" -n 1`
						fi
				hex=${hexColorsArray[$pick]}

				# If $hex is an invalid hex color (NULL, because I assigned from out of range of the array, or in other words we used all the colors in the list), default to gray #404040, re stdout error when this was a bug: "line 69: printf: 0x: invalid hex number" :
				if [ ${#hex} == 0 ]
				then
							echo all colors in the list have been used\; therefore setting \$hex for this pixel to default gray \#404040
					hex=404040
				fi
				# re http://stackoverflow.com/a/7254022/1397555;
						# ALSO NOTE the next commented line, which would be for a list without # before hex numbers:
						# printf "%d\n %d\n %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2} >> temp.txt
				printf "%d\n %d\n %d\n" 0x${hex:1:2} 0x${hex:3:2} 0x${hex:5:2} >> temp.txt
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
	cat ppmheader.txt grid.ppm > "$numCols"x"$numRows"gridRND_"$timestamp".ppm
	rm ppmheader.txt grid.ppm

done
