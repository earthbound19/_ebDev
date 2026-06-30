pathToScript=$(command -v PNGofRowsOfRandomVerticalColorStripes.py)
# echo pathToScript is $pathToScript

for i in $(seq 593)
do
	python $pathToScript -m2 -n11 -r15 -x1920 -y1080 -o12 -p40 -v6 --random-variant-interleave -s'Lake_Bonneville_Desert.hexplt'
done

# probably not necessary depending on if imgsGet~ lists the files properly:
renumberFiles.sh -epng

imgsGetSimilar.sh
mkNumberedCopiesFromFileList.sh
cd _temp_numbered/
ffmpegAnim.sh 30 30 11 png