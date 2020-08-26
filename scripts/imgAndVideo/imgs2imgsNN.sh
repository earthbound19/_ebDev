# DESCRIPTION
# Resizes all images of type T (via parameter $1) in the current path, by nearest-neighbor method, to target format F ($2), at size A x B ($3 x $4). (Nearest neighbor method will keep hard edges, or look "pixelated.") Runs `img2imgNN.sh` repeatedly to do this.

# USAGE
# This script uses the same parameters as `img2imgNN.sh`, EXCEPT that parameter $1 is a file type instead of a specific file. All files of type $1 will be passed to imgs2imgsNN.sh:
# - $1 source file type
# - $2 destination format
# - $3 scale by nearest neighbor method to pixels X
# - $4 OPTIONAL. Force this Y-dimension, regardless of aspect. Scales by nearest neighbor method to pixels Y. ONLY USED for ppms. Ignored for all other types (aspect kept). SEE COMMENTS in i_view32.exe code lines area for options to maintain aspect and/or rotate image (wanted for my purposes at times).
# Example command:
#    imgs2imgsnn.sh ppm png 640
# OR, to force a given x by y dimension for a ppm:
#    imgs2imgsNN.sh ppm png 640 480


# CODE
array=(`find . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n' | tr -d '\15\32'`)
for img in ${array[@]}
do
	img2imgNN.sh $img $2 $3 $4
done