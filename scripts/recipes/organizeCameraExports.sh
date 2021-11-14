# DESCRIPTION
# Organizes CR2 and MOV format camera exports this way, using other scripts:
#    - lowercases MOV and CR2 extensions to lowercase
#    - renames files after metadata date
#    - extracts preview thumbnails
#    - sorts all these file types into subfolders by type

# DEPENDENCIES
# Various scripts. See the flat list of those called after CODE.

# USAGE
# From a folder with such files to organize (and no other files!), run without any parameters:
# - organizeCameraExports.sh


# CODE
toLowercaseExtensions.sh MOV
toLowercaseExtensions.sh CR2
mkdir tmp_renames_2ydTVzqG
# Because (at this writing) renameByMetadata.sh doesn't operate selectively on file types, move the types we want to operate on into their own folder (to exclude other types from the operation) :
mv *.mov ./tmp_renames_2ydTVzqG/
mv *.cr2 ./tmp_renames_2ydTVzqG/
cd tmp_renames_2ydTVzqG/
# Do the actual rename:
renameByMetadata.sh
# Move those up a folder, move back to that folder, and destroy the temp folder:
mv * ..
cd ..
rm -rf tmp_renames_2ydTVzqG
# Extract thumbs:
dcraw -e *.cr2
# Thanks to a genius breath yon https://stackoverflow.com/a/45703829 ;
# rename all .thumb.jpg files to just .jpg:
for x in *.thumb.jpg; do mv "$x" "${x%.thumb.jpg}.jpg"; done
toTypeFolder.sh mov
toTypeFolder.sh cr2
toTypeFolder.sh jpg
