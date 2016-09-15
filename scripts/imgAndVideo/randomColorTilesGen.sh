# DESCRIPTION
# Creates a .ppm (plain text file bitmap format) image which is W x H pixels of random colors, then converts it to a blown-up image of a set scale Y with hard edges preserved--a grid of random color tiles. Generates Z such images. See USAGE for script parameters and example.

# USAGE
# Pass this script the following parameters; the last being optional:
# $1 How many pixels wide wide you want a random image grid to be
# $2 How many pixels tall ~
# $3 How many such random images you want to create
# $4 A file list of hex color values to randomly pick from (instead of doing "completely" pseudo-random colors).
		# DEPRECATED:
		# $5 The multiplier scale you want to scale up the resulting image by (maintaining hard edges). This script first creates a .ppm plain text format image file, then converts it to a .png file, maintaining hard edges and scaling up by the multiplier of the third parameter.
# Example command that will generate one hundred and seventy 16x9 pixel files of colors picked randomly from the color hex code list file rainbowHexColorsByMyEye.txt:
# thisScript.sh 16 9 170 rainbowHexColorsByMyEye.txt

# --which will produce 10x10 pixel random colored .ppm images, fifteen of them, and scale each up x80, maintaining hard edges, to accompanying .png images.

# TO DO make the cols / rows paramater input sequence consistent between this and makeBWGridRandomNoise.sh, if they aren't (check).
# TO DO: set default values if no $1 $2 and $3 variables passed to script. Make this take string/switch parameters using em wah dut that testing that.
# TO DO? : use ffmpeg for upscaling instead?
# TO DO? : Allow upscale to target resolution?
# TO DO: convert from hex color lists thusly; operating on hex values after list import:
	# hex="ff1200"
	# printf "%d %d %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
	# re: http://stackoverflow.com/a/7254022/1397555
	# -first checking for non-empty $4 and importing from list given by $4 thus:
	# if [ ! -z ${4+x} ]

numCols=$1
numRows=$2
howManyImages=$3
		# DEPRECATED:
		# multiplierScale=$4

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
	count=0
	for i in $( seq $numRows )
	do
					echo Generating row for image number $a . . .
		count=$(( count + 1 ))
				# Pick a random color from a hex color list if such a list is specified (converting to RGB along the way); otherwise pick completely random RGB values.
				if [ ! -z ${4+x} ]
					then
						# empty temp.txt before writing new color columns to it:
						printf "" > temp.txt
						for columnsThingCountDerp in $( seq $numCols )
						do
							pick=`shuf -i 0-"$sizeOf_hexColorsArray" -n 1`
							hex="${hexColorsArray[$pick]}"
							printf "%d\n %d\n %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2} >> temp.txt
						done
					else
						shuf -i 1-255 -n $numbersNeedsPerRow > temp.txt
				fi
		tr '\n' ' ' < temp.txt > $count.temp
		echo >> $count.temp
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

			# DEPRECATED, on account of wanting to make mp4 animations where ffmpeg can upscale on the fly (and skip need of any upscaled .png image) see improved approach at end of makeBWGridRandomNoise.sh:
			# Convert new image to upscaled (preserving hard edges) by 50 time as large png:
			# newXpix=$((numbersNeedsPerRow * $multiplierScale))
			# newYpix=$((numRows * $multiplierScale))
							# echo Creating enlarged png version with hard edges maintained . . .
			# nconvert -ratio -rtype quick -resize $newXpix $newYpix -out png -o "$numRows"x"$numCols"gridRND_"$timestamp".png "$numRows"x"$numCols"gridRND_"$timestamp".ppm
done