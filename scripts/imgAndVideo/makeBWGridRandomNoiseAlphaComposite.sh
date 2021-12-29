# DESCRIPTION
# Animate RND block noise as in makeBWGridRandomNoiseAnim.sh, and use it as alpha in a composite animation with a foreground image animated over a background image, where the RND block noise is the animated transparency (or alpha) mask. Uses complete foreground image as first still and background as final still (with RND block noise anim between).

# DEPENDENCIES
# `ffmpeg`, `graphicsmagick` (as `gm`), `imgs2imgsNN.sh`, `ffmpegAnim.sh`.

# USAGE
# Run this script with these parameters:
# - $1 the number of desired columns of black or white boxes (block noise).
# - $2 The number of desired rows ".
# - $3 How many such images to make.
# - $4 How many such images to show per second in the output animation (which will be at 29.97 frames per second, with the input interpreted at $4 frames per second).
# - $5 Resolution to scale images up to for video (by nearest neighbor method), in pixels across.
# - $6 Resolution to scale images up to for video (by nearest neighbor method), in pixels down.
# - $7 background image file name. Defaults to `bg.png` if not provided.
# - $8 foreground image file name. Defaults to `fg.png` if not provided.
# Example that will generate images that are 5 columns wide, 8 rows high, make 28 such images, animate them at a source framerate of 0.65 per second, and blow them up to 746 x 1080px, assuming the image files `bg.png` and `fg.png` are in this directory:
#    makeBWGridRandomNoiseAlphaComposite.sh 5 8 28 0.65 746 1080
# NOTES
# - It seems that for ffmpeg to encode video from the source images, the source images must have an x pixel count (accross) which is an even number, and so must y (number of pixels down). Otherwise, ffmpeg may throw an error on encoding.
# - If the rnd block char mask is smaller or larger than the source images, it may be that the source images have different dpi than the generated alpha RND blocks (which would be expected to be default 72dpi).
# - You can leave space on the right or bottom of block character noise by giving smaller dimensions for the X and Y block noise upscale dimension parameters.


# CODE
numCols=$1
numRows=$2
howManyImages=$3
inputFPS=$4
if [ "$5" ]; then xTargetPix="$5"; else xTargetPix=1920; fi
if [ "$6" ]; then yTargetPix="$6"; else yTargetPix=1080; fi
if [ "$7" ]; then bgImageFileName="$7"; else bgImageFileName='bg.png'; fi
if [ "$8" ]; then fgImageFileName="$8"; else fgImageFileName='fg.png'; fi

# IMAGE FILE CHECKS and exit with warning if not found:
if [ ! -e $bgImageFileName ]; then echo "Warning: specified background file name or default bg.png not found. Exit."; exit 7; fi
if [ ! -e $fgImageFileName ]; then echo "Warning: specified foreground file name or default bg.png not found. Exit."; exit 8; fi
if [ ! -e $alphaFileName ]; then echo "Warning: specified alpha file name or default alpha.png not found. Exit."; exit 8; fi

squaresPerImage=$((numCols * numRows))

rndString=$(randomString.sh)
timestamp=$(date +"%Y_%m_%d__%H_%M_%S")
renderID="$timestamp"_"$rndString"
renderDir="$renderID"_BWgridRandomNoiseIMGs_
mkdir $renderID
cd $renderID

# loop per howManyImages, making RND block noise pbm image files:
for a in $( seq $howManyImages )
do
					echo Generating image\# $a . . .
	# Generate a text file of the number of pseudorandom "1s" and "0s" (white and black cubes) in the image:
	cat /dev/urandom | tr -dc '0-1' | head -c $squaresPerImage > grid.pbm
	# Split it into new lines by the number of columns ("digits") per line that should be in the image:
	sed -i "s/\(.\{$numCols\}\)/\1\n/g" grid.pbm
	# Intersperse all the digits with spaces:
	sed -i 's/\([0-9]\)/\1 /g' grid.pbm

	printf "P1
$numCols $numRows
" > ppmheader.txt
					echo Concatenating custom header and generated grid.pbm into new .pbm file . . .
	timestamp=$(date +"%Y_%m_%d__%H_%M_%S__%N")
	cat ppmheader.txt grid.pbm > "$numCols"x"$numRows"__"$timestamp".pbm
	rm ppmheader.txt grid.pbm
done

# convert all those pbm image files to blown up pngs by nearest neighbor method;
# set first and second param to imgs2imgsNN.sh depending on whether x edge is longer number (as imgs2imgsNN.sh wants longest edge first); set default and override if needed:
longerEdge=$xTargetPix
shorterEdge=$yTargetPix
# switch that if the reverse is true (or if both are equal switch again :shrug:) :
if (( $xTargetPix <= $yTargetPix))
then
	longerEdge=$yTargetPix
	shorterEdge=$xTargetPix
fi
imgs2imgsNN.sh pbm png $longerEdge $shorterEdge

# make an array of those resultant png files:
alphaFiles=( $(find . -maxdepth 1 -type f -iname \*.png -printf '%f\n') )
# calculate number of frames in final anim:
numFrames=${#alphaFiles[@]}
# adding two to that, as we'll make a start and end shim also:
numFrames=$((numFrames + 2))
# calculate number of digits of that for zero-padding:
digitsToPadTo=${#numFrames}
		# make fg first frame and bg last frame shims numbered at start (0) and end of anim:
		zeroFrameShim=$(printf "%0""$digitsToPadTo""d\n" 0)
		cp ../$fgImageFileName "$zeroFrameShim".png
# step over array and make composite from each alpha (block noise png) image in array;
# creating padded (animation frame) number file for each:
# starting at one because we'll make a shim 0 after this control block; these will start at 1 and first frame will be 0:
counter=1
for alphaFile in ${alphaFiles[@]}
do
	countString=$(printf "%0""$digitsToPadTo""d\n" $counter)
	# composite via compose mask; re:
	# https://legacy.imagemagick.org/Usage/compose/#mask
	# ex. command:
	# magick composite tile_water.jpg   tile_aqua.jpg  moon_mask.gif   mask_over.jpg
	# -- but that isn't working with imagemagick for me. But it does work with graphicsmagick! :

	# The actual composite! :
	gm composite ../$fgImageFileName ../$bgImageFileName $alphaFile "$countString".png
	# remove alpha png (pbm source remains) (NOTE: if you don't remove this, try moving it somewhere else -- it may mess up the ffmpeg render/file count sequence if you don't!) :
	rm $alphaFile
	counter=$((counter+1))
done
		# get count of one after last file:
		numAlphaFiles=${#alphaFiles[@]}; lastFrameShim=$((numAlphaFiles + 1))
		# use that count to get zero-padded final frame number:
		lastFrameShim=$(printf "%0""$digitsToPadTo""d\n" $lastFrameShim)
		cp ../$bgImageFileName "$lastFrameShim".png

# actual video file render! :
targetVideoFileName="$renderID"_BWGridRandomNoiseAlphaComposite.mp4
ffmpegAnim.sh $inputFPS 29.97 13 png

# move render up from this subdirectory:
mv _out.mp4 ../$targetVideoFileName

#cd ..
echo Done. Final file is $targetVideoFileName.
