# DESCRIPTION
# Makes glitch art from any data source by creating a bmp header approximating a defined image size (at this writing square) into which that data would fit; takes that image header and slaps raw copied data from any source onto the end of it. It breaks the bmp spec and yet many image editors will display and convert the image (to non-broken "glitch" converted images) anyway.

# USAGE
# ./thisScript.sh dataSource.file

# DEPENDENCIES
# GraphicsMagick, dd

# DETAILS
# Does a square root calculation (rounded) from the byte size of the data to determine the bmp X and Y dimensions which this creates a header from.

# TO DO
# Various data mapping, signal processing/pattern matching type things to data to more meaningfully map it to color values. e.g. for every  raw RGB (three values from 0 to 255)-aligned datum map to fewer values approximating the range of that datum?

fileToMakeCorruptedCopyOf=$1
__ln=( $( ls -Lon "$fileToMakeCorruptedCopyOf" ) )
__size=${__ln[3]}
		# echo file size in bytes is $__size
		# echo square root of that (rounded to integer) is:
		# echo "sqrt ($__size)" | bc
side=`echo "sqrt ($__size)" | bc`
		# echo side val is\: $side

gm convert -compress none -size "$side"x"$side" xc:gray stub.bmp
		# NOTE that we want 2 x 27 bytes (count=2, bs=27) for 54 bytes, the size of the header as I'm seeing it in a hex editor:
		# Byte size of header figured from http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm (file header + image header size) and observing color values white FF FF FF and gray 7E 7E 7E at offset 0x36 (hex for decimal 54) in a hex editor.
dd bs=27 count=2 if=stub.bmp of=stubHeader.dat
cat stubHeader.dat $fileToMakeCorruptedCopyOf > "$fileToMakeCorruptedCopyOf"_asBMP.bmp


# rm stub.bmp stubHeader.dat