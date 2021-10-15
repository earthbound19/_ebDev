# DESCRIPTION
# Creates a markdown image listing (README.md) of all .png format palette files (rendered from .hexplt source files) in the current path.

# WARNINGS
# - This will overwrite a palette README.md file that already exists.
# - It will also delete a README.md if there are no .pngs in the directory you run this in.

# USAGE
# Run this script without any parameters:
#    palettesMarkdownGallery.sh
# NOTE
# On Mac (at least) this script throws an error about test, and yet it still works as intended (the test causes a zero or nonzero return code).


# CODE
array=($(find . -maxdepth 1 -type f -iname \*.png -printf '%f\n' | tr -d '\15\32' | sort -n))
array_length=${#array[@]}

# If no png files were found (if find threw an error), destroy any README.md gallery file and exit the script:
if (( array_length == "0" ))
then
	echo "--no png files were found. Destroying any README.md and will then exit script!";
	if [ -e README.md ]
	then
		echo "--> README.md found. Will delete."
		rm README.md
	else
		echo "--> No README.md found."
	fi
	exit
else
	echo "--png files were found. Will create README.md gallery."
fi

# Otherwise, proceed with gallery creation:
printf "# Palettes\n\nClick any image to go to the source image; the text line above the image to go to the source .hexplt file.\n\n" > README.md

for element in ${array[@]}
do
	hexpltName=${element%.*}
	# NOTE the escaped backticks: they are to create preformatted text formatting around the palette name, in cases where underscore pairs in palette names are erroneously interpreted as italic markdown by some renderers:
	printf "### [\`$hexpltName\`]($hexpltName.hexplt)\n\n" >> README.md
	printf "[ ![$element]($element) ]($element)\n\n" >> README.md
done

printf "Created with [palettesMarkdownGallery.sh](https://github.com/earthbound19/_ebDev/blob/master/scripts/palettesMarkdownGallery.sh)." >> README.md

echo DONE.