# DESCRIPTION
# Calls renderHexPalette-gm.sh for every .hexplt file in the path (non-recrusive) from which this script is invoked. Result: all hex palette files in the current path are rendered. Also optionally recurses into subdirectories

# USAGE
# To render all palettes in the current directory, invoke the script without any argument:
#  ./renderAllHexPalettes-gm.sh
# To recurs into all subdirectories and render all palettes in them, pass any parameter for $1:
#  ./renderAllHexPalettes-gm.sh YORP

# CODE
if [ "$1" ]
then
	# no -maxdepth 1 switch; recurse through subdirectories
	hexpltFilesArray=(`gfind . -type f -iname \*.hexplt`)
else
	# -maxdepth 1 switch restricts search to current directory
	hexpltFilesArray=(`gfind . -maxdepth 1 -type f -iname \*.hexplt`)
fi

for element in ${hexpltFilesArray[@]}
do
	echo ~~~~
	echo invoking renderHexPalette-gm.sh for $element . . .
	renderHexPalette-gm.sh $element
done

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path for which there was not already a corresponding .png image. Palette images are named after the source *.hexplt files. If you passed any parameter to this script, this has been done recursively through all subfolders also."