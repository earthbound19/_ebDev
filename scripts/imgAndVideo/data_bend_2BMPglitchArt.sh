# DESCRIPTION
# Makes glitch art (via data bending) from any data source by creating a bmp header approximating a defined image size (at this writing square) into which that data would fit; takes that image header and slaps raw copied data from any source onto the end of it. It breaks the bmp spec and yet many image editors will display and convert the image (to non-broken "glitch" converted images) anyway.

# DEPENDENCIES
# GraphicsMagick, `dd`

# USAGE
# Run with one parameter:
# - $1 input file to make a "bent" (glitch art) copy of.
# Exampe command:
#    data_bend_2BMPglitchArt.sh dataSource.file

# CODE
# DETAILS
# Does a square root calculation (rounded) from the byte size of the data to determine the bmp X and Y dimensions which this creates a header from.
if [ ! "$1" ]; then echo "No parameter \$1 (source file to bend). Exit."; exit; else sourceFile=$1 fi;

imgFileNoExt=`echo $sourceFile | sed 's/\(.*\)\..\{1,4\}/\1/g'`
ppmDestFileName="$imgFileNoExt"_asBMP.bmp

fileToMakeCorruptedCopyOf=$sourceFile
__ln=( $( ls -Lon "$fileToMakeCorruptedCopyOf" ) )
__size=${__ln[3]}
		# echo file size in bytes is $__size
side=`echo "sqrt ($__size / 3)" | bc`
		# echo side val is\: $side

gm convert -compress none -size "$side"x"$side" xc:gray stub.bmp
		# NOTE that we want 2 x 27 bytes (count=2, bs=27) for 54 bytes, the size of the header as I'm seeing it in a hex editor:
		# Byte size of header figured from http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm (file header + image header size) and observing color values white FF FF FF and gray 7E 7E 7E at offset 0x36 (hex for decimal 54) in a hex editor.
dd bs=27 count=2 if=stub.bmp of=stubHeader.dat
cat stubHeader.dat $fileToMakeCorruptedCopyOf > $ppmDestFileName

rm stub.bmp stubHeader.dat