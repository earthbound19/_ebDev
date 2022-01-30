# DESCRIPTION
# Sorts (filters) all images in the current directory which have similarity threshold $1 to image $2. Moves those sorted images into a randomly named subfolder (after the pattern _similar_images_<rndChars>) and prints the subfolder name when sorting is complete.


# DEPENDENCIES
# `printAllIMGfileNames.sh`, GraphicsMagick, image files in the current directory to work on, and bash / GNU utilities

# USAGE
# Run with these parameters:
# - $1 A decimal between 0 and 1, which is the difference threshold to consider a file similar enough to sort. Similarity is defined as nearer to 1; a different threshold of 0 means the images are identical, and 1 means they're completely different. Comparisons where the found threshold are equal to or lower than this number will be sorted as meeting the difference threshold.
# - $2 File name of image to compare all other images to.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (a decimal between 0 and 1, which is a difference threshold--see USAGE comments in source) passed to script. Exit."; exit 1; else differenceThreshold=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$1 (file name of source image to compare all other images to) passed to script. Exit."; exit 2; else sourceIMGfileName=$2; fi

echo getting image file names . . .
allIMGs=( $(printAllIMGfileNames.sh) )
	# THIS WORKS to delete the comparison image from that array; re: https://stackoverflow.com/a/16861932/1397555 -- BUT it's super duper slow on a very large array, so doing faster check later:
	# allIMGs=( ${allIMGs[@]/$sourceIMGfileName} )
rndStr=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 11)

rndSortSubfolderName=_thresholdFilteredImages_"$rndStr"
mkdir $rndSortSubfolderName

echo running comparisons . . .
for comparisonIMG in ${allIMGs[@]}
do
	# only do comparison if they are not the same image (as the image to compare to will be in the array; don't compare it to itself) :
	if [ "$sourceIMGfileName" != "$comparisonIMG" ]
	then
				echo "Comparing image $comparisonIMG to $sourceIMGfileName with threshold $differenceThreshold . . ."
		threshold=$(gm compare -metric MAE $sourceIMGfileName $comparisonIMG | sed -n 's/.*Total: \([0-9\.]\{1,\}\).*/\1/p')
		if (( $(echo "$threshold <= $differenceThreshold" |bc -l) ))
		then
			# echo "true for $threshold <= $differenceThreshold"
			mv $comparisonIMG ./$rndSortSubfolderName/
		fi
	fi
done

echo "DONE sorting images by similarity threshold to image file $sourceIMGfileName. Any that were found similar by threshold $differenceThreshold are in the subfolder $rndSortSubfolderName."