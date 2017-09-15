# DESCRIPTION
# Creates an mp4 video (AVC) from a series of numbered input images. Automatically detects the number of digits in the input frames. Expects *only* digits in the input filenames. Creates the animation at _out.mp4.

# WARNING: AUTOMATICALLY overwrites _out.mp4 if it already exists.

# USAGE
# From the directory with the image animation source images, invoke this script with these parameters:
# $1 input "frame rate" (how to interpret the speed of input images in fps)
# $2 desired output framerate
# $3 desired constant quality (crf)
# $4 the file extension of the input images.

# Optional: $5 rescale target resolution expressed either as nnnnXnnnn or per the following note. Source images will be rescaled by nearest-neighbor (keep hard edges) option to this target resolution. To calculate and keep and aspect ratio automatically targeting a given X or Y pix dimension, specify one or the other and : -1; e.g. 320:-1 will target 320x pixels and whatever corresponding Y pixels would keep the aspect, or -1:800 would target 800y pixels and whatever corresponding X pixels will keep the aspect.

# NOTE: You can hack this script to produce an animated .gif image simply by changing the extension at the end of the applicable command line (line 32).

# TO DO? :
# Make it name the output file after the ../.. parent folder name?
# Optional padding re https://superuser.com/a/690211

if [ ! -z ${5+x} ]
then
	rescaleParams="-vf scale=$5:flags=neighbor"
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
find *.$4 > allFiles.txt
arraySize=$(wc -l < allFiles.txt)
numDigitsOf_arraySize=${#arraySize}
rm allFiles.txt

# UTvideo codec option; comment out the x264 codec option if you uncomment this:
# ffmpeg -y -f image2 -r $1 -i %0"$numDigitsOf_arraySize"d.$4 -r 29.97 -codec:v utvideo _out.avi

echo executing ffmpeg command . . .
# x264 codec option; comment out the UTvideo option if you uncomment this:
ffmpeg -y -f image2 -r $1 -i %0"$numDigitsOf_arraySize"d.$4 $rescaleParams -r $2 -crf $3 _out.mp4

# THE FOLLOWING could be adapted to a rawvideo option:
# ffmpeg -y -r 24 -f image2 -i doctoredFrames\mb-DGYTMSWA-fr_%07d.png -vf "format=yuv420p" -vcodec rawvideo -r 29.97 _DGYTMSWAsourceDoctoredUncompressed.avi

# DEV NOTES
# to enable simple interpolation to up the framerate to 30, use this tag in the codec/output flags section:
# -vf fps=30

# ex. OLD command: ffmpeg -y -r 18 -f image2 -i %05d.png -crf 13 -vf fps=30 out.mp4
