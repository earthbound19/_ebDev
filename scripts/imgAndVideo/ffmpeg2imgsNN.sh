# DESCRIPTION
# Calls ffmpeg2imgNN.sh repeatedly for every file of type $1, converting to format $2, upscaled to target max dimension $3.

# USAGE
# Run with these parameters:
# - $1 input file types to upscale by nearest neighbor method
# - $2 target file type (must be different than $1 unless you want to clobber those)
# - $3 length of longest dimension to upscale to, maintaining aspect.
# Example that will convert all png images to bmps scaled up with 1280 pixels on their longest side:
#    ffmpeg2imgsNN.sh png bmp 1280


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (type of file to scan for and operate on) passed to script. Exit."; exit 1; else source_format=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (target file format) passed to script. Exit."; exit 1; else dest_format=$2; fi
if [ ! "$3" ]; then printf "\nNo parameter \$3 (longest dimension to upscale to, maintaining aspect) passed to script. Exit."; exit 1; else max_dimension=$3; fi

files=( $(find . -maxdepth 1 -type f -iname \*.$source_format -printf '%f\n') )
for file in ${files[@]}
do
	ffmpeg2imgNN.sh $file $dest_format $max_dimension
done