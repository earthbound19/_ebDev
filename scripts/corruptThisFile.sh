# DESCRIPTION
# Produces a corrupted version of whatever file you pass to it as a parameter, skipping the first N bytes of the file (see the skipHeaderBytes variable initialization at the start of this script). Designed for e.g. making glitch art from jpg images or mp4 movies. NOTE: because of bash math restraints (unless I use bc, no thanks), this will fail on files of size 100 bytes or less.

# USAGE
# Pass this script two parameters, being:
# $1 A file name.
# $2 What percent of the file to corrupt (in a copy of it)
# This will produce a corrupted version of the file, named __corrupted_"$2"pct_$timestamp__<originalFileName>.
# NOTE: See comment ALTERNATE OPTIONS HERE for other percent options (which are effective for variously sized files)

# TO DO: throw errors for missing paramaters and exit.
# TO DO? Add random (relatively rare, or paramaterized?) deletion of copied chunks before concatination.
# TO DO? If the source file is a common movie format, convert it first to a transport stream and corrupt that?
# TO DO? Exert fine control over header bytes skipped (by using dd bs=1, where it is now using the default 512 bytes).

# IMPORTANT GLOBAL:
skipHeaderBytes=1

fileToMakeCorruptedCopyOf=$1
percentToCorrupt=$2

# Retrieve extension of source file; thanks re http://stackoverflow.com/a/1665574 :
fileExt=`echo $fileToMakeCorruptedCopyOf | sed -n 's/.*\.\(.\{1,5\}\).*/\1/p'`

__ln=( $( ls -Lon "$fileToMakeCorruptedCopyOf" ) )
__size=${__ln[3]}
		echo file size in bytes is $__size.
__size_minus_header=$((__size - $skipHeaderBytes))
		echo file size minus header, in bytes, is $__size_minus_header.

		echo command one\: dd count=$skipHeaderBytes if=$fileToMakeCorruptedCopyOf of=header.dat
dd count=$skipHeaderBytes if=$fileToMakeCorruptedCopyOf of=header.dat
		echo command two\: dd skip=$skipHeaderBytes if=$fileToMakeCorruptedCopyOf of=imgData.dat
dd skip=$skipHeaderBytes if=$fileToMakeCorruptedCopyOf of=imgData.dat

# while there's still data left to corrupt, keep rolling a virtual die until you roll an N, then corrupt a random number of bytes left; this is all done as dd copies that will be concatenated later: 

__ln=( $( ls -Lon "imgData.dat" ) )
__size=${__ln[3]}
		echo file size of imgData.dat in bytes is $__size

echo Percent of file I should corrupt according to parameter passed to script\:
echo $percentToCorrupt

__ln=( $( ls -Lon "imgData.dat" ) )
__size=${__ln[3]}
			# echo file size of imgData in bytes is $__size
		# Re: reply by "lewis" here: http://echochamber.me/viewtopic.php?t=6377
		# Also: http://stackoverflow.com/a/7290825/1397555
			# To find what percent of N = y, divide N by 100, then mutliply by y:

# ALTERNATE OPTIONS HERE; comment out the one you don't want:
corruptionPasses=$(($__size / 100000 * $percentToCorrupt))
# corruptionPasses=$(($__size / 10000 * $percentToCorrupt))
# corruptionPasses=$(($__size / 1000 * $percentToCorrupt))
# corruptionPasses=$(($__size / 100 * $percentToCorrupt))
# corruptionPasses=3

echo will do $corruptionPasses corruption passes\, which is about $percentToCorrupt percent of the file . . .
for i in $( seq $corruptionPasses )
do
	echo Corruption write pass $i of $corruptionPasses underway . . .
	seekToByte=`shuf -i 1-"$__size" -n 1`
# TO DO: prefetch n random bytes earlier, and get new ones sequentially from that in memory.
	dd conv=notrunc bs=1 count=1 seek=$seekToByte if=/dev/urandom of=./imgData.dat
done

timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
cat header.dat imgData.dat > __corrupted_"$percentToCorrupt"pct_"$timestamp"__$fileToMakeCorruptedCopyOf
rm header.dat imgData.dat