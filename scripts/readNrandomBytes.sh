# DESCRIPTION
# Copies $2 random contiguous bytes from file $1 and writes them to file $3. Could be useful for data bending / glitch art.

# USAGE
# Invoke with these parameters:
# - $1 input file name
# - $2 how many contiguous bytes to read from random location in $1
# - $3 file name to write them to
# Example that reads 15 contiguous bytes from a random location in in.flam3, and writes them to flam3outFragments.bin:
#  readNrandomBytes.sh in.flam3 15 flam3outFragments.bin
# NOTES:
# - THIS SCRIPT MAY BE VERY SLUGGISH with files more than several thousand kilobytes in size.
# - To quickly make a random source file to test this with:
# dd count=200 bs=1 obs=1 if=/dev/urandom of=random2.bin

# TO DO
# - Write a script that calls this many times for a random selection of files, and assembles the results into glitch art.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (input file name). Exit."; exit 1; else inputFile=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (how many random bytes to read). Exit."; exit 1; else howManyBytesToRead=$2; fi
if [ ! "$3" ]; then printf "\nNo parameter \$3 (output file name). Exit."; exit 1; else outputFile=$3; fi

inputFileByteSize=`stat --printf="%s" $inputFile`
			# Because we want the "size" of the file to only be itself minus how many bytes to read (to avoid reading anywhere from the end of the file backward to $howManyBytesToRead but getting the same output, which would be a statistical anomoly . . . which only obsessed coders or cryptographers care about) :
inputFileByteSize=$(($inputFileByteSize - $howManyBytesToRead))
	echo inputFileByteSize val is\:
	echo $inputFileByteSize
skipToByte=`seq 0 $inputFileByteSize | sort -R | head -n 1`
	echo skipToByte val is\:
	echo $skipToByte

dd count=$howManyBytesToRead bs=1 obs=1 if=$inputFile of=$outputFile skip=$skipToByte
	# DANGEROUS HACK to make the above line randomly corrupt bytes on a drive:
	# dd count=$howManyBytesToRead bs=1 obs=1 if=/dev/urandom of=/dev/hda0 skip=$skipToByte


# DEVELOPER NOTES
# deprecated approach:
# __ln=( $( ls -Lon "$inputFile" ) )
# __size=${__ln[3]}
	# echo "Size is: $__size bytes"
# echo file size in bytes is $__size. getting random number in that range:

#re: http://stackoverflow.com/a/2556282
# shuf -i 1-$__size -n 1