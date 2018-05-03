# DESCRIPTION
# Reads n random bytes from file y, where n is paramater $2 (number of bytes) to be passed to script, and y is paramater $1 (a file name) to be passed to script. Why? Um. Nothing practical probably. Actually, it can be hacked to randomly destroy bits on a device (drive) for whatever purposes you would want to do that for which are not malicious (I actually have such purposes--simulate hard drive corruption in a virtual machine). Something I did to thaw out after a hard work day. Writes the result to an output file randomBytes.bin

# USAGE
# readNrandomBytes.sh ./in.flam3 15
# This script assumes two parameters, being $1 a file name to read and $2 how many random bytes to read from file $1 from a random position in the file.
# ALSO: THIS SCRIPT MAY BE VERY SLUGGISH with files more than several thousand kilobytes in size.
# To quickly make a random source file to test this with:
# dd count=200 bs=1 obs=1 if=/dev/urandom of=random2.bin

NOTE:

howManyBytesToRead=$2
	echo howManyBytesToRead val is\:
	echo $howManyBytesToRead
inputFileByteSize=`stat --printf="%s" $1`
			# Because we want the "size" of the file to only be itself minus how many bytes to read (to avoid reading anywhere from the end of the file backward to $howManyBytesToRead but getting the same output, which would be a statistical anomoly . . . which only obsessed coders or cryptographers care about) :
inputFileByteSize=$(($inputFileByteSize - $howManyBytesToRead))
	echo inputFileByteSize val is\:
	echo $inputFileByteSize
skipToByte=`seq 0 $inputFileByteSize | sort -R | head -n 1`
	echo skipToByte val is\:
	echo $skipToByte

dd count=$howManyBytesToRead bs=1 obs=1 if=$1 of=randomBytes.bin skip=$skipToByte
	# DANGEROUS HACK to make the above line randomly corrupt bytes on a drive:
	# dd count=$howManyBytesToRead bs=1 obs=1 if=/dev/urandom of=/dev/hda0 skip=$skipToByte


# NOTES
# deprecated script from a silly similarly named script readRandomNbytes.sh :p :
# Read n bytes from file name parameter $1 (parameter $2 specificies how many bytes). EXCEPT this doesn't do that, yet. Right now, it generates a random number in the range of how many bytes long the input file is.

# __ln=( $( ls -Lon "$1" ) )
# __size=${__ln[3]}
	# echo "Size is: $__size bytes"
# echo file size in bytes is $__size. getting random number in that range:

#re: http://stackoverflow.com/a/2556282
# shuf -i 1-$__size -n 1