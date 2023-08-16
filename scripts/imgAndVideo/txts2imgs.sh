# DESCRIPTION
# Via ImageMagick, generates image renders of the text contents of all .txt files in the path from which this script is run, with the images named after the source text file names. Dimensions, font point size, and font are customizable via parameters; if not provided, defaults are used. Will not clobber render targets that already exist.

# DEPENDENCIES
# - `ImageMagick`
# - `getFullPathToFile.sh`
# - If you use a custom font, it must be either in the current directory or in your PATH.

# USAGE
# With this script in your PATH, run it with these parameters:
# - $1 OPTIONAL. Dimensions of image in format NNxNN. If not provided, a default is used. To use $2 and/or $3 and use the default for this, pass the word DEFAULT for $1.
# - $2 OPTIONAL. Point size to render font at. If not provided, a default is used. To use $3 and use the default for this, pass the word DEFAULT for $2.
# - $3 OPTIONAL. Font to use. Must be either in the directory you run this script from or in your PATH. If not provided, a default will be searched for, and used if found; otherwise imagemagick's default will be used. If provided but not found by the script, script will exit with an error message.
# To use defaults, run the script without any parameter:
#    texts2imgs.sh
# Example that will produce a 1920x1080 image with font point size 120, using NotoSerif-Regular.ttf:
#    texts2imgs.sh 1920x1080 120 NotoSerif-Regular.ttf


# CODE
if [ ! "$1" ] || [ "$1" == "DEFAULT" ]; then sizeParameter="1920x1920"; else sizeParameter=$1; fi
if [ ! "$2" ] || [ "$2" == "DEFAULT" ]; then pointSizeParameter=72; else pointSizeParameter=$2; fi

if [ "$3" ]
then
	fontFileName=$3
	fullPathToFontFile=$(getFullPathToFile.sh $fontFileName)
else
	fontFileName="NotoSerif-Regular.ttf"
	fullPathToFontFile=$(getFullPathToFile.sh $fontFileName)
fi
if [ "$3" ] && [ "$fullPathToFontFile" == "" ]
then
	printf "\n~\nPROBLEM: Font file $fontFileName not found in current directory or anywhere in PATH. Change things so that either is the case, then run the script again, or don't pass a font file name variable to the script. Will exit script."; exit 1
fi
if [ "$fullPathToFontFile" != "" ]
then
	echo "Font file $fontFileName found at $fullPathToFontFile. Will use."
	magickFontSwith="-font $fullPathToFontFile"
fi
# reference pseudocode that can be commented out and be effectively the same, for this case:
# if [ ! "$3" ] && [ "$fullPathToFontFile" == "" ]
# then
	# magickFontSwith=
# fi

fileNamesArray=( $(find . -maxdepth 1 -type f -iname \*.txt -printf '%f\n') )
for fileName in ${fileNamesArray[@]}
do
	# make image for each poem, if it doesn't already exist:
	fileNameNoExt=${fileName%.*}
	renderTargetFileName="$fileNameNoExt".png
	if [ ! -e "$renderTargetFileName" ]
	then
		printString=$(cat $fileName)
# image render command on lines connected by  \:
magick convert -background white -size $sizeParameter \
-gravity Center \
-pointsize $pointSizeParameter \
$magickFontSwith \
caption:"$printString" \
$renderTargetFileName
	else
		echo "Render target $renderTargetFileName already exists; will not clobber."
	fi
done