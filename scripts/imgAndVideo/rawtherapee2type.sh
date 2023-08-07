# DESCRIPTION
# Converts (almost?) any camera raw format image file into a more widely supported raster image format (default .png) file via rawtherapee-cli. Uses an existing sidecar if present, and default processing options in RawTherapee's setting under Preferences > Image Processing > Default Processing Profile". See NOTES for a command to quickly extract any embedded thumbnails.

# DEPENDENCIES
#    rawtherapee-cli installed (it comes with rawtherapee) and in your PATH

# USAGE
# Run with these parameters:
# - $1 REQUIRED. A raw image filename in your PATH. e.g. 2023_07_29__08_43_59_T5i.cr2, for example, to convert a source file 2023_07_29__08_43_59_T5i.cr2 to default png output format:
#    rawtherapee2type.sh 2023_07_29__08_43_59_T5i.cr2
# - $2 OPTIONAL. Output file type [tif|png]. Defaults to png if omitted or specified as anything other than tif or tiff. (But output tif output files are just .tif even if you pass tiff.) For example to convert to tif:
# - $3 OPTIONAL. Adjustments parameter file (pp3 format) to use for processing. Must be a file in the same directory as the image to be processed (or perhaps not, maybe a relative path to it will work). Note that this will be used in addition to the default processing set in rawtherapee's UI in Preferences > Image Processing > Default Processing Profile. If you don't want to use the default processing, hack this script to remove the -d switch from the rawtherapee call. (Default processing is used in all conversions regardless of whether you pass $3.). If you use $3 you must also use $2.
#    rawtherapee2type.sh 2023_07_29__08_43_59_T5i.cr2 tif
# NOTES
# To quickly rip the embedded jpegs (if there be any) out of all images, don't even use this script, use dcraw:
#    dcraw -e *.CR2


# CODE
# START PARAMETER CHECKING AND resultant switch setting.
if [ "$1" ]; then inputFile=$1; else printf "\nNo parameter \$1 (input file name) passed to script. Exit."; exit 1; fi

fileNameNoExt="${inputFile%.*}"

if [ "$2" == 'tif' ] || [ "$2" == 'tiff' ]
then
	outputFormatSwitch='-tz'
	targetFileName=$fileNameNoExt.tif
else
	outputFormatSwitch='-n'
	targetFileName=$fileNameNoExt.png
fi

if [ "$3" ]
then
	processingFileParameter="-p $3"
fi
# END PARAMETER CHECKING AND resultant switch setting.

if [ ! -f $targetFileName ]
then
  echo Target file $targetFileName does not exist. Will render.
  # CLI options re: https://rawpedia.rawtherapee.com/Command-Line_Options :
  # rawtherapee-cli [-o <output>|-O <output>] [-q] [-a] [-s|-S] [-p <files>] [-d] [-j[1-100] [-js<1-3>]|[-b<8|16>] <[-t[z] | [-n]]] [-Y] [-f] -c <input>
  # -p is to specify a processing sidecar/option file (format .pp3)
  # if a format is specified in a command line switch, but no output file name given, it names the output file after the base name of the source and then appends an extension matching the output format; but I'll specify the output file name anyway (shrug) :
  rawtherapee-cli -o $targetFileName -q -s $processingFileParameter -d -b16 $outputFormatSwitch -c $inputFile
else
  echo Target file $targetFileName already exists. Will not overwrite.
fi