# DESCRIPTION
# For preparation for data bending animation. Could have other purposes I don't know. Takes source file $1 and copies increasing numbers of bytes from it to numbered files named after it, in a subfolder also named after it (plus some random characters). Bytes are in multiples of optional parameter $2 (default value 1). Also, file names of byte copies are given the extension .dat.

# USAGE
# Run with these parameters:
# - $1 source file to make so many incrementing byte copies of
# - $2 OPTIONAL. Byte increment of copies. Of not provided, defaults to 1.
# For example:
#    copyIncrementedBytes.sh A_Screed_Into_the_Void.txt
# NOTE
# To use this from another script and make use of the subfolder name, call it with `source`:
#    source copyIncrementedBytes.sh A_Screed_Into_the_Void.txt
# -- and then use the $copyIncrementedBytesSubfolderName, which will be set in your environment if you call this script and return from it that way.

# KEYWORDS
# print, copy, byte, data bending, data bent, animation, type, increment

# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source file to make so many incrementing byte copies of) passed to script. Exit."; exit 1; else sourceFile=$1; fi
# set default value for byteIncrement if $2 not provided; else use $2:
if [ ! "$2" ]; then byteIncrement=1; else byteIncrement=$2; fi

# Adapted from getRNDinFileBytesRange.sh:
fileInfoArray=( $( ls -Lon "$sourceFile" ) )
byteSizeOfSourceFile=${fileInfoArray[3]}
numDigitsToPadTo=${#byteSizeOfSourceFile}

fileNameNoExt=${sourceFile%.*}
rndStr=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 11)
copyIncrementedBytesSubfolderName="$fileNameNoExt"_bytesCopies_"$rndStr"

mkdir $copyIncrementedBytesSubfolderName

# speedup (no call to printf for digit pad formattting) obtained via genius breath yon: https://stackoverflow.com/a/8789815/1397555
for i in $(seq -f %0"$numDigitsToPadTo"g 0 $byteIncrement $byteSizeOfSourceFile)
do
	echo Running byte copy operation $i of $byteSizeOfSourceFile . . .
	outfile="$copyIncrementedBytesSubfolderName""/""$fileNameNoExt"_toByte_$i.dat
	dd bs=$byteIncrement count=$i if=$sourceFile > $outfile
done

echo "DONE. Files are in folder $copyIncrementedBytesSubfolderName."
