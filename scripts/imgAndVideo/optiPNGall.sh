# DESCRIPTION
# Recursively optimizes all pngs in the current directory and subdirectories,
# via pngquant and optpng, preserving full fidelity of original pixels.

# USAGE
# optiPNGall.sh


# CODE
pngsFileNamesArray=(`find . -type f -name "*.png"`)

for element in ${pngsFileNamesArray[@]}
do
	pngquant --skip-if-larger --ext=.png --force --quality 100 --speed 1 --nofs --strip --verbose $element
	optipng -o7 $element
done