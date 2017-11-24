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

# pseudo-code:
# get data size
#     the calc of ~bmp script is wrong i think! TO DO: fix that.
 # bcse 3 vals per px, sqrt(data size / 3) = x and y dim. of img?
# hrm. if data size is 27:
# sqrt (27 / 3) = 3
# x and y ppx dim. = that (3)
# f f f f f f f f f = triplet of pix (3 px wide); 9 vals
# f f f f f f f f f
# f f f f f f f f f = 3 rows of 9 vals = 27 = orig. data length.


# CODE
inputDataFile=$1
__ln=( $( ls -Lon "$inputDataFile" ) )
__size=${__ln[3]}
IMGsideLength=`echo "sqrt ($__size / 3)" | bc`
valsPerRow=$((IMGsideLength * 3))

# Make P3 PPM format header:
echo "P3" > PPMheader.txt
echo "# P3 means ASCCI, $IMGsideLength $IMGsideLength is cols x rows, ff is max color (hex 255), triplets of hex vals per RGB val." >> PPMheader.txt
echo $IMGsideLength $IMGsideLength >> PPMheader.txt
echo ff >> PPMheader.txt

echo impoarting data from $1 to local variable..
hexMonolith=`xxd -ps $inputDataFile`
# remove spaces (and line breaks?) from that:
hexMonolith=`echo $hexMonolith | tr -d ' \n'`

# Values used by the following for loop:
hexPairIndexCounter=0
colsCount=0
printf "" > PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
dataCutoff=$(( $valsPerRow * $IMGsideLength))   # For where there is more data than can fit in an image IMGsideLength x IMGsideLength
valsRowTXT=

echo Creating PPM $IMGsideLength x $IMGsideLength . . .
for i in $( seq $dataCutoff )
do
      HEXval=${hexMonolith:$hexPairIndexCounter:2}
      # echo HEXval $HEXval
      valsRowTXT="$valsRowTXT $HEXval"
          # echo $valsRowTXT
      colsCount=$((colsCount + 1))
      if (($colsCount == $valsPerRow))
      then
        # append valsRowTXT row to PPM body buildup file, and reset colsCount and valsRowTXT for next row accumulation:
        echo $valsRowTXT >> PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
        echo wrote new row at offset $1\: $valsRowTXT
        colsCount=0
        valsRowTXT=
      fi
      hexPairIndexCounter=$((hexPairIndexCounter + 2))
done

cat PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt > "$inputDataFile"_asPPM.ppm

rm PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

# open "$inputDataFile"_asPPM.ppm