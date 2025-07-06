# DESCRIPTION
# Produces list of images in the current directory arranged by file modified date, oldest first. (NOTE that may not correspond to create date on Windowes). List is intended as a source list for ffmpeg (to create an animation).

# USAGE
# Run with these parameters:
# - $1 REQUIRED. File format (e.g. 'png') to list.
# For example, to make a list file for all png images in the current directory, run:
#    imgsByDateListForFFMPEG.sh 'png'
# (you may also just pass png without surrounding quote marks)
# NOTES
# Output file is named ffmpegIMGlist.txt. This is so that tools designed to use that file can use it without retooling.


# CODE
if [ -f ffmpegIMGlist.txt ]; then echo "NOTE: information target file ffmpegIMGlist.txt already exists. To recreate it, rename or delete it and run this script again. Exit."; exit 1; fi

allIMGs=()
if [ ! "$1" ]
then
	echo "ERROR: no source image format (e.g. 'png') passed for \$1. Exit."; exit 2
else
	srcImageType=$1
fi

	# simpler example dev reference command:
	# allIMGs=( $(find . -maxdepth 1 -type f -iname "*.$srcImageType" -printf '%f\n') )
# sorts by file date (oldest first); re: https://superuser.com/a/546900/130772
allIMGs=( $(find . -maxdepth 1 -type f -iname "*.$srcImageType" -printf "%T@ %Tc %p\n" | sort -n | sed 's/.* \.\///g') )

# check if array is empty; if it was we know there were no such files found, so print error and exit:
if [ "${#allIMGs[@]}" == 0 ]
then
	echo "ERROR: resulting array size from searching for image type $srcImageType is zero; no images of that type found in this directory. Exit."; exit 3
fi

# blank / create new ffmpegIMGlist.txt:
printf "" > ffmpegIMGlist.txt

for imageFileName in ${allIMGs[@]}
do
	printf "file '$imageFileName'\n" >> ffmpegIMGlist.txt
done

echo ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
echo "FINIS! Results are in ffmpegIMGlist.txt. Scripts which may process these result lists: mkNumberedCopiesFromFileList.sh, ffmpegCrossfadeIMGsToVideoFromFileList.sh, ffmpegAnimFromFileList.sh, and maybe others."