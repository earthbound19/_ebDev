# DESCRIPTION
# Pseudorandomly picks a number in a range of bytes corresponding to byte size of file $1 (parameter $1 passed to script). This number is intended to be used to the pull that byte number (or a number of bytes starting at that byte number) via e.g. dd.

__ln=( $( ls -Lon "$1" ) )
__size=${__ln[3]}
	# echo "Size is: $__size bytes"
echo file size in bytes is $__size. getting random number in that range:

#re: http://stackoverflow.com/a/2556282
shuf -i 1-$__size -n 1