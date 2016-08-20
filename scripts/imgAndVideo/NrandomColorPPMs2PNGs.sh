# USAGE: pass this script three parameters, the first being the number of pixels wide (and tall) you want a random image grid to be, the second being how many such random images you want to create, and the third being the multiplier scale you want to scale up the resulting image by (maintaining hard edges). It first creates a .ppm plain text format image file, then converts it to a .png file, maintaining hard edges and scaling up by the multiplier of the third parameter. Example command:

# thisScript.sh 10 15 80

# --which will produce 10x10 pixel random colored .ppm images, fifteen of them, and scale each up x80, maintaining hard edges, to accompanying .png images.

# TO DO: set default values if no $1 $2 and $3 variables passed to script. Make this take string/switch parameters using em wah dut that testing that.
# TO DO? : use ffmpeg for upscaling instead?
# TO DO? : Allow upscale to target resolution?

numLoops=$1
howManyImages=$2
multiplierScale=$3

# Outer loop per howManyImages:
for a in $( seq $howManyImages )
do
	# Inner loop which produces each image:
	numbersNeedsPerRow=$(( $1 * 3 ))
	count=0
	for i in $( seq $numLoops )
	do
					echo Generating row for image number $a . . .
		count=$(( count + 1 ))
		shuf -i 1-255 -n $numbersNeedsPerRow > temp.txt
		tr '\n' ' ' < temp.txt > $count.temp
		echo >> $count.temp
	done

	rm temp.txt
	cat *.temp > grid.ppm
	rm *.temp

	printf "P3
	#the P3 means colors are in ascii, then 3 columns and 2 rows, then 255 for max color, then RGB triplets
	$1 $1
	255
	" > ppmheader.txt

					echo Concatenating generated rows into one new .ppm file . . .
	timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
	cat ppmheader.txt grid.ppm > $1x$1gridRND_$timestamp.ppm
	rm ppmheader.txt grid.ppm

	# Convert new image to upscaled (preserving hard edges) by 50 time as large png:
	newXpix=$((numbersNeedsPerRow * $multiplierScale))
					echo Creating enlarged png version with hard edges maintained . . .
	nconvert -ratio -rtype quick -resize $newXpix $newXpix -out png -o $1x$1gridRND_$timestamp.png $1x$1gridRND_$timestamp.ppm
done