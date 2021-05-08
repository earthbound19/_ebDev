# DESCRIPTION
# Creates an mp4 video (AVC) from a flat text file list of input image (or video!) file names (one image file name per line in list). Creates the animation at _out.mp4.

# WARNING
# This script overwrites _out.mp4 if it already exists.

# USAGE
# From the directory with the image animation source images, run this script with these parameters:
# - $1 input "frame rate" (how to interpret the speed of input images in fps)
# - $2 desired output framerate
# - $3 desired constant quality (crf)
# - $4 the flat text file list of image file names to string into an animation _out.mp4.
# Optional: $5 rescale target resolution expressed as nnnnXnnnn. Source images will be rescaled by nearest-neighbor (keep hard edges) option to this target resolution.
# NOTES:
# - The expected list format is, per ffmpeg:
#    file 0001.png
#    file 0002.png
#    file 0003.png
# -- etc.
# - You can hack this script to produce an animated .gif image simply by changing the extension at the end of the applicable command line (line 32). - You may prefer to instead build a file list by way of mkNumberedLinksFromFileList.sh for use with ffmpegAnim.sh, because file concatenation with ffmpeg, it seems, can be buggy and drop frames.
# - If your source files are still images, uncomment the framerateParam line of code. If your source files are videos, comment that line out.


# CODE
# TO DO
# ? make it name the output file after the ../.. parent folder name?
# Adapt the script from which this is derived to handle parameter $4 here (and then scrap this script)?

if [ "$5" ]
then
	rescaleParams="-vf scale=$5:-1:flags=neighbor"
		# echo rescaleParams val is\:
		# echo $rescaleParams
fi

# framerateParam="-framerate $1"

# re https://stackoverflow.com/questions/25073292/how-do-i-render-a-video-from-a-list-of-time-stamped-images --it works--! :
# TWO OPTIONS on the following two lines; first is x264, second is lossless compressed UTvideo codec avi; comment out what you don't want:
ffmpeg -y $framerateParam -f concat -i $4 -vf fps=$2 -crf $3 _out.mp4
# ffmpeg -y -f concat -framerate $1 -i $4 -vf fps=$2 -crf $3 -codec:v utvideo _out.avi

# | ffmpeg -y -framerate $1 -f image2pipe $rescaleParams -r $2 -crf $3 _out.mp4

# THE FOLLOWING could be adapted to a rawvideo option:
# ffmpeg -y -framerate 24 -f image2 -i doctoredFrames\mb-DGYTMSWA-fr_%07d.png -vf "format=yuv420p" -vcodec rawvideo -r 29.97 _DGYTMSWAsourceDoctoredUncompressed.avi

# DEV NOTES
# to enable simple interpolation to up the framerate to 30, use this tag in the codec/output flags section:
# -vf fps=30

# ex. OLD command: ffmpeg -y -framerate 18 -f image2 -i %05d.png -crf 13 -vf fps=30 out.mp4
