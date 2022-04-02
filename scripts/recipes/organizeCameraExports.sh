# DESCRIPTION
# Organizes exported media files (e.g. from cameras and devices) this way, using other scripts:
#    - renames various common camera/device media file extensions to lowercase
#    - renames files after metadata date
#    - extracts preview thumbnails from CR2s
#    - renames all .jpeg file extensions to .jpg
#    - sorts all these file types into subfolders by type
#    - optionally losslessly copies all video files to mp4 containers, with metadata and timestamps copied from the original
#    - optionally move all relevant data into subfolders named by type; see the comment labeled UNCOMMENT for that.

# DEPENDENCIES
# Various scripts. See throughout the code.

# USAGE
# From a folder with such files to organize (and no other files!), run without any parameters:
#    organizeCameraExports.sh
# Or optionally, run with any word for parameter $1 to losslessly convert many video formats to mp4, and copy metadata and timestamps to the converted target; for example:
#    organizeCameraExports.sh BYORF


# CODE
# ADD AN EXTENSION to this list if you need it operated on with this script:
extensions=(
MOV
CR2
JPG
JPEG
PNG
HEIC
MP4
GIF
M4A
3GP
)

lowerCaseExtensions=()
# lowercase the extension on all file types in list;
# build a lowercase extensions array at the same time:
for ext in ${extensions[@]}
do
	toLowercaseExtensions.sh $ext
	lowerCasedFileExt=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
	lowerCaseExtensions+=($lowerCasedFileExt)
done

mkdir tmp_renames_2ydTVzqG
# Because (at this writing) renameByMetadata.sh doesn't operate selectively on file types, move the types we want to operate on into their own folder (to exclude other types from the operation) :
for lowerCaseExt in ${lowerCaseExtensions[@]}
do
	mv *."$lowerCaseExt" ./tmp_renames_2ydTVzqG/
done

cd tmp_renames_2ydTVzqG/
# Do the actual rename:
renameByMetadata.sh NORTHERP
# Move those up a folder, move back to that folder, and destroy the temp folder:
mv -i * ..
cd ..
rm -rf tmp_renames_2ydTVzqG

getEmbeddedThumbsDCRAW.sh cr2

# re https://stackoverflow.com/a/45703829, rename all .jpeg to .jpg:
for x in *.jpeg; do mv -i "$x" "${x%.jpeg}.jpg"; done

# OPTIONALLY lossleslly recontain all .mov files to .mp4, and copy metadata and timestamp from the original to the target mp4:
if [ "$1" ]
then
	allVideo2mp4Lossless.sh
fi

# OPTIONAL: move all file types into subfolders named after that file type; uncomment the next four lines of code:
# for lowerCaseExt in ${lowerCaseExtensions[@]}
# do
	# toTypeFolder.sh $lowerCaseExt
# done

echo "DONE."