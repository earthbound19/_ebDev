# DESCRIPTION
# Creates an mp4 video (AVC) from a series of numbered input images. Automatically detects the number of digits in the input frames. Expects *only* digits in the input filenames. Creates the animation at _out.mp4.

# WARNING: AUTOMATICALLY overwrites _out.mp4 if it already exists.

# USAGE
# From the directory with the image animation source images, invoke this script with these parameters:
# $1 input "frame rate" (how to interpret the speed of input images in fps)
# $2 desired output framerate
# $3 desired constant quality (crf)
# $4 the file extension of the input images.
# Optional: $5 rescale target resolution expressed as N[NN..]xN[NN..], for example 200x112; OR to scale to one target dimension and calculate the other automatically (to maintain aspect), give e.g. 1280:-1 (to produce an image that is 1280 pix wide by whatever the other dimension should be). Source images will be rescaled by nearest-neighbor (keep hard edges) option to this target resolution.
# TO DO; Optional: padding re https://superuser.com/a/690211

# NOTE: You can hack this script to produce an animated .gif image simply by changing the extension at the end of the applicable command line (line 32).

# TO DO? : make it name the output file after the ../.. parent folder name?

if [ ! -z ${5+x} ]
then
	rescaleParams="-vf scale=$5:-1:flags=neighbor"
		# echo rescaleParams val is\:
		# echo $rescaleParams
fi

# IN DEVELOPMENT: automatic centering of image in blacke matte borders (padding):
# steps:
# - get matte WxH intended
# - get src images to anim WxH
# - div. matte W / 2 for center X pixmark
# - div. src image W / 2 for offset from matte center X pixmark
# - subtr. offset from center X pixmark for X pixmark to place src images at.
# - Follow same process on Y to get Y offset pixmark and place src images there.
# - formulate ur paramater to pass to ffmpeg from that; in form:
# padParams=-vf "pad=width=1920:height=1080:x=0:y=0:color=black"
# ex commands to fetch and parse src pix dimensions is in getDoesIMGinstagram.sh.
# an example command wut does some math as would be needer per this algo: echo "scale=5; 3298 / 1296" | bc

# horked from renumberFiles.sh:
gfind *.$4 > allFiles.txt
dos2unix allFiles.txt
arraySize=$(wc -l < allFiles.txt)
numDigitsOf_arraySize=${#arraySize}
rm allFiles.txt

echo executing ffmpeg command . . .
# default codec for file type and UTvideo options both follow; comment out whatever you don't want; for the first you can change the _out.ttt file type to e.g. .mp4, .gif, etc.:
ffmpeg -y -f image2 -framerate $1 -i %0"$numDigitsOf_arraySize"d.$4 $rescaleParams -vf fps=$2 -crf $3 _out.mp4
# ffmpeg -y -f image2 -framerate $1 -i %0"$numDigitsOf_arraySize"d.$4 $rescaleParams -vf fps=$2 -crf $3 -codec:v utvideo _out.avi

		# EXPERIMENT re: https://stackoverflow.com/a/45465730
		# ffmpeg -y -i seeing_noaudio.mp4 -c copy -f h264 seeing_noaudio.h264
		# ffmpeg -y -r 24 -i seeing_noaudio.h264 -c copy seeing.mp4


# THE FOLLOWING could be adapted to a rawvideo option:
# ffmpeg -y -r 24 -f image2 -i doctoredFrames\mb-DGYTMSWA-fr_%07d.png -vf "format=yuv420p" -vcodec rawvideo -r 29.97 _DGYTMSWAsourceDoctoredUncompressed.avi

# DEV NOTES
# to enable simple interpolation to up the framerate to 30, use this tag in the codec/output flags section:
# -vf fps=30

# ex. OLD command: ffmpeg -y -r 18 -f image2 -i %05d.png -crf 13 -vf fps=30 out.mp4
