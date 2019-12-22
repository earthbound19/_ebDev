# DESCRIPTION
# Generates image renders of the text contents of all .txt files in the path from which this script is invoked, with the images named after the source text file names.

# USAGE
# With this script in your PATH, invoke it with no parameters:
# ./texts2imgs.sh

# CODE
array=(`gfind . -maxdepth 1 -type f -iname \*.txt -printf '%f\n'`)
for element in ${array[@]}
do
	fileNameNoExt=${element%.*}
	printString=`cat $element`
	convert -background white -size 1920x1920 \
	-gravity Center \
	-pointsize 72 \
	caption:"$printString" \
	"$fileNameNoExt".png
done