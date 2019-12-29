# DESCRIPTION
# Creates a markdown image listing of all palette files (rendered from .hexplt source files) in the current path. Gallery file is README.md. WARNING: this will overwrite any other such file! DOUBLE WARNING: it will delete any (presumably erroneous) README.md if there are no .pngs in the directory you run this in!

# USAGE
# Invoke this script without any parameters: markdown gallery from; e.g.:
# ./thisScript.sh

# NOTES
# On Mac (at least) this script throws an error about test, and yet it still works as intended (the test causes a zero or nonzero return code).

# TO DO
# Remove search for many image types?


# CODE

# checking error code on find command thanks to a genius breath yon: https://serverfault.com/a/768042/121188
! test -z $(gfind . -maxdepth 1 -iname \*.png)
error_code=`echo $?`
# echo error_code is $error_code

# If no png files were found (if find threw an error), destroy any README.md gallery file and exit the script:
if (( error_code == "1" ))
then
	echo "--NO png files were found. DESTROYING README.md and will then exit script!";
	rm README.md; exit
else
	echo "--png files were found. Will create README.md gallery."
fi

# Otherwise, proceed with gallery creation:
printf "# Palettes\n\nClick any image to go to the source image; the text line above the image to go to the source .hexplt file.\n\n" > README.md

array=(`gfind . -maxdepth 1 -type f -iname \*.png -printf '%f\n'`)

for element in ${array[@]}
do
	hexpltName=${element%.*}
	printf "### [$hexpltName]($hexpltName.hexplt)\n\n" >> README.md
	printf "[ ![$element]($element) ]($element)\n\n" >> README.md
done

printf "Created with [palettesMarkdownGallery.sh](https://github.com/earthbound19/_ebDev/blob/master/scripts/palettesMarkdownGallery.sh)." >> README.md

echo DONE.