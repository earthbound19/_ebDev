# DESCRIPTION
# Creates a markdown listing of so many png image renders from so many cgp (color_growth.py preset) files of the same name, with accompanying .mp4 movie renders if applicable. Operates on all such files in the current path. The output gallery file name is README.md. WARNING: if that file already exists in the current directory, it will overwrite it!

# USAGE
# Invoke this script without any parameters:
#  cgp_mp4_png_markdownGallery.sh

# TO DO Subsequently render the video to HTML5 with video via ____ (this is planned). [EDIT: via what?]


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