# DESCRIPTION
# Variant of data_bend_2PPMglitchArt.sh. Makes glitch art from any data source by creating a ppm header approximating a defined image size (at this writing square) into which that data would fit; takes that image header and slaps raw copied hex value pairs (converted to decimal) into an RGB value array which composes the remainder of the PPM format file. However, this variant pads those hex values with 00 in what would be the R and B of RGB values in the result, to produce a monochrome image of varying shades of green to "display" varying data values. (Actually, it may pad with arbitrary values I've hard coded for any other color; the commends explain how to set those values to anything *you* want.) The result may be converted to any other image format, apparently only by IrfanView (GraphicsMagick and NConvert choke on ppm files with hex values; IrfanView doesn't).

# USAGE
# ./thisScript.sh dataSource.file

# DEPENDENCIES
# a 'nix environment including the od utility, and optionally IrfanView and irfanView2imgNN.sh

# NOTES
# You *may* be able to reliably reverse the process to recreate an original file a PPM was made from: all of the hex values for a source file are recorded in a resulting PPM via this script. In other words, this may be a way to obfuscate data (but note that the obfuscation is easily unmaked or reversed).

# TO DO
# Alternative padding of the R or B values with zeros, OR copying a value to the other two unused RGB vals to produce a shade of gray.
# Once that's done, reintegrate those options into the original as options.
# Option to pad with any value you may want from 00-ff (also including in whichever column?), not just 00.


# CODE
imgFileNoExt=`echo $1 | sed 's/\(.*\)\..\{1,4\}/\1/g'`
ppmDestFileName="$imgFileNoExt""_asPPM.ppm"

inputDataFile=$1
__ln=( $( ls -Lon "$inputDataFile" ) )
__size=${__ln[3]}
IMGsideLength=`echo "sqrt ($__size)" | bc`		# / 3 because three vals per pixel
echo will create image of dimensions $IMGsideLength x $IMGsideLength.

# Make P3 PPM format header:
echo "P3" > PPMheader.txt
echo "# P3 means text file, $IMGsideLength $IMGsideLength is cols x rows, ff is max color (hex 255), triplets of hex vals per RGB val." >> PPMheader.txt
echo $IMGsideLength $IMGsideLength >> PPMheader.txt
echo ff >> PPMheader.txt

# Make P3 PPM body:
od -t x1 -w$IMGsideLength $inputDataFile > PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
# NOTE: to make a green tint any other color you can make with only blue and red (whatever sense it makes to say green tint here), you can change the zeros in the following sed regex to anything from 00 to ff hex; 00 would look like: ..  00 \1 00  ..
# some options;
# "green tints" of medium dark, dimmish purple:												68 \1 b6
# "blue tints" of dim green:																00 5b \1
# varied pink or purple bordering a slightly greenish dimmish shade of eggshell blue:		\1 7f ff
# For other possibilities, see: RGB_combos_of_255_127_and_0_repetition_allowed.hexplt
sed -i 's/ \([0-9a-z]\{2\}\)/ 00 5b \1 /g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
# strip off the byte offset count (I think it is) info at the start of each row, via sed:
sed -i 's/^[0-9]\{1,\} \(.*\)/\1/g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
# reduce any double-spaces (which may result from earlier text processing) to single:
sed -i 's/  / /g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

# Concatenate the header and body into a new, complete PPM format file:
cat PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt > $ppmDestFileName
rm PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

echo . . .
echo creation of $ppmDestFileName DONE. Undergoing any further optional steps . . .

	# Optional and preferred to make the ppm file useable to all image converters that I've found besides IrfanView: convert result to spec-compliance (it would seem?) via IrfanView; the only thing I *don't* like about this is it can make column counts no longer match--which I call a bug and yet other programs seem to convert the result ok--BIG BREATH--comment out the next line if you don't want this:
# i_view32.exe $ppmDestFileName /convert=tmp_Zfrffb9Zbp2VdN.ppm && rm $ppmDestFileName && mv tmp_Zfrffb9Zbp2VdN.ppm $ppmDestFileName

	# Optionally open the file in the default associated program (Windows) :
# cygstart $ppmDestFileName

	# optionally scale up by NN method by N pix, saving to png format:
# upscaleX=$((IMGsideLength * 36)) && irfanView2imgNN.sh $ppmDestFileName png $upscaleX

echo DONE.