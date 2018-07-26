# DESCRIPTION
# resizes an image by nearest neighbor method via ffmpeg.

# UNTESTED: imgFileNoExt val.
# If I ever use it (I thought I might, but maybe not), I'll fix it up if necessary and remove this first comment.

# USAGE
# Invoke this script with three parameters, being:
# $1 input file
# $2 output format
# $3 px wide to resize to by nearest neighbor method, maintaining aspect

# template command; resizes to x800 px maintaining aspect ratio:
# ffmpeg -y -i in.png -vf scale=1280:-1:flags=neighbor out.png

imgFileNoExt=${1%.*}
ffmpeg -y -i $1 -vf scale=$3:-1:flags=neighbor $imgFileNoExt.$2