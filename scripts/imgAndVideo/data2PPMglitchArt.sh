# DESCRIPTION
# Makes glitch art from any data source by creating a ppm header approximating a defined image size (at this writing square) into which that data would fit; takes that image header and slaps raw copied hex value pairs (converted to decimal) into an RGB value array which composes the remainder of the PPM format file. The result may be converted to any other image format, apparently only by IrfanView (GraphicsMagick and NConvert choke on ppm files with hex values; IrfanView doesn't).

# USAGE
# ./thisScript.sh dataSource.file

# DEPENDENCIES
# a 'nix environment, xxd, optionally IrfanView and irfanView2imgNN.sh


# CODE

# pseudo-code:
# get data size
		# bcse 3 vals per px, sqrt(data size / 3) = x and y dim. of img
# ex. if data size is 27:
# sqrt (27 / 3) = 3
# x and y ppx dim. = that (3)
		# check:
		# f f f f f f f f f = triplet of pix (3 px wide); 9 vals
		# f f f f f f f f f
		# f f f f f f f f f = 3 rows of 9 vals = 27 = orig. data length.

imgFileNoExt=`echo $1 | sed 's/\(.*\)\..\{1,4\}/\1/g'`
ppmDestFileName="$imgFileNoExt""_asPPM.ppm"

inputDataFile=$1
__ln=( $( ls -Lon "$inputDataFile" ) )
__size=${__ln[3]}
IMGsideLength=`echo "sqrt ($__size / 3)" | bc`		# / 3 because three vals per pixel
valsPerRow=$((IMGsideLength * 3))

# Make P3 PPM format header:
echo "P3" > PPMheader.txt
echo "# P3 means text file, $IMGsideLength $IMGsideLength is cols x rows, ff is max color (hex 255), triplets of hex vals per RGB val." >> PPMheader.txt
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
      valsRowTXT="$valsRowTXT $HEXval"
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

cat PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt > $ppmDestFileName
# Optional and preferred to make the ppm file useable to all image converters that I've found besides IrfanView: convert result to spec-compliance (it would seem?) via IrfanView; the only thing I *don't* like about this is it can make column counts no longer match--which I call a bug and yet other programs seem to convert the result ok--BIG BREATH--comment out the next line if you don't want this:
# i_view32.exe $ppmDestFileName /convert=tmp_Zfrffb9Zbp2VdN.ppm && rm $ppmDestFileName && mv tmp_Zfrffb9Zbp2VdN.ppm $ppmDestFileName

rm PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

# Optionally open the file in the default associated program (Windows) :
# cygstart $ppmDestFileName

# optionally scale up by NN method by N pix, saving to png format:
# upscaleX=$((IMGsideLength * 160)) && irfanView2imgNN.sh $ppmDestFileName png $upscaleX