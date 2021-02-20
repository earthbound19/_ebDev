# DESCRIPTION
# Via ImageMagick, generates image renders of the text contents of all .txt files in the path from which this script is run, with the images named after the source text file names. Dimensions, font point size, and font are customizable via parameters; if not provided, defaults are used. Will not clobber render targets that already exist.

# DEPENDENCIES
# - `ImageMagick`
# - `getFullPathToFile.sh`
# - If you use a custom font, it must be either in the current directory or in your PATH.

# USAGE
# With this script in your PATH, run it with these parameters:
# - $1 OPTIONAL. Dimensions of image in format NNxNN. If not provided, a default is used.
# - $2 OPTIONAL. Point size to render font at. If not provided, a default is used.
# - $3 OPTIONAL. Font to use. Must be either in the directory you run this script from or in your PATH. If not provided, imagemagick's default will be used. If provided but not found by script, script will exit with an error message.
# To use defaults, run the script without any parameter:
#    texts2imgs.sh
# Example that will produce a 1920x1080 image with font point size 120, using NotoSerif-Regular.ttf:
#    texts2imgs.sh 1920x1080 120 NotoSerif-Regular.ttf


# CODE
if [ ! "$1" ]; then sizeParameter="1920x1920"; else sizeParameter=$1; fi
if [ ! "$2" ]; then pointSizeParameter=72; else pointSizeParameter=$2; fi

# Build variable that is full path to font file name assigned to $fontFileName (from $3); if can't find font (and build variable), error out:
fullPathToFontFile=""
if [ "$3" ]
then
	fontFileName=$3
	# fixed vs. ls command, which "finds" a font file if you give everything correctly and then add characters after the name (not correct! -- find command does exact search! ) :
	fullPathToFontFile=$(find . -maxdepth 1 -name $fontFileName -printf "%P")
	# if result of that is not blank, the following check will fail and the variable will be left as we want it (non-blank, having found the file, in the current directory).
	if [ "$fullPathToFontFile" == "" ]
	# but if it is blank, the search failed (and this check for a blank result will succeed), and we should search the PATH for it:
	then
		fullPathToFontFile=$(getFullPathToFile.sh $fontFileName)
		# if it was found by THAT script, now it will be a non-empty string, and we can leave that variable as is and use it.
		if [ "$fullPathToFontFile" == "" ]
		# But if it was also not found by that check; if it is an empty string, we did not find the file in the PATH either, and we should error out:
		then
			printf "\n~\nPROBLEM: Font file $fontFileName not found in current directory or anywhere in PATH. Change things so that either is the case, then run the script again, or don't pass a font file name variable to the script. Will exit script."; exit 1
		fi
	fi
echo "Font file $fontFileName found at $fullPathToFontFile."
fontParameter="-font '$fullPathToFontFile'";
echo "fontParameter is $fontParameter"
fi

fileNamesArray=( $(find . -maxdepth 1 -type f -iname \*.txt -printf '%f\n') )
for fileName in ${fileNamesArray[@]}
do
	# make image for each poem, if it doesn't already exist:
	fileNameNoExt=${fileName%.*}
	renderTargetFileName="$fileNameNoExt".png
	if [ ! -e "$renderTargetFileName" ]
	then
		cp $fileName tmp_txts2imgs_hZE9WjFeS.txt
		dos2unix tmp_txts2imgs_hZE9WjFeS.txt
		# IFS='\n'
		printString=$(cat tmp_txts2imgs_hZE9WjFeS.txt)
# print everyting to a temp script file and then execute the script, because something goes on otherwise with variables not working and the only solution I know is this workaround:
printf "magick convert -background white -size $sizeParameter \
-gravity Center \
-pointsize $pointSizeParameter \
$fontParameter \
caption:'$printString' \
$renderTargetFileName" > txts2imgs_tmp_script__KX9CPaFdB.sh
	./txts2imgs_tmp_script__KX9CPaFdB.sh
	else
		echo "Render target $renderTargetFileName already exists; will not clobber."
	fi
done

# cleanup temp files if we created them (if they exist) :
if [ -e tmp_txts2imgs_hZE9WjFeS.txt ]; then rm tmp_txts2imgs_hZE9WjFeS.txt; fi
if [ -e txts2imgs_tmp_script__KX9CPaFdB.sh ]; then rm txts2imgs_tmp_script__KX9CPaFdB.sh; fi
