# DESCRIPTION: IN DEVELOPMENT. Read n bytes from file name parameter $1 (parameter $2 specificies how many bytes). EXCEPT this doesn't do that, yet. Right now, it generates a random number in the range of how many bytes long the input file is.

__ln=( $( ls -Lon "$1" ) )
__size=${__ln[3]}
	# echo "Size is: $__size bytes"
echo file size in bytes is $__size. getting random number in that range:

#re: http://stackoverflow.com/a/2556282
shuf -i 1-$__size -n 1