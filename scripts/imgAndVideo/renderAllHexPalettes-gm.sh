# DESCRIPTION
# Runs renderHexPalette-gm.sh for every .hexplt file in the path (non-recursive) from which this script is run. Result: all hex palette files in the current path are rendered. Also optionally recurses into subdirectories. See USAGE.

# USAGE
# To render all palettes in the current directory, run the script without any argument:
#    renderAllHexPalettes-gm.sh
# To recurse into all subdirectories and render all palettes in them, pass any parameter for $1:
#    renderAllHexPalettes-gm.sh YORP
# To pass additional parameters, examine the positional parameters in renderHexPalette-gm.sh and position them the same here, but don't use $1 for that script here, because $1 is provided by this script as $element in a loop repeatedly calling renderHexPalette-gm.sh.
# To NOT recurse into subdirectories but also use additional parameters, pass the keyword NULL for $1, e.g.:
#    renderAllHexPalettes-gm.sh NULL 250 NULL 5


# CODE
if [ "$1" ] && [ "$1" != "NULL" ]
then
	# no -maxdepth 1 switch; recurse through subdirectories
	hexpltFilesArray=(`find . -type f -iname \*.hexplt`)
else
	# -maxdepth 1 switch restricts search to current directory
	hexpltFilesArray=(`find . -maxdepth 1 -type f -iname \*.hexplt`)
fi

for element in ${hexpltFilesArray[@]}
do
	echo ~~~~
	echo Will run renderHexPalette-gm.sh for $element . . .
	renderHexPalette-gm.sh $element $2 $3 $4 $5 $6
done

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path for which there was not already a corresponding .png image. Palette images are named after the source *.hexplt files. If you passed any parameter to this script, this has been done recursively through all subfolders also."