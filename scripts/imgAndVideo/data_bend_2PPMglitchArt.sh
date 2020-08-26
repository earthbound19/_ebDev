# DESCRIPTION
# Makes glitch art from any data source by creating a ppm header approximating a defined image size (at this writing square) into which that data would fit; takes that image header and slaps raw copied hex value pairs (converted to decimal) into an RGB value array which composes the remainder of the PPM format file. The result may be converted to any other image format, apparently only by IrfanView (GraphicsMagick and NConvert choke on ppm files with hex values; IrfanView doesn't). SEE ALTERNATE script data_bend_2PPMglitchArt00padded.sh for a better data representation option.

# DEPENDENCIES
# a Unix environment including the `od` utility, and optionally IrfanView and `img2imgNN.sh`

# USAGE
# Run with one parameter, which is the file name of the data source:
#    data_bend_2PPMglitchArt.sh dataSource.file
# NOTES
# You *may* be able to reliably reverse the process to recreate an original file a PPM was made from: all of the hex values for a source file are recorded in a resulting PPM via this script. In other words, this may be a way to obfuscate data (but note that the obfuscation is easily reversed).


# CODE
# TO DO
# Data padding to align bytes more representationally with RGB values, e.g. pad one byte (two hex) with four zeros where [(R G) B], [R (G B)], or [(R) G (B)] values would be; so [(00 00) val] for the first case, etc.

# DEVELOPER NOTES
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

# Make P3 PPM body:
# Dump file to one-byte hex columns $valsPerRow per row, via od
od -t x1 -w$valsPerRow $inputDataFile > PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
# strip off the byte offset count (I think it is) info at the start of each row, via sed:
sed -i 's/^[0-9]\{1,\} \(.*\)/\1/g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

# Concatenate the header and body into a new, complete PPM format file:
cat PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt > $ppmDestFileName
rm PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

echo . . .
echo creation of $ppmDestFileName DONE. Undergoing any further optional steps . . .

	# Optional and preferred to make the ppm file usable to all image converters that I've found besides IrfanView: convert result to spec-compliance (it would seem?) via IrfanView; the only thing I *don't* like about this is it can make column counts no longer match--which I call a bug and yet other programs seem to convert the result OK--BIG BREATH--comment out the next line if you don't want this:
# i_view32.exe $ppmDestFileName /convert=tmp_Zfrffb9Zbp2VdN.ppm && rm $ppmDestFileName && mv tmp_Zfrffb9Zbp2VdN.ppm $ppmDestFileName

	# Optionally open the file in the default associated program (Windows) :
# cygstart $ppmDestFileName

	# optionally scale up by NN method by N pix, saving to png format; check the i_view32 option:
# upscaleX=$((IMGsideLength * 36)) && img2imgNN.sh $ppmDestFileName png $upscaleX

echo DONE.


# DEV NOTES
# Far better options than rev. x of this script, where I contrived a needlessly elaborate control block to create and format data in a way that exiting tools in my path already (?!) already do! :
# Use od for hex output instead? Ex. command that outputs 5 1-byte hex values per row:
# od -t x1 -w5 input.dat
# OR an xxd command that does more formatting for me up front; 1 byte per column, 9 columns:
# xxd -g 1 -c 9 TREACHERY1.7.fountain