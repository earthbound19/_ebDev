# DESCRIPTION
# Sorts all images in the current directory into new subdirectories named after image dimeninsions. For example, all images of size 640x480 would be sorted into a folder named that, all images of size 1280x720 would be sorted into a folder named that, etc.

# DEPENDENCIES
#    printAllIMGfileNames.sh

# USAGE
# Run without any parameters:
#    allImagesToDimensionSubfolders.sh


# CODE

allImageFileNames=($(printAllIMGfileNames.sh))
imagesDimensionsArray=()
declare -A filenamesDimensions
for imageFileName in ${allImageFileNames[@]}
do
	# ex. command that gets image dimension format as NNNNxNNN:
	# identify -format "%[fx:w]x%[fx:h]" winamp_2017-09-03_11-14-36-32_s42-542500.png
	dimension=$(identify -format "%[fx:w]x%[fx:h]" $imageFileName)
	# add that to array of found dimensions:
	imagesDimensionsArray+=("$dimension")
	# also add it to an associative array by file name:
	filenamesDimensions[$imageFileName]=$dimension
	
done

# reduce array to unique elements as in sortUniq.sh, via variable/array piping <<<
# lines=($(<$1))
# Saved by a genius yonder: https://stackoverflow.com/a/11789688/1397555
OIFS="$IFS"
IFS=$'\n'
imagesDimensionsArray=($(sort <<<"${imagesDimensionsArray[*]}"))
imagesDimensionsArray=($(uniq <<<"${imagesDimensionsArray[*]}"))
IFS="$OIFS"

echo "CREATING SUBFOLDERS for image sort by dimension all in one go . . ."
for dimensions in ${imagesDimensionsArray[@]}
do
	if [ ! -d $dimensions ]
	then
		mkdir $dimensions
	fi
done

echo "SORTING FILES into subfolders by dimension . . ."
for imageFileName in ${allImageFileNames[@]}
do
	mv $imageFileName ${filenamesDimensions[$imageFileName]}/$imageFileName
done