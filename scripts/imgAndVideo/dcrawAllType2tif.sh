# DESCRIPTION
# Calls dcraw2tif.sh for every file of type $1 (should be a camera raw format file) in the current directory, and optionally all subdirectories. NOTE: rawtherapeeAllType2type.sh (or Raw Therapee) is preferred over this, as it uses a patched newer version of dcraw (if not other/better things).

# USAGE
# Run with these parameters:
# - $1 extension of source files to convert to tiff
# - $2 OPTIONAL. Anything, for example the word FROBYARF, which will cause search and conversion to be done in all files of type $1 in all subdirectories under the current directory.
# Example that will convert all cr2 files in the current directory to tiff format files:
#    dcrawAllType2tif.sh cr2
# Example that will do the same for all cr2 files in the current directory and all subdirectories:
#    dcrawAllType2tif.sh cr2 FROBYARF


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (extension of source files to convert to tiff) passed to script. Exit."; exit 1; else inputFileType=$1; fi

# set default maxdepth parameter of this directory only; if parameter $2 passed, set it to '' (the default of any depth) :
maxdepthParameter="-maxdepth 1"
if [ "$2" ];then maxdepthParameter=''; fi

inputFiles=( $(find . $maxdepthParameter -type f -iname "*.$inputFileType" -printf "%P\n") )
for inputFile in ${inputFiles[@]}
do
	dcraw2tif.sh $inputFile
done
