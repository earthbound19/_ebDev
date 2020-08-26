# DESCRIPTION
# Renders a phrase to an image using every font file found in the current directory, with a caption that gives the font name. Useful for logo/font prototyping. Caption, point size, and image width are customizable via parameters; see USAGE. The render png is named after the source font file. Will not render to target file name that already exists.

# DEPENDENCIES
# ImageMagick and a directory full of `.ttf` and/or `.otf` fonts you wish to render a phrase from.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. The string to render font previews from, surrounded in either single or double quotes. (If you want double quotes in this string, surround the whole phrase with single quotes, like this: '"QUOTE MARKS SURROUND OUR SLOGAN!"'. If you want single quotes or apostraphes, surround everything in double quotes. If you want both, you may need to escape the innermost single or double quote with \.) If not provided, the script generates a new string of randomly chosen printable characters for every font preview render image. If you wish to generate a random string but also use the additional optional parameters, pass this as "RANDOM".
# - $2 OPTIONAL. The width of the font preview image, in pixels. If not provided, a default is used.
# - $3 OPTIONAL. The point size to render the font previews in. If not provided, defaults to a percent of the image width.
# Example that will render the phrase "COLOR GROWTH color growth" for every font file in the current directory:
#     previewFonts.sh "COLOR GROWTH"
# Example that will do the same but make every preview 650 px wide:
#     previewFonts.sh "COLOR GROWTH" 65
# Example that will do the same but make the point size 16:
#     previewFonts.sh 65
# NOTES
# - If you include a newline character code sequence in the string (backslash-n, or `\n`), ImageMagick (which this script uses to render fonts) will insert a line break where you type that.
# - On Windows, IrfanView's thumbnail mode can preview many font files quickly.
# - There are also many font manager and preview softwares which may do better than this.


# CODE
# modifies global string:
set_rndSTR () {
	renderSTR=$(cat /dev/urandom | tr -dc "a-zA-Z0-9'@=~!#$%^&()+[{]};. ,-" | fold -w 20 | head -n 1)
}

if [ "$1" ] && [ "$1" != "RANDOM" ]; then renderSTR=$1; else useRNDstrEachRender="True"; set_rndSTR; fi
if [ "$2" ]; then imgWidth=$2; else imgWidth=1240; fi
if [ "$3" ];
then
	pointSize=$3
else
	pointSize=$(echo "scale=0; x = $imgWidth * 0.085; x / 1" | bc)
fi

# CODE
allFontsFilesHere=$(find . -maxdepth 1 -iname \*.ttf -printf "%P\n" -o -iname \*.otf -printf "%P\n" -o -iname \*.FON -printf "%P\n")

for fontFileName in ${allFontsFilesHere[@]}
do
	fontFileNameNoExt=${fontFileName%.*}
	renderTarget=$fontFileNameNoExt.png
	echo -~-~
	if [ ! -e $renderTarget ]
	then
		# Render typeface declaration
		# make renderSTR point X percent of font point size; float to int re genius breaths yon: https://stackoverflow.com/questions/20558710/bc-truncate-floating-point-number
		typeFaceInfoStringPointSize=$(echo "scale=0; x = $pointSize * 0.15; x / 1" | bc)
		# set that to minimum allowed if its below it:
		if [ $typeFaceInfoStringPointSize -lt 16 ]; then typeFaceInfoStringPointSize=19; fi
		if [ "$useRNDstrEachRender" == "True" ]; then set_rndSTR; fi
		magick convert -background white -fill black -pointsize $typeFaceInfoStringPointSize -size $imgWidth caption:"Font file: $fontFileName" tmpIMG1_fjinm732nCz.png 2>/dev/null
		# Render renderSTR
		echo Rendering string \"$renderSTR\" from \'$fontFileName\' . . .
		magick convert -background white -fill black -font $fontFileName -pointsize $pointSize -size $imgWidth caption:"$renderSTR" tmpIMG2_fjinm732nCz.png 2>/dev/null
		# Composite them and save the result to an image named after the font, in the ./fontRenders subdir
		magick tmpIMG2_fjinm732nCz.png tmpIMG1_fjinm732nCz.png -background lightgrey -gravity Southwest -append $renderTarget 2>/dev/null
	else
		echo Render target \'$renderTarget\' already exists. Will skip this render. To re-render it, delete the existing render target file.
	fi
done

# remove temp files if they exist (if we created them) :
if [ -e tmpIMG1_fjinm732nCz.png ]; then rm tmpIMG1_fjinm732nCz.png; fi
if [ -e tmpIMG2_fjinm732nCz.png ]; then rm tmpIMG2_fjinm732nCz.png; fi