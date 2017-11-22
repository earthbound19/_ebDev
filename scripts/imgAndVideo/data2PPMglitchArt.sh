# Make a script that does this in ppm format, translating hex-mapped values to RGB values? Could (slowly) convert hex pairs to decimal numbers between 0 and 255 this way:
# valOne=`xxd -ps ocean2.wav`
# ..read over pairs of those values (put each in valTwo) and convert them to decimal, by adapting this, assuming $x is a string variable, and $p is an incrementing position:
# echo ${x:$p:2}          ;# syntax is ${string:index:length}
# ..


# DESCRIPTION
# Makes glitch art from any data source by creating a ppm header approximating a defined image size (at this writing square) into which that data would fit; takes that image header and slaps raw copied hex value pairs (converted to decimal) into an RGB value array which composes the remainder of the PPM format file. The result may be converted to any other image format e.g. via GraphicsMagick.

# USAGE
# ./thisScript.sh dataSource.file

# DEPENDENCIES
# a 'nix environment, xxd

# DETAILS
# Does a square root calculation (rounded) from the byte size of the data to determine the bmp X and Y dimensions which this creates a header from.

# CODE
fileToMakeCorruptedCopyOf=$1
__ln=( $( ls -Lon "$fileToMakeCorruptedCopyOf" ) )
__size=${__ln[3]}
side=`echo "sqrt ($__size)" | bc`

for i in $( seq $__size )
do
	echo fyerp
done

# cat stubHeader.txt "$fileToMakeCorruptedCopyOf"_rawHexTXT.txt > "$fileToMakeCorruptedCopyOf"_asPPM.ppm

# rm stubHeader.txt "$fileToMakeCorruptedCopyOf"_rawHexTXT.txt