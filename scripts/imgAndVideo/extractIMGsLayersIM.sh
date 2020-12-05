# DESCRIPTION
# Calls `extractIMGlayersIM.sh` repeatedly for every file of type $1 (for example psd) in the current directory, and optionally subdirectories. Passes $1 as the first parameter to that script for each call.

# USAGE
# Run with these parameters:
# - $1 file type, or extension (without a dot in it, for example psd) to search for in the current directory. Every file of that type found will be used in a call of `extractIMGlayersIM.sh` with that file name as the parameter to that script. See that script's documentation for details
# - $2 OPTIONAL. May be anything, for example the word FLOREFLEFL. If present, all subdirectories will be searched for files of type $1. If not present, only the current directory will be searched.
# Example command that will call `extractIMGlayersIM.sh` once with every psd (Photoshop format) file in the current directory:
#    extractIMGsLayersIM.sh psd
# Example command that will do the same but for all psd files in the current directory and subdirectories also:
#    extractIMGsLayersIM.sh psd FLOREFLEFL

# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source format, e.g. psd or tiff) passed to script. Exit."; exit 1; else sourceFormat=$1; fi

subDirSearchParam='-maxdepth 1'
if [ "$2" ]; then subDirSearchParam=''; fi

files=( $(find . $subDirSearchParam -type f -name "*.$sourceFormat" -printf "%P\n") )
for file in ${files[@]}
do
	extractIMGlayersIM.sh $file
done

printf "DONE running extractIMGlayersIM.sh for all files of type $sourceFormat\nin the current directory"
if [ "$subDirSearchParam" == '' ]
then
	printf ", and also subdirectories.\n"
else
	printf ".\n"
fi
