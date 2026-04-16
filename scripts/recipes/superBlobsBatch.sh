# DESCRIPTION
# Creates many pngs and svgs of black random blob shapes on a transparent background, cropped to blog edges, via other scripts. Why would you want such images? Correct. (I have art pipeline uses for them as masks, for example.)

# DEPENDENCIES
# randomBlob.py, imgs2imgs.sh, BMPs2SVGs.sh, cropTransparencyOffAllImages.py, and padImage.py, all from the _ebDev repository. All of their respective dependencies too. An MSYS2 or bash environment. These must all be in your PATH.

# USAGE
# From an empty directory, run the script:
#    superBlobsBatch.sh
# It runs through a preset variety of switches to randomBlob.py, to make different types of blobs.
# Results will be in png and svg subfolders.


# CODE
scriptFileName=randomBlob.py
fullPathToScript=$(command -v $scriptFileName)
if [[ $fullPathToScript == "" ]]
then
	printf "ERROR: script $scriptFileName not found in PATH. Exit.\n"
	exit 1
else
	printf "script file $scriptFileName found at $fullPathToScript; proceeding.\n"
fi

# check that:


if [ -n "$(ls -A)" ] && [ -n "$(ls -A | grep -v -E '^(pngs|svgs)$')" ]; then
    printf "\nPROBLEM: this directory has files already. This script generates many files and enforces as a design choice that it to only run in an empty directory. Create and navigate to an empty directory and run this script again from that. It's okay to alternately only have subdirectories named 'pngs' and/or 'svgs' (without quote marks in the names). Any other setup will cause this script to throw.)\n"
	exit 1
else
	printf "Current directory found to be empty (or have only acceptable subfolders svgs|pngs); proceeding.\n\n"
fi

printf "CHEWBACCCAAAA HRRHRNRNRRNRRRGGG!!\n\n"

