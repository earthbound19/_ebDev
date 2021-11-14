# DESCRIPTION
# Animate RND block noise as in makeBWGridRandomNoiseAnim.sh, and use it as alpha in a composite animation with a foreground image animated over a background image, where the RND block noise is the animated transparency (or alpha) mask. THIS IS A STUB, in development.

# DEPENDENCIES
# `ffmpeg`, `graphicsmagick` (as `gm`), `imgs2imgsNN.sh`

# USAGE
# Run this script with these parameters:
# - $1 the number of desired columns of black or white boxes (block noise).
# - $2 The number of desired rows ".
# - $3 How many such images to make.
# - $4 How many such images to show per second in the output animation (which will be at 29.97 frames per second, with the input interpreted at $4 frames per second).
# - then wait (maybe a long time).
# - $5 Resolution to scale images up to for video (by nearest neighbor method), in pixels across.
# - $6 Resolution to scale images up to for video (by nearest neighbor method), in pixels down.
# - $7 background image file name. Defaults to `bg.png` if not provided.
# - $8 foreground image file name. Defaults to `fg.png` if not provided.

# Example that will generate images that are 24 columns wide, 16 rows high, and make 1024 such images, animate them at a source framerate of 5 per second, and blow them up to 1920 x 1080 px, assuming the image files `bg.png` and `fg.png` are in this directory:
#    makeBWGridRandomNoiseAlphaComposite.sh 24 16 1024 5 1920 1080


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

# convert all those pbm image files to blown up pngs by nearest neighbor method:
imgs2imgsNN.sh pbm png $xTargetPix $yTargetPix

# make an array of those resultant png files:
alphaFiles=( $(find . -maxdepth 1 -type f -iname \*.png -printf '%f\n') )

# calculate number of digits to pad numbered (animation) files to:
digitsToPadTo=${#alphaFiles[@]}; digitsToPadTo=${#digitsToPadTo}

# step over array and make composite from each alpha (block noise png) image in array;
# creating padded (animation frame) number file for each:
counter=0
for alphaFile in ${alphaFiles[@]}
do
	counter=$((counter+1))
	countString=$(printf "%0""$digitsToPadTo""d\n" $counter)
	# composite via compose mask; re:
	# https://legacy.imagemagick.org/Usage/compose/#mask
	# ex. command:
	# magick composite tile_water.jpg   tile_aqua.jpg  moon_mask.gif   mask_over.jpg
	# -- but that isn't working with imagemagick for me. But it does work with graphicsmagick! :

	# The actual composite! :
	gm composite ../fg.png ../bg.png $alphaFile "$countString".png
	# remove alpha png (pbm source remains) :
	rm $alphaFile
done

# actual video file render! :
targetVideoFileName="$renderID"_BWGridRandomNoiseAlphaComposite.mp4
ffmpegAnim.sh $inputFPS 29.97 13 png

# move render up from this subdirectory:
mv _out.mp4 ../$targetVideoFileName

cd ..
echo Done. Final file is $targetVideoFileName.

