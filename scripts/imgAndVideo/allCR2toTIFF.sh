# DESCRIPTION
# Calls dcraw2tif.sh for every raw file of type $1 in the current directory, thereby making .tif format conversions of them.

# USAGE
# Run with these parameters:
# - $1 raw format file extension to operate on, without any dot, e.g. 'cr2'
# Example that will convert all cr2 format files in the current directory to tiff format images:
#    allRAWtoTIFF.sh cr2
# NOTES
# Search for extension is case-insensitive; if you specify CRW for $1 it will find crw (lowercase extension files) and visa-versa.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (raw format file extension to operate on) passed to script. Exit."; exit 1; else sourceFormat=$1; fi

allFilesType=( $(find . -maxdepth 1 -iname "*.$sourceFormat" -printf "%P\n") )
for element in ${allFilesType[@]}
do
	dcraw2tif.sh $element
done