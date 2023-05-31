# DESCRIPTION
# Variant of `data_bend_2PPMglitchArt.sh`. Represents arbitrary bytes (from any file) as data where each byte becomes one of the components of an RGB color. The color is hard-coded to result in blue to violet depending on the 0 to 255 value of the raw data, which is made into a component of <VALUE 0 255>, where VALUE is the data value from the source data. See also `all_data_bend_type2PPMglitchArt.sh`, which will call this script against every file of a given type in a path.

# DEPENDENCIES
# a Unix environment including the `od` utility, and optionally IrfanView and `img2imgNN.sh`

# USAGE
# Run with one parameter, which is a data source file name:
#    data_bend_2PPMglitchArt00padded.sh dataSource.file
# NOTES
# - Data is bent by making a ppm header approximating a square image size that the data will fit into, generating so many RGB values with the data as one component of the RGB values (as described), writing that as a ppm body, then combining the body with the ppm head. This is different from data_bend_2PPMglitchArt, where RGB values have an essentially random value. The result may be converted to any other image format via GraphicsMagick, ImageMagick, IrfanView, Photoshop, or any other utility that reads ppms files.
# - You *may* be able to reliably reverse the process to recreate an original file a PPM was made from: all of the hex values for a source file are recorded in a resulting PPM via this script. In other words, this may be a way to obfuscate data (but note that the obfuscation is easily reversed).



# CODE
# TO DO
# - alternative padding of the R or B values with zeros, OR copying a value to the other two unused RGB vals to produce a shade of gray.
# - once that's done, reintegrate those options into the original as options.
# - option to pad with any value you may want from 00-ff (also including in whichever column?), not just 00.

ppmDestFileName=${1%.*}_asPPM.ppm

inputDataFile=$1
__ln=( $( ls -Lon "$inputDataFile" ) )
__size=${__ln[3]}
IMGsideLength=`echo "sqrt ($__size)" | bc`		# / 3 because three vals per pixel
echo will create image of dimensions $IMGsideLength x $IMGsideLength.

# Make P3 PPM format header:
echo "P3" > PPMheader.txt
echo "# P3 means text file, $IMGsideLength $IMGsideLength is cols x rows, 255 is max color (RGB 255), triplets of hex vals per RGB val." >> PPMheader.txt
echo $IMGsideLength $IMGsideLength >> PPMheader.txt
	# DEPRECATED: ff as max color (hex) ; now it's 255:
echo 255 >> PPMheader.txt

# Make P3 PPM body:
		# DEPRECATED HEX option (seems not to be standard; result rejected by GraphicsMagick and ImageMagick, but accepted by IrfanView:
		# od -t x1 -w$IMGsideLength $inputDataFile > PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
# DECIMAL option:
od -An -t d1 -w$IMGsideLength $inputDataFile > PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
# NOTE: to make a green tint any other color you can make with only blue and red (whatever sense it makes to say green tint here), you can change the zeros in the following sed regex to anything from 00 to ff hex; 00 would look like: ..  00 \1 00  ..
		# some options (NOTE that the hex options are deprecated) ;
		# "green tints" of medium dark, dimmish purple:												68 \1 b6			decimal: 105 \1 182
		# "blue tints" of dim green:																00 5b \1			decimal: 00 91 \1
		# varied pink or purple bordering a slightly greenish dimmish shade of eggshell blue:		\1 7f ff			decimal: \1 127 255
		# but really for that I prefer, at least for RGB:																decimal: \1 0 255
		# shades of blue, no other hues:															0 0 \1				decimal: 0 0 \1
		# For other possibilities, see: RGB_combos_of_255_127_and_0_repetition_allowed.hexplt
		# DEPRECATED sed command focused on converting hex:
		# sed -i 's/ \([0-9a-z]\{2\}\)/ 00 5b \1 /g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
sed -i 's/ \([0-9]\{1,\}\)/ 105 \1 182 /g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
# strip off the byte offset count (I think it is) info at the start of each row, via sed;
# DEPRECATED as unnecessary via adding -An flag to od call:
# sed -i 's/^[0-9]\{1,\} \(.*\)/\1/g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
# reduce any double-spaces (which may result from earlier text processing) to single, twice:
sed -i 's/  / /g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
sed -i 's/  / /g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt
# delete still-resulting double spaces at start:
# sed -i 's/^  //g' PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

# Concatenate the header and body into a new, complete PPM format file:
cat PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt > $ppmDestFileName
rm PPMheader.txt PPMtableTemp_huuRgKWvYvNtw5jd5CWPyJMc.txt

echo . . .
echo creation of $ppmDestFileName DONE. Undergoing any further optional steps . . .

	# Optional and preferred to make the ppm file usable to all image converters that I've found besides IrfanView: convert result to spec-compliance (it would seem?) via IrfanView; the only thing I *don't* like about this is it can make column counts no longer match--which I call a bug and yet other programs seem to convert the result OK--BIG BREATH--comment out the next line if you don't want this:
# i_view32.exe $ppmDestFileName /convert=tmp_Zfrffb9Zbp2VdN.ppm && rm $ppmDestFileName && mv tmp_Zfrffb9Zbp2VdN.ppm $ppmDestFileName

	# Optionally open the file in the default associated program (Windows) :
# cygstart $ppmDestFileName

	# optionally scale up by NN method by N pix, saving to png format:
# upscaleX=$((IMGsideLength * 36)) && img2imgNN.sh $ppmDestFileName png $upscaleX

echo DONE.