# DESCRIPTION
# Pseudorandomly picks a number in a range of bytes corresponding to byte size of file $1 (parameter $1 passed to script), and prints it. This number is intended to be used with e.g. dd for random byte sampling (e.g. from a give byte start position), for data bending/glitch art.

# USAGE
#    getRNDinFileBytesRange.sh inputFile.png
# To use from another script to assign the random byte index to a variable:
# rndByteIDX=`./getRNDinFileBytesRange.sh inputFile.png`


# CODE
__ln=( $( ls -Lon "$1" ) )
__size=${__ln[3]}
	# echo "Size is: $__size bytes"
# echo file size in bytes is $__size. getting random number in that range:

#re: http://stackoverflow.com/a/2556282
shuf -i 1-$__size -n 1