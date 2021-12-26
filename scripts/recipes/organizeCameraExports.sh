# DESCRIPTION
# Organizes exported media files (e.g. from cameras and devices) this way, using other scripts:
#    - renames various common camera/device media file extensions to lowercase
#    - renames files after metadata date
#    - extracts preview thumbnails from CR2s
#    - renames all .jpeg file extensions to .jpg
#    - sorts all these file types into subfolders by type

# DEPENDENCIES
# Various scripts. See the flat list of those called after CODE.

# USAGE
# From a folder with such files to organize (and no other files!), run without any parameters:
#    organizeCameraExports.sh


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
# Extract thumbs:
dcraw -e *.cr2
# Thanks to a genius breath yon https://stackoverflow.com/a/45703829 ;
# rename all .thumb.jpg files to just .jpg:
for x in *.thumb.jpg; do mv -i "$x" "${x%.thumb.jpg}.jpg"; done
# rename all .jpeg to .jpg:
for x in *.jpeg; do mv -i "$x" "${x%.jpeg}.jpg"; done
# OPTIONAL: uncomment if you want to lossleslly recontain all .mov files to .mp4 -- but be warned that this will lose metadata if you destroy the original mov files (metadata is not copied)! :
# allVideo2mp4Lossless.sh

for lowerCaseExt in ${lowerCaseExtensions[@]}
do
	toTypeFolder.sh $lowerCaseExt
done

echo "DONE."