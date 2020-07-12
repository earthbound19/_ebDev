# DESCRIPTION
# Generates a series of images of black and white boxes (noise scaled up with hard edges preserved), the sum of all black and white boxes in all images being just over the number of bits in a megabyte, then strings them together into a video representative of about 1 megabyte (in bits). Accomplishes this by first generating so many .pbm format (plain-text) images, then converting them (and animating them). Result filename is of format <timestamp>__1MB_img_seq_representation.mp4

# DEPENDENCIES
# A 'nixy environment, ffmpeg, renumberFiles.sh, mkNumberedLinks.sh

# USAGE
# Run this script with these parameters:
# - $1 the number of desired columns of black or white boxes.
# - $2 The number of desired rows ".
# - $3 How many such images to make.
# - $4 How many such images to show per second in the output animation (which will be at 29.97 frames per second, with the input interpreted at $4 frames per second).
# - then wait (maybe a long time).
# NOTE: at this writing, if not always, you must manually specify the target video size hard-coded at the end fo this script (in the ffmpeg parameters).
#  src/[timestamp]__1MB_img_seq_representation.mp4


# CODE
# RE pbm format: http://wiki.christophchamp.com/index.php?title=Portable_pixmap_(file_format)#P1
# NOTES (AND THE MATH) TO REPRESENT 1 MB in a BW noise anim:
# Use a 144x80 pixel image of black and white noise (so, 11520 squares), blown up with hard edges preserved to 1280x720. Use a series of these. Use 729 of them. = 8,398,080 squares. ~= 8,388,608, which is the number of 1s and 0s in 1 Megabyte (in the power of 2 definition; an alternate definition is by powers of 10, re: http://searchstorage.techtarget.com/definition/megabyte and https://en.wikipedia.org/wiki/Megabyte ). 1 megabyte = 1024 kilobytes, 1 kilobyte = 1024 bytes. 1024 kilobytes * 1024 bytes * 8 bits per byte = 8,388,608 bits.
# PUTTING THAT TOGETHER, call this script thus:
#  makeBWGridRandomNoiseAnim.sh 144 80 729 7 
# TO DO
# - Take parameters to this script to alter the following globals.
# - Alter the scale=1280:960 vars accordingly--or wouldn't I just use e.g. 1280:-1 to maintain aspect with 1280 x pixels?

numCols=$1
numRows=$2
howManyImages=$3
inputFPS=$4
	# DEPRECATED; was for using nconvert to upscale image; can be done directly with ffmpeg:
	# multiplierScale=125
squaresPerImage=$((numCols * numRows))

# Outer loop per howManyImages:
for a in $( seq $howManyImages )
do
					echo Generating image\# $a . . .
	# Generate a text file of the number of pseudorandom "1s" and "0s" (white and black cubes) in the image:
	cat /dev/urandom | tr -dc '0-1' | head -c $squaresPerImage > grid.pbm
# TO DO: See if you can make all this data in files in-memory and cat therefrom.
	# Split it into new lines by the number of columns ("digits") per line that should be in the image:
	sed -i "s/\(.\{$numCols\}\)/\1\n/g" grid.pbm
	# Intersperse all the digits with spaces:
	sed -i 's/\([0-9]\)/\1 /g' grid.pbm

	printf "P1
$numCols $numRows
" > ppmheader.txt
					echo Concatenating custom header and generated grid.pbm into new .pbm file . . .
	timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
	cat ppmheader.txt grid.pbm > "$numCols"x"$numRows"__"$timestamp".pbm
	rm ppmheader.txt grid.pbm

		# DEPRECATED: usage of nconvert. Nearest-neighbor resizing can be done directly by ffmpeg.
		# Convert new image to upscaled (preserving hard edges) by N times as large png:
		# newXpix=$((numCols * $multiplierScale))
		# newYpix=$((numRows * $multiplierScale))
						# echo Creating enlarged png version with hard edges maintained . . .
						# DEPRECATED, because ffmpeg can do nearest-neighbor resize from a ppm internally; e.g. ffmpeg -y -f image2 -i %03d.pbm -vf scale=1280:720:flags=neighbor .. :
						# nconvert -ratio -rtype quick -resize 1000 1000 -out png -o "$numCols"x"$numRows"__"$timestamp".png "$numCols"x"$numRows"__"$timestamp".pbm
done

mkNumberedLinks.sh pbm
cd numberedLinks

numDigits=`ls *.pbm | head -n 1`
numDigits=`basename $numDigits .pbm`
numDigits=${#numDigits}
		# echo numDigits val is $numDigits
timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
ffmpeg -y -framerate $inputFPS -f image2 -i %0"$numDigits"d.pbm -vf scale=1280:960:flags=neighbor -crf 17 -c:a aac -strict experimental -tune fastdecode -pix_fmt yuv420p -b:a 192k -ar 48000 -r 29.97 "$timestamp"__1MB_img_seq_representation.mp4

mv "$timestamp"__1MB_img_seq_representation.mp4 ..
rm *.pbm
cd ..
rmdir numberedLinks

# mkdir _src_"$timestamp"__1MB_img_seq_representation
# mv *.pbm _src_"$timestamp"__1MB_img_seq_representation