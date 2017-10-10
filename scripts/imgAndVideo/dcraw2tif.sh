# DESCRIPTION
# Converts any camera raw format image file into a .tif file via dcraw.

# DEPENDENCIES
# dcraw

# USAGE
# Invoke this script with one parameter, being a raw image filename in your PATH. e.g.:
# ./thisScript.sh rawImageFileName.cr2

# I feel stupid that this far more efficient and elegant method of extracting file base names and extensions has eluded me for years, re: https://www.cyberciti.biz/faq/unix-linux-extract-filename-and-extension-in-bash/ -- this will speed up at least a few scripts.
fileName="${1%.*}"
fileExt=`echo "${1##*.}"`

	# - SCRATCHED -D switch; it makes the image very white. ? AND -W makes it very black. Together, they make it gray. (I assume that with good paramters they can adjust the white and black points.)
	dcraw -6 -w +M -o 0 -q 0 -T -q 3 -v -O "$fileName"_dcraw.tif "$1"

# ! :
# -z        Change file dates to camera timestamp [this doesn't do any conversion--it only corrects the file time stamp]
