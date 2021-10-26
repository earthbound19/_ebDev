# DESCRIPTION
# Recursively optimizes all pngs in the current directory and subdirectories, via optpng, preserving full fidelity of original pixels. See NOTE for pngquant option.

# USAGE
#    optiPNGall.sh
# NOTE To additionally use pngquant but lose color fidelity in the process, uncomment the line in the for loop which begins with pngquant.


# CODE
pngsFileNamesArray=( $(find . -type f -name "*.png") )
# NOTE

for element in ${pngsFileNamesArray[@]}
do
	# pngquant --skip-if-larger --ext=.png --force --quality 100 --speed 1 --nofs --strip --verbose $element
	optipng -o7 $element
done