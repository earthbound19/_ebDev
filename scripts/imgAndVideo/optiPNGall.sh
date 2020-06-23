# DESCRIPTION
# Recursively optimizes all pngs in the current directory and subdirectories,
# via optpng.

# USAGE
# optiPNGall.sh


# CODE
pngsFileNamesArray=(`gfind . -type f -name "*.png"`)

for element in ${pngsFileNamesArray[@]}
do
	optipng -o7 $element
done