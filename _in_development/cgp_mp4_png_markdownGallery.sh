# DESCRIPTION
# Creates a markdown listing of so many png image renders from so many cgp (color_growth.py preset) files of the same name, with accompanying .mp4 movie renders if applicable. Operates on all such files in the current path. Gallery file is README.md. WARNING: this will overwrite any other such file! The file may subsequently be rendered to HTML5 with video via ____ (this is planned)

# USAGE
# Invoke this script without any parameters:
# ./thisScript.sh


# CODE
gfind *.cgp > all_cgp.txt

printf "# Palettes\n\nClick any image to go to the source image; the text line above the image to go to the source .hexplt file.\n\n" > README.md

while read element
do
	hexpltName=${element::-5}
	printf "### [$hexpltName]($hexpltName.hexplt)\n\n" >> README.md
	printf "[ ![$element]($element) ]($element)\n\n" >> README.md
done < all_png.txt

printf "Created with [palettesMarkdownGallery.sh](https://github.com/earthbound19/_ebDev/blob/master/scripts/palettesMarkdownGallery.sh)." >> README.md

rm all_cgp.txt