commandSwitchesSets=(
"-p 1 -n 14 -l 15"
"-p 1 -n 17 -l 12"
"-p 1 -n 7 -l 18"
"-p 1 -n 7 -l 19"
"-p 1 -n 14 -l 16"
"-p 1 -n 17 -l 13"
"-p 1 -n 17 -l 14"
"-p 1 -n 14 -l 17"
"-p 1 -n 7 -l 20"
"-p 1 -n 7 -l 21"
"-p 1 -n 14 -l 18"
"-p 1 -n 17 -l 15"
"-p 1 -n 14 -l 19"
"-p 1 -n 17 -l 16"
"-p 1 -n 7 -l 24"
"-p 1 -n 17 -l 17"
"-p 1 -n 14 -l 20"
"-p 1 -n 7 -l 28"
"-p 1 -n 8 -l 18"
"-p 1 -n 17 -l 18"
"-p 1 -n 14 -l 21"
"-p 1 -n 8 -l 19"
"-p 1 -n 17 -l 19"
"-p 1 -n 14 -l 24"
"-p 1 -n 8 -l 20"
"-p 1 -n 18 -l 12"
"-p 1 -n 14 -l 28"
"-p 1 -n 8 -l 21"
"-p 1 -n 15 -l 15"
"-p 1 -n 18 -l 13"
"-p 1 -n 18 -l 14"
"-p 1 -n 15 -l 16"
"-p 1 -n 8 -l 24"
"-p 1 -n 18 -l 15"
"-p 1 -n 8 -l 28"
"-p 1 -n 15 -l 17"
"-p 1 -n 9 -l 18"
"-p 1 -n 15 -l 18"
"-p 1 -n 18 -l 16"
"-p 1 -n 15 -l 19"
"-p 1 -n 18 -l 17"
"-p 1 -n 9 -l 19"
"-p 1 -n 18 -l 18"
"-p 1 -n 15 -l 20"
"-p 1 -n 9 -l 20"
"-p 1 -n 18 -l 19"
"-p 1 -n 15 -l 21"
"-p 1 -n 9 -l 21"
"-p 1 -n 15 -l 24"
"-p 1 -n 9 -l 24"
"-p 1 -n 19 -l 12"
"-p 1 -n 9 -l 28"
"-p 1 -n 15 -l 28"
"-p 1 -n 19 -l 13"
"-p 1 -n 19 -l 14"
"-p 1 -n 10 -l 18"
"-p 1 -n 16 -l 15"
"-p 1 -n 19 -l 15"
"-p 1 -n 16 -l 16"
"-p 1 -n 10 -l 19"
"-p 1 -n 16 -l 17"
"-p 1 -n 10 -l 20"
"-p 1 -n 19 -l 16"
"-p 1 -n 19 -l 17"
"-p 1 -n 16 -l 18"
"-p 1 -n 10 -l 21"
"-p 1 -n 19 -l 18"
"-p 1 -n 16 -l 19"
"-p 1 -n 10 -l 24"
"-p 1 -n 16 -l 20"
"-p 1 -n 19 -l 19"
"-p 1 -n 10 -l 28"
"-p 1 -n 16 -l 21"
"-p 1 -n 20 -l 12"
"-p 1 -n 11 -l 18"
"-p 1 -n 16 -l 24"
"-p 1 -n 20 -l 13"
"-p 1 -n 11 -l 19"
"-p 1 -n 16 -l 28"
"-p 1 -n 11 -l 20"
"-p 1 -n 20 -l 14"
"-p 1 -n 17 -l 15"
"-p 1 -n 11 -l 21"
"-p 1 -n 20 -l 15"
"-p 1 -n 11 -l 24"
"-p 1 -n 17 -l 16"
"-p 1 -n 20 -l 16"
"-p 1 -n 11 -l 28"
"-p 1 -n 17 -l 17"
"-p 1 -n 20 -l 17"
"-p 1 -n 17 -l 18"
"-p 1 -n 20 -l 18"
"-p 1 -n 12 -l 18"
"-p 1 -n 12 -l 19"
"-p 1 -n 20 -l 19"
"-p 1 -n 17 -l 19"
"-p 1 -n 17 -l 20"
"-p 1 -n 12 -l 20"
"-p 1 -n 21 -l 12"
"-p 1 -n 12 -l 21"
"-p 1 -n 21 -l 13"
"-p 1 -n 17 -l 21"
"-p 1 -n 21 -l 14"
"-p 1 -n 17 -l 24"
"-p 1 -n 12 -l 24"
"-p 1 -n 21 -l 15"
"-p 1 -n 17 -l 28"
"-p 1 -n 12 -l 28"
"-p 1 -n 21 -l 16"
"-p 1 -n 18 -l 15"
"-p 1 -n 13 -l 18"
"-p 1 -n 18 -l 16"
"-p 1 -n 21 -l 17"
"-p 1 -n 13 -l 19"
"-p 1 -n 21 -l 18"
"-p 1 -n 13 -l 20"
"-p 1 -n 18 -l 17"
"-p 1 -n 18 -l 18"
"-p 1 -n 13 -l 21"
"-p 1 -n 21 -l 19"
"-p 1 -n 13 -l 24"
"-p 1 -n 18 -l 19"
"-p 1 -n 24 -l 12"
"-p 1 -n 13 -l 28"
"-p 1 -n 24 -l 13"
"-p 1 -n 18 -l 20"
"-p 1 -n 18 -l 21"
"-p 1 -n 24 -l 14"
"-p 1 -n 14 -l 18"
"-p 1 -n 14 -l 19"
"-p 1 -n 24 -l 15"
"-p 1 -n 18 -l 24"
"-p 1 -n 14 -l 20"
"-p 1 -n 24 -l 16"
"-p 1 -n 18 -l 28"
"-p 1 -n 19 -l 15"
"-p 1 -n 14 -l 21"
"-p 1 -n 24 -l 17"
"-p 1 -n 19 -l 16"
"-p 1 -n 24 -l 18"
"-p 1 -n 14 -l 24"
"-p 1 -n 19 -l 17"
"-p 1 -n 14 -l 28"
"-p 1 -n 24 -l 19"
"-p 1 -n 19 -l 18"
"-p 1 -n 15 -l 18"
"-p 1 -n 28 -l 12"
"-p 1 -n 15 -l 19"
"-p 1 -n 28 -l 13"
"-p 1 -n 19 -l 19"
"-p 1 -n 15 -l 20"
"-p 1 -n 28 -l 14"
"-p 1 -n 19 -l 20"
"-p 1 -n 28 -l 15"
"-p 1 -n 19 -l 21"
"-p 1 -n 15 -l 21"
"-p 1 -n 19 -l 24"
"-p 1 -n 28 -l 16"
"-p 1 -n 15 -l 24"
"-p 1 -n 15 -l 28"
"-p 1 -n 19 -l 28"
"-p 1 -n 28 -l 17"
"-p 1 -n 20 -l 15"
"-p 1 -n 28 -l 18"
"-p 1 -n 16 -l 18"
"-p 1 -n 20 -l 16"
"-p 1 -n 28 -l 19"
"-p 1 -n 16 -l 19"
"-p 1 -n 16 -l 20"
"-p 1 -n 20 -l 17"
"-p 1 -n 16 -l 21"
"-p 1 -n 20 -l 18"
"-p 1 -n 20 -l 19"
"-p 1 -n 16 -l 24"
"-p 1 -n 20 -l 20"
"-p 1 -n 16 -l 28"
"-p 1 -n 20 -l 21"
"-p 1 -n 17 -l 18"
"-p 1 -n 20 -l 24"
"-p 1 -n 17 -l 19"
"-p 1 -n 17 -l 20"
"-p 1 -n 20 -l 28"
"-p 1 -n 21 -l 15"
"-p 1 -n 17 -l 21"
"-p 1 -n 21 -l 16"
"-p 1 -n 17 -l 24"
"-p 1 -n 21 -l 17"
"-p 1 -n 17 -l 28"
"-p 1 -n 21 -l 18"
"-p 1 -n 21 -l 19"
"-p 1 -n 21 -l 20"
"-p 1 -n 21 -l 21"
"-p 1 -n 21 -l 24"
"-p 1 -n 21 -l 28"
"-p 1 -n 24 -l 15"
"-p 1 -n 24 -l 16"
"-p 1 -n 24 -l 17"
"-p 1 -n 24 -l 18"
"-p 1 -n 24 -l 19"
"-p 1 -n 24 -l 20"
"-p 1 -n 24 -l 21"
"-p 1 -n 24 -l 24"
"-p 1 -n 24 -l 28"
"-p 1 -n 28 -l 15"
"-p 1 -n 28 -l 16"
"-p 1 -n 28 -l 17"
"-p 1 -n 28 -l 18"
"-p 1 -n 28 -l 19"
"-p 1 -n 28 -l 20"
"-p 1 -n 28 -l 21"
"-p 1 -n 28 -l 24"
"-p 1 -n 28 -l 28"
)

# Always quote the expansion to preserve spaces
for switchSet in "${commandSwitchesSets[@]}"
do
	python $fullPathToScript $switchSet
done

fullPathToScript=$(command -v cropTransparencyOffAllImages.py)
python $fullPathToScript -t png -a -o
imgs2imgs.sh png bmp
BMPs2SVGs.sh smooth
rm *.bmp *.png

allSVG2img.sh 512 png ffffff00

if [ ! -d svgs ]; then mkdir svgs; fi
mv *.svg ./svgs/

fullPathToScript=$(command -v padImage.py)
echo fullPathToScript is $fullPathToScript

for i in $(ls *.png);
do
	python $fullPathToScript -i $i -c ffffff00 -r 512 -s 512 -o
done

if [ ! -d pngs ]; then mkdir pngs; fi
mv *.png ./pngs/

printf "\n\nDone making many blob images, cropping them to trim off excess white space, converting them to svgs, and sorting the svgs and original pngs into subdirectories.\n"