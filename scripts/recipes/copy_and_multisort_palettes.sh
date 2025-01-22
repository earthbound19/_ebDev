# DESCRIPTION
# By use of other scripts, for each .hexplt file in the current directory, copies the palette into subdirectories, and sorts the colors in each palette into a copy of the palette, all these different ways:
#    oklab starting on black
#    oklab starting on white
#    CAM16 starting on black
#    CAM16 starting on white
#    CIEDE2000 starting on black
#    CIEDE2000 starting on white
#	 HCT starting on black
#	 HCT starting on white
#    CIECAM02 starting on black
#    CIECAM02 starting on white
# Subdirectories are named after these sorting methods. The first colors to sort on can be hacked; see NOTE in USAGE.

# USAGE
# Run without any parameters:
#    copy_and_multisort_palettes.sh
# NOTE
# To change the start colors sorted against, change the color_one and color_two variables in the script.

# CODE
# TO DO:
color_one='000000'
color_two='ffffff'

palettes=$( (find . -maxdepth 1 -type f -iname '*.hexplt' -printf "%P\n") )

# expects two parameter $1 and $2, which are a color to start sorting on (a string) and a color distance (delta) space usable by coloraide (another string):
function sort_all_palettes_by_custom_space() {
	sort_folder=_palette_copies_sort_"$1"_"$2"
	if [ ! -d $sort_folder ]; then mkdir $sort_folder; fi
	for palette in ${palettes[@]}
	do
		cp $palette ./$sort_folder/$palette
	done
	cd $sort_folder
	sortAllHexPalettesColoraide.sh "-s $1 -w -c $2"
	renderAllHexPalettes.sh
	cd ..
}

sort_all_palettes_by_custom_space $color_one ok
sort_all_palettes_by_custom_space $color_two ok

sort_all_palettes_by_custom_space $color_one cam16
sort_all_palettes_by_custom_space $color_two cam16

sort_all_palettes_by_custom_space $color_one 2000
sort_all_palettes_by_custom_space $color_two 2000

sort_all_palettes_by_custom_space $color_one hct
sort_all_palettes_by_custom_space $color_two hct


# this can't use that sort_all_palettes_by_custom_space function as it uses another script:
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

