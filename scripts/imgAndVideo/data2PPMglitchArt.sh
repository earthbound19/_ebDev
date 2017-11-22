<<<<<<< HEAD
# DESCRIPTION
# Makes glitch art from any data source by creating a ppm header approximating a defined image size (at this writing square) into which that data would fit; takes that image header and writes rows of copied hex value pairs (converted to decimal) into an RGB value array which composes the remainder of the PPM format file. The result may be converted to any other image format e.g. via GraphicsMagick. Results end up in a new PPM image file named "$inputDataFile"_asPPM.ppm
=======
# Make a script that does this in ppm format, translating hex-mapped values to RGB values? Could (slowly) convert hex pairs to decimal numbers between 0 and 255 this way:
# valOne=`xxd -ps ocean2.wav`
# ..read over pairs of those values (put each in valTwo) and convert them to decimal, by adapting this, assuming $x is a string variable, and $p is an incrementing position:
# echo ${x:$p:2}          ;# syntax is ${string:index:length}
# ..


# DESCRIPTION
# Makes glitch art from any data source by creating a ppm header approximating a defined image size (at this writing square) into which that data would fit; takes that image header and slaps raw copied hex value pairs (converted to decimal) into an RGB value array which composes the remainder of the PPM format file. The result may be converted to any other image format e.g. via GraphicsMagick.
>>>>>>> ef8caf4f9a83a28e99197c08b655b2a55e56e338

# USAGE
# ./thisScript.sh dataSource.file

# DEPENDENCIES
# a 'nix environment, xxd

<<<<<<< HEAD
# CODE
# Get size of input data in bytes
inputDataFile=$1
__ln=( $( ls -Lon "$inputDataFile" ) )
__size=${__ln[3]}
# Assume a square target image size for the bent data by square root of that size, divided by three (because every triplet of hex pairs will make up one RGB value (or array of three values between 0-255) :
BMPsideLength=`echo "sqrt ($__size)" | bc`
BMPsideLength=$((BMPsideLength / 3))
    echo BMP length on each side will be $BMPsideLength. Churning HEX data into decimal triplets\, each of which will be an RGB value . . .

# Make P3 PPM format header, which a later generated array of RGB values will be concatenated to:
echo "P3" > PPMheader.txt
echo "# The P3 means colors are in ASCCI decimal, then $BMPsideLength columns and $BMPsideLength rows, then 255 for max color, then RGB triplets within that range:" >> PPMheader.txt
echo $BMPsideLength $BMPsideLength >> PPMheader.txt
echo 255 >> PPMheader.txt

# Will this break for very large files? :
hexMonolith=`xxd -ps $inputDataFile`
# Remove spaces (and line breaks?) from that:
hexMonolith=`echo $hexMonolith | tr -d ' \n'`
=======
# DETAILS
# Does a square root calculation (rounded) from the byte size of the data to determine the bmp X and Y dimensions which this creates a header from.

# CODE
inputDataFile=$1
__ln=( $( ls -Lon "$inputDataFile" ) )
__size=${__ln[3]}
    # echo __size val is\: $__size
BMPsideLength=`echo "sqrt ($__size)" | bc`
    # echo BMPsideLength $BMPsideLength
# divide that by 3 because we're going to use three decimal values from 0-255 for each pixel on each row:
BMPsideLength=$((BMPsideLength / 3))
    echo BMP length on each side will be $BMPsideLength. Churning HEX data into decimal triplets\, each of which will be an RGB value . . .

# Make P3 PPM format header:
echo "P3" > PPMheader.txt
echo "# The P3 means colors are in ascii, then $BMPsideLength columns and $BMPsideLength rows, then 255 for max color, then RGB triplets within that range:" >> PPMheader.txt
echo $BMPsideLength $BMPsideLength >> PPMheader.txt
echo 255 >> PPMheader.txt

# will this break for very large files? :
hexMonolith=`xxd -ps $inputDataFile`
# remove spaces (and line breaks?) from that:
hexMonolith=`echo $hexMonolith | tr -d ' \n'`
    # echo hexMonolith val is\:
    # echo $hexMonolith
>>>>>>> ef8caf4f9a83a28e99197c08b655b2a55e56e338

hexPairIndexCounter=0
colsCount=0
printf "" > PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
RGBvalsRowTXT=
for i in $( seq $__size )
do
      tmpHEX=${hexMonolith:$hexPairIndexCounter:2}
      RGBval=`echo $((16#$tmpHEX))`
<<<<<<< HEAD
=======
      # echo RGBval $RGBval
>>>>>>> ef8caf4f9a83a28e99197c08b655b2a55e56e338
      RGBvalsRowTXT="$RGBvalsRowTXT $RGBval"
      colsCount=$((colsCount + 1))
      if (($colsCount == $BMPsideLength))
      then
        # append RGBvalsRowTXT row to PPM body buildup file, and reset colsCount and RGBvalsRowTXT for next row accumulation:
        echo Made row at offset $i of $__size\; RGB decimal values\:
        echo $RGBvalsRowTXT
        echo appending that to PPM text body . . .
        echo $RGBvalsRowTXT >> PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
        echo ~~
        colsCount=0
        RGBvalsRowTXT=
      fi
      hexPairIndexCounter=$((hexPairIndexCounter + 2))
done

cat PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt > "$inputDataFile"_asPPM.ppm

rm PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

# OPTIONAL open of the file immediately after render (for Cygwin, "open" must be "cygstart") :
# open "$inputDataFile"_asPPM.ppm