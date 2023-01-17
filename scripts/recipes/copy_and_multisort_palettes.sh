# DESCRIPTION
# By use of other scripts, for each .hexplt file in the current directory, copies the palette into subdirectories, and sorts the colors in each palette into a copy of the palette, all these different ways:
#    oklab starting on black
#    oklab starting on white
#    CIECAM02 starting on black
#    CIECAM02 starting on white
#    CAM16 starting on black
#    CAM16 starting on white
# Subdirectories are named after these sorting methods. The first colors to sort on can be hacked; see NOTE in USAGE.

# USAGE
# Run without any parameters:
#    copy_and_multisort_palettes.sh
# NOTE
# To change the start colors sorted against, change the color_one and color_two variables in the script.

# CODE
color_one='000000'
color_two='ffffff'

palettes=$( (find . -maxdepth 1 -type f -iname '*.hexplt' -printf "%P\n") )

# oklab sort on color_one first
# the following variable will be repeatedly redefined:
sort_folder=_palette_copies_sort_oklab_$color_one
if [ ! -d $sort_folder ]; then mkdir $sort_folder; fi
for palette in ${palettes[@]}
do
	# filter out non-color information in the palette on the fly via grep; slower than making an array of array of reformatted palettes (which I tried and failed to do), but faster than repeated runs of reformatAllHexPalettes.sh:
	cat $palette | grep -i -o '#[0-9a-f]\{6\}' > ./$sort_folder/$palette
done
cd $sort_folder
allRGBhexColorSortInOkLab.sh $color_one
renderAllHexPalettes.sh
cd ..

# oklab sort on color_two
sort_folder=_palette_copies_sort_oklab_$color_two
if [ ! -d $sort_folder ]; then mkdir $sort_folder; fi
for palette in ${palettes[@]}
do
	cat $palette | grep -i -o '#[0-9a-f]\{6\}' > ./$sort_folder/$palette
done
cd $sort_folder
allRGBhexColorSortInOkLab.sh $color_two
renderAllHexPalettes.sh
cd ..

# CIECAM02 sort on color_one
sort_folder=_palette_copies_sort_CIECAM02_$color_one
if [ ! -d $sort_folder ]; then mkdir $sort_folder; fi
for palette in ${palettes[@]}
do
	cat $palette | grep -i -o '#[0-9a-f]\{6\}' > ./$sort_folder/$palette
done
cd $sort_folder
allRGBhexColorSortInCIECAM02.sh $color_one
renderAllHexPalettes.sh
cd ..

# CIECAM02 sort on color_two
sort_folder=_palette_copies_sort_CIECAM02_$color_two
if [ ! -d $sort_folder ]; then mkdir $sort_folder; fi
for palette in ${palettes[@]}
do
	cat $palette | grep -i -o '#[0-9a-f]\{6\}' > ./$sort_folder/$palette
done
cd $sort_folder
allRGBhexColorSortInCIECAM02.sh $color_two
renderAllHexPalettes.sh
cd ..

# CAM16-UCS sort on color_one
sort_folder=_palette_copies_sort_CAM16_$color_one
if [ ! -d $sort_folder ]; then mkdir $sort_folder; fi
for palette in ${palettes[@]}
do
	cat $palette | grep -i -o '#[0-9a-f]\{6\}' > ./$sort_folder/$palette
done
cd $sort_folder
allRGBhexColorSortInCAM16-UCS.sh $color_one
renderAllHexPalettes.sh
cd ..

# CAM16-UCS sort on color_two
sort_folder=_palette_copies_sort_CAM16_$color_two
if [ ! -d $sort_folder ]; then mkdir $sort_folder; fi
for palette in ${palettes[@]}
do
	cat $palette | grep -i -o '#[0-9a-f]\{6\}' > ./$sort_folder/$palette
done
cd $sort_folder
allRGBhexColorSortInCAM16-UCS.sh $color_two
renderAllHexPalettes.sh
cd ..