# DESCRIPTION
# Sorts a palette into sub-sorted hue channel ranges in okLab space, with each sub-channel sorted starting on color $3, via `hexplt_split_to_channel_ranges_OKLAB.js` and text processing. See documentation of that script to understand what is meant by hue channel ranges. Result file is in name format `<fileBaseName>_sortSplitChannelsOkLab<fileExtension>.`

# USAGE
# Run with these parameters:
# - $1 source file to sort this way
# - $2 number of hue channel ranges
# - $3 OPTIONAL. sRGB hex color code without any # character, e.g. a44053, to start sorting on in each channel. If omitted defaults to perceptually neutral gray 191919, because sorting channels starting on gray produces some pretty darn interesting sort decisions and stuff with some palettes, in my opinion.


# CODE
if [ "$1" ]; then sourceFile=$1; else printf "\nNo parameter \$1 (source palette file) passed to script. Exit."; exit 1; fi
if [ "$2" ]; then numberOfHueDivisions=$2; else printf "\nNo parameter \$2 (number of hue channel ranges) passed to script. Exit."; exit 2; fi
if [ "$3" ]; then startSortColor=$3; else startSortColor='ffffff'; fi

# destination file format is: <fileBaseName>_sortSplitChannelsOkLab<fileExtension> :
destinationFileName=${sourceFile%.*}_sortSplitChannelsOkLab.${sourceFile##*.}

fullPathToScript=$(getFullPathToFile.sh hexplt_split_to_channel_ranges_OKLAB.js)

# make and copy source file into temp dir; wipe previously existing temp dir if it's there:
tmpDir=${sourceFile%.*}_sortSplitChannelsOkLab
if [ -d $tmpDir ]; then rm -rf $tmpDir; fi
mkdir $tmpDir

cp $sourceFile ./$tmpDir
cd $tmpDir
node $fullPathToScript -i $sourceFile -n $numberOfHueDivisions
rm $sourceFile

parametricHairball="-s $startSortColor"
allRGBhexColorSortInOkLab.sh "$parametricHairball"
renderAllHexPalettes.sh
cat *.hexplt > ../$destinationFileName
cd ..
# rm -rf $tmpDir

printf "DONE. Result file is $destinationFileName. Intermediary files (which you might find more useful) are in $tmpDir."