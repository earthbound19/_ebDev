# DESCRIPTION
# Copies metadata from file $1 to $2, if possible, via exittool. Any metadata fields that already exist in the target are overwritten with metadata from the same tags in source. No backup of the target file is made; the change is permanent and, if there are errors, destructive.

# DEPENDENCIES
# exiftool, a nixy/bash environment to run this script (e.g. MSYS2 on Windows)

# USAGE
# Run with these parameters:
# - $1 file name of source file to copy metadata from
# - $2 file name of target file to copy metadata to
# - $3 OPTIONAL. Anything, such as the word FNEORN, which will cause the script to update the target file timestamp to the media creation date, if found, from metadata.
# Example that will copy metadata fom file source.mov to target.mp4:
#    copyMetadataFromSourceFileToTarget.sh source.mov target.mp4 
# Example that will do the same but also update the time stamp of target.mp4 to the media creation date and time from metadata:
#    copyMetadataFromSourceFileToTarget.sh source.mov target.mp4 FNEORN


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of source file to copy metadata from) passed to script. Exit."; exit 1; else sourceFileName=$1; fi

if [ ! "$2" ]; then printf "\nNo parameter \$2 (file name of target file to copy metadata to) passed to script. Exit."; exit 2; else targetFileName=$2; fi

if [ ! -f $sourceFileName ]; then echo "ERROR: source file $sourceFileName not found."; exit 3; fi

if [ ! -f $targetFileName ]; then echo "ERROR: target file $targetFileName not found."; exit 4; fi

# print file name of this script for information when it is invoked from other scripts:
echo "${0##*/} : copying metadata from source file $sourceFileName to target file $targetFileName . . ."
exiftool -overwrite_original -TagsFromFile $sourceFileName $targetFileName

# OPTIONAL via anything for paratmer $3: Update time stamp of target file to metadata creation date; uses a conditional like is given in this post: https://exiftool.org/forum/index.php?topic=6519.msg32511#msg32511 -- but adding an -else clause:
if [ "$3" ];
then
	echo "${0##*/} : attempting to modify file time stamp to match any creation date metadata, for file $targetFileName . . ."
	exiftool -if "defined $CreateDate" -v -overwrite_original '-FileModifyDate<CreateDate' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" -else -v -overwrite_original '-FileModifyDate<DateTimeOriginal' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" $targetFileName
fi