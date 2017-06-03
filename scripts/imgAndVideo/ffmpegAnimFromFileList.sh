# DESCRIPTION
# Creates an mp4 video (AVC) from a flat text file list of input image file names (one image file name per line in list). Creates the animation at _out.mp4.

# WARNING: AUTOMATICALLY overwrites _out.mp4 if it already exists.

# USAGE
# From the directory with the image animation source images, invoke this script with these parameters:
# $1 input "frame rate" (how to interpret the speed of input images in fps)
# $2 desired output framerate
# $3 desired constant quality (crf)
# $4 the flat text file list of image file names to string into an animation _out.mp4.
# Optional: $5 rescale target resolution expressed as nnnnXnnnn. Source images will be rescaled by nearest-neighbor (keep hard edges) option to this target resolution.

# NOTE: You can hack this script to produce an animated .gif image simply by changing the extension at the end of the applicable command line (line 32).

# TO DO? : make it name the output file after the ../.. parent folder name?

if [ ! -z ${5+x} ]
then
	rescaleParams="-vf scale=$5:flags=neighbor"
		# echo rescaleParams val is\:
		# echo $rescaleParams
fi

# UTvideo codec option; comment out the x264 codec option if you uncomment this:
# ffmpeg -y -f image2 -r $1 -i %0"$numDigitsOf_arraySize"d.$4 -r 29.97 -codec:v utvideo _out.avi

# DEV render command that WORKS! :
ffmpeg -y -f concat -r $1 -i $4 -r $2 -crf $3 _out.mp4

# | ffmpeg -y -r $1 -f image2pipe $rescaleParams -r $2 -crf $3 _out.mp4

# THE FOLLOWING could be adapted to a rawvideo option:
# ffmpeg -y -r 24 -f image2 -i doctoredFrames\mb-DGYTMSWA-fr_%07d.png -vf "format=yuv420p" -vcodec rawvideo -r 29.97 _DGYTMSWAsourceDoctoredUncompressed.avi

# DEV NOTES
# to enable simple interpolation to up the framerate to 30, use this tag in the codec/output flags section:
# -vf fps=30

# ex. OLD command: ffmpeg -y -r 18 -f image2 -i %05d.png -crf 13 -vf fps=30 out.mp4
