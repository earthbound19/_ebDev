# DESCRIPTION
# Creates a markdown image listing of all palette files (rendered from .hexplt source files) in the current path. Gallery file is README.md. WARNING: this will overwrite any other such file!

# USAGE
# Invoke this script without any parameters: markdown gallery from; e.g.:
# ./thisScript.sh

# TO DO
# Remove parameter $1 and replace it with a built-in listing of many image types.


# CODE
gfind *.png > all_png.txt

printf "# Palettes\n\nClick any image to go to the source image; the text line above the image to go to the source .hexplt file.\n\n" > README.md

while read element
do
	echo current image is\: $element
	hexpltName=${element::-5}
	printf "### [$hexpltName]($hexpltName)\n\n" >> README.md
	printf "[ ![$element]($element) ]($element)\n\n" >> README.md
	# printf "bruh\n\n" >> README.md
done < all_png.txt

rm all_png.txt