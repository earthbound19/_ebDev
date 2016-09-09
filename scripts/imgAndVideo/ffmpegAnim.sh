# DESCRIPTION
# Creates an mp4 video (AVC) from a series of numbered input images. Automatically detects the number of digits in the input frames. Expects *only* digits in the input filenames. Creates the animation at _out.mp4.

# WARNING: AUTOMATICALLY overwrites _out.mp4 if it already exists.

# USAGE
# From the directory with the image animation source images, invoke this script with these parameters:
# $1 desired output framerate
# $2 desired constant quality (crf)
# $3 the file extension of the input images.

# TO DO: adjustable input file list "frame rate."
# TO DO? : make it name the output file after the ../.. parent folder name?

# horked from renumberFiles.sh:
find *.$3 > allFiles.txt
arraySize=$(wc -l < allFiles.txt)
numDigitsOf_arraySize=${#arraySize}
rm allFiles.txt

ffmpeg -y -f image2 -i %0"$numDigitsOf_arraySize"d.$3 -r $1 -crf $2 _out.mp4

# DEV NOTES
# ex. command:
# ffmpeg -y -r 24 -f image2 -i doctoredFrames\mb-DGYTMSWA-fr_%07d.png -vf "format=yuv420p" -vcodec rawvideo -r 29.97 _DGYTMSWAsourceDoctoredUncompressed.avi

# to enable simple interpolation to up the framerate to 30, use this tag in the codec/output flags section:
# -vf fps=30

# ex. OLD command: ffmpeg -y -r 18 -f image2 -i %05d.png -crf 13 -vf fps=30 out.mp4
