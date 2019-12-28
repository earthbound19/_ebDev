# DESCRIPTION
# Creates a .ppm (plain text file bitmap format) image which is W x H pixels of random vertical color stripes, then converts it to a blown-up image of a set scale Y with hard edges preserved--a grid of random color tiles. Generates Z such images. See USAGE for script parameters and example.

# USAGE
# Pass this script the following parameters; the last being optional:
# $1 The minimum number of columns to repeat a color (note that this is *before*) the image upscale).
# $2 The maximum number of columns to repeat a color (note that this is *before*) the image upscale).
# $3 How many pixels wide to scale the final image
# $4 How many pixels tall to scale the final image
# $5 How many such random images you want to create
# $6 A file list of hex color values to randomly pick from (instead of doing "completely" pseudo-random colors).

# NOTES
# TO DO
# This script was adapted from randomColorTilesGen.sh -- adapt any necessary comments therefrom.

# VARS ARE
minColorColumnRepeat=$1
maxColorColumnRepeat=$2
scalePixX=$3
scalePixY=$4
	# Former, related: numCols=$1
	# Former, related: numRows=$2
howManyImages=$5
colorSelectionList=$6
echo colorSelectionList val\:

# ! VARS WERE: !
# $1 How many pixels wide wide you want a random image grid to be
# $2 How many pixels tall ~
# $3 How many such random images you want to create
# $4 A file list of hex color values to randomly pick from (instead of 

if [ "$4" ]
	then
	mapfile -t hexColorsArray < $colorSelectionList
	sizeOf_hexColorsArray=${#hexColorsArray[@]}
	sizeOf_hexColorsArray=$(( $sizeOf_hexColorsArray - 1))		# Else we get an out of range error for the zero-based index of arrays.
fi

# Outer loop per howManyImages:
for a in $( seq $howManyImages )
do
	# Inner loop which produces each image:
	# stripesPerRow=$(( $numCols * 3 ))
	# numbersNeedsPerRow=$(( $numCols * 3 ))
	howManyStripes=`shuf -i $minColorColumnRepeat-$maxColorColumnRepeat -n 1`
	count=0
	for i in $( seq $howManyStripes )
	do
					echo Generating stripes for image number $a . . .
		count=$(( count + 1 ))
				# Pick a random color from a hex color list if such a list is specified (converting to RGB along the way); otherwise pick completely random RGB values.
				if [ ! -z ${colorSelectionList+x} ]
					then
						# empty temp.txt before writing new color columns to it:
						printf "" > temp.txt
							pick=`shuf -i 0-"$sizeOf_hexColorsArray" -n 1`
							hex="${hexColorsArray[$pick]}"
									# Pick a number of times to repeat that chosen hex color, then write it that number of times to the temp file that will make up the eventual .ppm file: 
									repeatThisColumnColor=`shuf -i $minColorColumnRepeat-$maxColorColumnRepeat -n 1`
									for k in $( seq $repeatThisColumnColor )
									do
							printf "%d\n %d\n %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2} >> temp.txt
									done
					else
# TO DO: make this spit out hex or is it already? -- no, generate a triplet of numbers from 1-255; perhaps gen. the hex first and then format like that other if control block else thing here above? neh just numbers.
						shuf -i 1-255 -n $repeatThisColumnColor > temp.txt
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

			# OPTIONAL:
			# newXpix=$((stripesPerRow * $multiplierScale))
			# newYpix=$((numRows * $multiplierScale))
							# echo Creating enlarged png version with hard edges maintained . . .
			# nconvert -ratio -rtype quick -resize $newXpix $newYpix -out png -o "$numRows"x"$numCols"gridRND_"$timestamp".png "$numRows"x"$numCols"gridRND_"$timestamp".ppm
done