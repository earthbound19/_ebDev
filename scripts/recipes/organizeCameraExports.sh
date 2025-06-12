# DESCRIPTION
# Organizes exported media files (e.g. from cameras and devices), using other scripts, this way:
#    - renames various common camera/device media file extensions to lowercase
#    - renames files after metadata date
#    - renames all .jpeg file extensions to .jpg (including doing this after optional thumbnail extraction, where dcraw extracts thumbnails as .jpeg files)
# For the following optional features, search for comments with "uncomment" instructions:
#    - extracts embedded thumbnails from cr2 raw files. (Performs the rename of .jpeg files .jpg after this.)
#    - losslessly copies all video files to mp4 containers, with metadata and timestamps copied from the original.
#    - moves all relevant data into subfolders named by type.

# DEPENDENCIES
# Various scripts. See throughout the code.

# USAGE
# From a folder with such files to organize (and no other files!), run without any parameters:
#    organizeCameraExports.sh
# TEMPORARILY DEPRECATED and this script hacked to skip it: sidecar scanning and renaming (as follows), owing to this bug: in some setting (or all settings?) renamed files in a subfolder are not being matched to sidecards etc. nor sidecars renamed.
# To skip sidecar etc. scanning for renameByMetadata.sh, pass a parameter $1 to the script, which can be anything, e.g.:
#    organizeCameraExports.sh NORTHERP
# See the various comments with "uncomment" instructions for the optional features.

# CODE
# TO DO
# - FIX BUG detailed above in TEMPORARILY DEPRECATED comment
# - parameterize optional features?

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
# Do the actual rename; this passes $1, which if it was passed to the script will be any string or whatever, and if not, it will be empty; that flag and the word NORTHERP control things in renameByMetadata.sh (see documentation in it) :
# TO DO: fix the issue mentioned above under the TEMPORARILY DEPRECATED comment (I think the issue is that renamed files are moved away from the same directory as the would-be sidecar matches to find), then uncomment the next line and delete the one after it:
# renameByMetadata.sh NORTHERP $1
renameByMetadata.sh NORTHERP SKIP_SIDECAR_CHECKING
# Move those up a folder, move back to that folder, and destroy the temp folder:
mv -i * ..
cd ..
rm -rf tmp_renames_2ydTVzqG

# TO EXTRACT EMBEDDED THUMBNAILS FROM ALL .cr2 FILES in the current directory, uncomment the next line:
# getEmbeddedThumbsDCRAW.sh cr2

# re https://stackoverflow.com/a/45703829, rename all .jpeg to .jpg:
for x in *.jpeg; do mv -i "$x" "${x%.jpeg}.jpg"; done

# LOSSLESSLY RECONTAIN ALL .mov FILES TO .mp4, and copy metadata and timestamp from the original to the target mp4; uncomment the next line:
# allVideo2VideoLossless.sh

# MOVE ALL FILES OF GIVEN EXTENSIONS (that this script operates on) INTO SUBFOLDERS; uncomment the next four lines of code:
# for lowerCaseExt in ${lowerCaseExtensions[@]}
# do
	# toTypeFolder.sh $lowerCaseExt
# done

echo "DONE."