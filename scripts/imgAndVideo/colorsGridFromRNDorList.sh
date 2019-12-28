# DESCRIPTION
# Creates a .ppm (plain text file bitmap format) image which is W x H pixels of random colors OR colors from a list. Generates Z such images. See USAGE for script parameters and examples.

# USAGE
# BECAUSE I KEEP FORGETTING, $4, $5 and $6 are actually different things.
# Pass this script the following parameters; the last being optional:
# $1 How many pixels wide wide you want a random image grid to be
# $2 How many pixels tall ~
# $3 How many such random images you want to create
# $4 Hex color list file name to pick colors from randomly (if omitted, colors are generated randomly). May or may not result in all colors from source list showing up in final image--it depends on psuedo-random "chance."
# $5 any value (e.g. "foo") pick colors from list (in $4) sequentially.
# $6 any value (e.g. "florghulment") pick colors from list (in $4) sequentially *after sorting it randomly*.
# NOTE that if you provide a source list of colors ($4), but numbers too small in parameters $1 and $2, it will not use all colors from the list (as it will generate tiles against only part of the list).
# AFTER RUNNING this script you may wish to run e.g.:
# imgs2imgsNN.sh ppm png 4280 4280
# -- see the comments in imgs2imgsNN for details.

# EXAMPLE COMMANDS
# Generate 3 files of randomly generated colors in a 4x2 grid:
# thisScript.sh 4 2 1
# Generate one hundred and seventy 16x9 pixel files of colors picked randomly from the color hex code list file rainbowHexColorsByMyEye.txt:
# thisScript.sh 16 9 170 rainbowHexColorsByMyEye.txt
# The same as the previous command, but reading colors from the list sequentially:
# thisScript.sh 16 9 170 rainbowHexColorsByMyEye.txt foo

# TO DO: get this using the root hex colors list dir location that summat other script then there used.
# TO DO: as much of this script as possible in-memory instead of on disk, to speed it up dramatically.
# TO DO make the cols / rows paramater input sequence consistent between this and makeBWGridRandomNoise.sh, if they aren't (check).
# TO DO: set default values if no $1 $2 and $3 variables passed to script. Make this take string/switch parameters using em wah dut that testing that.

numCols=$1
numRows=$2
howManyImages=$3

# if $6 was passed to script (if $6 not null), "randomly" shuffle the elements of the source file into a temp file, and generate the array from that. If no $6, just copy the file (without shuffling it) into a temp file, create the array from the temp file, and destroy the temp file.
if [ "$6" ]
then
	gshuf $4 > tmp_feoijwefjojeoo.txt
else
	cp $4 tmp_feoijwefjojeoo.txt
fi

# If a color list file is specified, count the number of items in it and store them in an array.
if [ "$4" ]
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
	colorListIterate=0			# used in an inner loop a ways below
	for i in $( seq $numRows )
	do
					echo Generating row for image number $a . . .
		rowCount=$(( rowCount + 1 ))
		# If a hex color list is specified, pick a color from it (using conditions below); otherwise, generate a random color.
		if [ "$4" ]
		then
			# empty temp.txt before writing new color columns to it:
			printf "" > temp.txt
			for columnsThingCountDerp in $( seq $numCols )
			do
						# If param $5 passed to script, pick the index for the next (sequential) color in that list. If no param $5 passed to script, pick a random color from the file-imported color list. 
						if [ "$5" ]
						then
							pick=$colorListIterate
							colorListIterate=$(( colorListIterate + 1 ))
											# OPTIONAL; comment this level indent out if you don't want this behavior:
											# IF WE'VE reached the last color in the list, reset the counter to the first color in the list. If your result image would have more color tiles than there are colors in the source list, this will reuse the colors in the list to fill the image, which could result in interesting repeating patterns or patterns broken over lines.
											# The + 1 in the following if check is to avoid a zero-based index goof.
											# if [ $colorListIterate == $(( $sizeOf_hexColorsArray + 1)) ]
											# then
												# colorListIterate=0
											# fi
						else
							pick=`gshuf -i 0-"$sizeOf_hexColorsArray" -n 1`
						fi
				hex=${hexColorsArray[$pick]}
				# If $hex is an invalid hex color (0, because I assigned from out of range of the array, or in other words we used all the colors in the list), default to gray #404040, re stdout error when this was a bug: "line 69: printf: 0x: invalid hex number" :
				if [ ${#hex} == 0 ]
				then
							echo all colors in the list have been used\; therefore setting $hex for this pixel to default gray \#404040
					hex=404040
				fi
				# re http://stackoverflow.com/a/7254022/1397555;
						# ALSO NOTE the next commented line, which would be for a list without # before hex numbers:
						# printf "%d\n %d\n %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2} >> temp.txt
				# This printf statement converts hex to decimal:
				printf "%d\n %d\n %d\n" 0x${hex:1:2} 0x${hex:3:2} 0x${hex:5:2} >> temp.txt
			done
		else
			gshuf -i 1-255 -n $numbersNeedsPerRow > temp.txt
		fi
		tr '\n' ' ' < temp.txt > $rowCount.temp
		# adds a newline after that last line:
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
