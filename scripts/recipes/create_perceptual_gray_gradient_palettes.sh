# DESCRIPTION
# Runs getNshadesOfGrayCIECAM02.py N times (per default parameter or $1) to create grayscale palettes which run perceptually darker from N divisions of white to black.

# USAGE
# Run without any parameter to use the default number of palettes to create:
#    create_59_perceptual_gray_gradient_palettes.sh
# To create N palettes, pass any integer as the first parameter; for example to create 25 palettes, run:
#    create_59_perceptual_gray_gradient_palettes.sh 25
# NOTE
# Counting starts at 3 (because if you want a two-color palette of shades of gray, you can just create black and white), so the number of palettes created will actually be N-3.


# CODE
if [ ! "$1" ]; then number_of_palettes_to_make=120; else number_of_palettes_to_make=$1; fi

i=3
fullPathToSript=$(getFullPathToFile.sh getNshadesOfColorCIECAM02.py)
	# Alternate, for comparing RGB grayscale (it gets darker faster!) :
	# fullPathToSript=$(getFullPathToFile.sh getNshadesOfGrayRGB.py)
while [ $i -le $number_of_palettes_to_make ]
do
	renderTarget="$i"shadesOfGrayCIECAM02.hexplt
	if [ ! -e $renderTarget ]
	then
		echo "Will create palette with $i shades of gray . . ."
		python $fullPathToSript -c 'FFFFFF' -n $i -b 100
	else
		echo "Target palette file $renderTarget already exists. Will skip render."
	fi
	i=$(($i + 1))
done

echo DONE.