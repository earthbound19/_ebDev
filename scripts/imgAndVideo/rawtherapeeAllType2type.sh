# DESCRIPTION
# Calls `rawtherapee2type.sh` for every file of type $1 (should be a camera raw format file) in the current directory, converting to either png or tif ($2) and optionally doing the same through all subdirectories (anything for $3).

# USAGE
# Run with these parameters:
# - $1 extension of source files to convert, for example cr2
# - $2 OPTIONAL. Format (and therefore extension) to convert to. Options are png or tif. If omitted defaults to png.
# - $3 OPTIONAL. Adjustments parameter file (pp3 format) to use for processing. See parameter $3 documentation in `rawtherapee2type.sh`. If you want to use $4 (read on) but not $3, pass the word NULL for $3.
# - $4 OPTIONAL. Anything, for example the word FROBYARF, which will cause search and conversion to be done in all files of type $1 in all subdirectories under the current directory.
# Example that will convert all cr2 files in the current directory to tiff format files:
#    rawtherapeeAllType2type.sh cr2
# Example that will do the same for all cr2 files in the current directory and convert them to tif:
#    rawtherapeeAllType2type.sh cr2 tif
# Example that will convert all cr2 images to pngs in the current directory and all subdirectories:
#    rawtherapeeAllType2type.sh cr2 png FROBYARF


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (extension of source files to convert to tiff) passed to script. Exit."; exit 1; else inputFileType=$1; fi

if [ "$2" == 'tif' ] || [ "$2" == 'tiff' ]
then
	outputFormatParameter=tif
else
	outputFormatParameter=png
fi

if [ "$3" ] && [ "$3" != "NULL" ]; then sidecarFileName=$3; fi

# set default maxdepth parameter of this directory only; if parameter $2 passed, set it to '' (the default of any depth) :
maxdepthParameter="-maxdepth 1"
if [ "$4" ];then maxdepthParameter=''; fi

inputFiles=( $(find . $maxdepthParameter -type f -iname "*.$inputFileType" -printf "%P\n") )
for inputFile in ${inputFiles[@]}
do
	rawtherapee2type.sh $inputFile $outputFormatParameter $sidecarFileName
done
