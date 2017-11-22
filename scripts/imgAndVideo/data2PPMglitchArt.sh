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
inputDataFile=$1
__ln=( $( ls -Lon "$inputDataFile" ) )
__size=${__ln[3]}
    # echo __size val is\: $__size
BMPsideLength=`echo "sqrt ($__size)" | bc`
    # echo BMPsideLength $BMPsideLength
# divide that by 3 because we're going to use three decimal values from 0-255 for each pixel on each row:
BMPsideLength=$((BMPsideLength / 3))
    # echo now is $BMPsideLength

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

hexPairIndexCounter=0
colsCount=0
printf "" > PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
RGBvalsRowTXT=
for i in $( seq $__size )
do
      tmpHEX=${hexMonolith:$hexPairIndexCounter:2}
      RGBval=`echo $((16#$tmpHEX))`
      # echo RGBval $RGBval
      RGBvalsRowTXT="$RGBvalsRowTXT $RGBval"
      colsCount=$((colsCount + 1))
      if (($colsCount == $BMPsideLength))
      then
        # append RGBvalsRowTXT row to PPM body buildup file, and reset colsCount and RGBvalsRowTXT for next row accumulation:
        echo $RGBvalsRowTXT >> PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
        colsCount=0
        RGBvalsRowTXT=
      fi
      hexPairIndexCounter=$((hexPairIndexCounter + 2))
done

cat PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt > "$inputDataFile"_asPPM.ppm

rm PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

# open "$inputDataFile"_asPPM.ppm