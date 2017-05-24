# DESCRIPTION
# Converts all images of a given type (CR2, RAW etc.) to DNG type files via AdobeDNGConverter.exe CLI, which must be in your path and the executable so renamed.

# USAGE
# Invoke with one parameter $1, being a file type to operate on, e.g.:
# ./thisScript.sh CR2

find . -iname \*.$1 > all_wut.txt
mapfile -t all_wut < all_wut.txt
for element in "${all_wut[@]}"
do
	echo executing command\: AdobeDNGConverter.exe -c -p1 -fl $element . . .
	AdobeDNGConverter.exe -c -p1 -fl $element
done

rm all_wut.txt all_wut.txt
