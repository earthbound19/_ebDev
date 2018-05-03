# DESCRIPTION
# Produces a corrupted version of whatever file you pass to it as a parameter, skipping the first N bytes of the file (see the skipHeaderBytes variable initialization at the start of this script).

# USAGE
# Pass this script one parameter, being a file name. It will produce a corrupted version of the file, named <paramater>_corrupted.<original_file_extension>. Useful e.g. for making glitch art from jpg images. NOTE: it may mangle file names with a . before the extension. Untested. Dunno.

# NOTES: This was hard-coded for manipulating jpg images of about 256x256 pixels in size. At this writing, it may need serious tweaking for your purposes with larger images.

# TO DO: copyBytes random range by percent of file size, parameterized.
# TO DO: add random (relatively rare, or paramaterized?) deletion of copied chunks before concatination.

# IMPORTANT GLOBAL:
skipHeaderBytes=8

# Retrieve extension of source file; thanks re http://stackoverflow.com/a/1665574 :
fileExt=`echo $1 | sed -n 's/.*\.\(.\{1,5\}\).*/\1/p'`
mvDir=`echo $1 | sed "s/\(.*\)\.$fileExt/\1/g"`
if [ ! -d "$mvDir"_corrupted ]; then mkdir "$mvDir"_corrupted; fi

__ln=( $( ls -Lon "$1" ) )
__size=${__ln[3]}
echo file size in bytes is $__size.
__size_minus_header=$((__size - $skipHeaderBytes))
echo file size minus header, in bytes, is $__size_minus_header.

echo command one\: dd count=$skipHeaderBytes if=$1 of=header.dat
dd bs=1 count=$skipHeaderBytes if=$1 of=header.dat
echo command two\: dd skip=$skipHeaderBytes if=$1 of=imgData.dat
dd bs=1 skip=$skipHeaderBytes if=$1 of=imgData.dat

# while there's still data left to corrupt, keep rolling a virtual die until you roll an N, then corrupt a random number of bytes left; this is all done as dd copies that will be concatenated later: 
bytesCopied=0
chunksCopied=0
copyBytes=0
dieRoll=1

# VERY CONSEQUENTIAL VARIABLE (tweak--maybe make this script parametric:)
dieCorruptRoll=9

bytesRemaining=$__size_minus_header
while (( bytesRemaining > 0 ))
do
	# Keep rolling a virtual die. For each roll that is not N, decide on a random number of extra bytes to copy. For each roll that is N, finish this while loop, and copy the planned number of bytes to copy, then corrupt part of them.
	while [ $dieRoll -ne $dieCorruptRoll ]
	do
	dieRoll=`shuf -i 1-$dieCorruptRoll -n 1`
			echo Rolling the virtual die\; rolled a $dieRoll . . .
		#re: http://stackoverflow.com/a/2556282
	# newBytesToCopy=`shuf -i 512-3176 -n 1`		# A tested good range for e.g. 512x512 images.
	newBytesToCopy=`shuf -i 40-772 -n 1`		# good for 256x images?
	copyBytes=$((copyBytes + newBytesToCopy))
	done

	# We are here after we roll a virtual N on a die. Do the actual copying and corruption.
	chunksCopied=$(( chunksCopied + 1))
	formatChunksCopied=`printf "%0""12""d" $chunksCopied`
			# echo loop command\:
			# echo dd bs=1 if=./imgData.dat skip=$bytesCopied count=$copyBytes of=$formatChunksCopied.chunk
	dd bs=1 if=./imgData.dat skip=$bytesCopied count=$copyBytes of=$formatChunksCopied.chunk
		__ChunkLn=( $( ls -Lon "$formatChunksCopied.chunk" ) )
		__ChunkSize=${__ChunkLn[3]}
				# echo $formatChunksCopied.chunk size\: $__ChunkSize
	bytesCopied=$((bytesCopied + copyBytes))
				# echo bytesCopied is $bytesCopied
	bytesToCorrupt=`shuf -i 1-16 -n 1`

	# NOTE: IF YOU'RE NOT GETTING functional glitch images often enough, try commenting out one or two of the following if blocks:
	if [ $bytesToCorrupt -lt 7 ]
		then
				echo "______ rolled a(n) $dieCorruptRoll on a(n) ""$dieCorruptRoll""-sided virtual die. Decided to write $bytesToCorrupt patterned (but pseudo-random-sourced) bytes on copy via another roll from 1-17 with roll value less than 8. Will do this for chunk file\: $formatChunksCopied.chunk ______"
		dd bs=1 count=$bytesToCorrupt if=/dev/urandom of=tempGarbage.bin
		shred -f -n 1 -s $bytesToCorrupt -x --random-source=tempGarbage.bin ./$formatChunksCopied.chunk
		rm ./tempGarbage.bin
	fi
	if [ $bytesToCorrupt -lt 4 ]
		then
				echo "______ rolled a(n) $dieCorruptRoll on a(n) ""$dieCorruptRoll""-sided virtual die. Decided to write $bytesToCorrupt null (zero) bytes on copy via another roll from 1-17 with roll value less than 4. Will do this for chunk file\: $formatChunksCopied.chunk ______"
		shred -f -n $bytesToCorrupt -s $bytesToCorrupt -x --random-source=/dev/zero ./$formatChunksCopied.chunk
	fi
	if [ $bytesToCorrupt -gt 7 ]
		then
				echo "______ rolled a(n) $dieCorruptRoll on a(n) ""$dieCorruptRoll""-sided virtual die. Decided to corrupt $bytesToCorrupt bytes via another roll from 1-17. Will corrupt chunk file\: $formatChunksCopied.chunk ______"
		shred -f -n 1 -s $bytesToCorrupt -x --random-source=/dev/urandom ./$formatChunksCopied.chunk
		bytesRemaining=$((bytesRemaining - copyBytes))
	fi

			# echo bytesRemaining is $bytesRemaining
	# reset the virtual die to something that guarantees at least one roll on the next iteration through the loop:
	dieRoll=1
done

timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
cat header.dat *.chunk > $1_corrupted__$timestamp.$fileExt
# because my cygwin install can do stupid permissions things:
chmod 777 $1_corrupted__$timestamp.$fileExt

rm header.dat imgData.dat *.chunk

# Blerckh:
# Move the resulting file into a directory named after the file without the file extension. make the directory if it does not exist. (The directory name was determined and assigned to mvDir earlier.)
mv ./$1_corrupted__$timestamp.$fileExt ./$mvDir
# To open every finished image in your default windows image viewer after creation, uncomment the next line:
# cygstart ./$mvDir/$1_corrupted__$timestamp.$fileExt