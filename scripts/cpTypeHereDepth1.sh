# DESCRIPTION
# Copies all files of type $1 (png, jpg etc. -- configurable by first parameter) from all directories one level down from the current path. Copies them all here (.)

# USAGE
# Invoke this script with one parameter $1, being the file type extension (without a .) you wish to so copy.


# CODE
fileListFileName="all"_"$1".txt
find . -maxdepth 2 -iname \*.$1 > $fileListFileName

while read element
do
	cp $element .
done < $fileListFileName

rm $fileListFileName