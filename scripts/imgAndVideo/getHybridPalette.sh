# DESCRIPTION
# Gets color palettes (number of colors configurable via parameter) via an image plus color-thief-jimp and imagemagick, parses and combines them into one 18-color palette, and produces a palette image from the result.

# USAGE
# Invoke this script with two parameters:
# $1 the image to extract colors from
# $2 how many colors for color-thief-jimp and imagemagick (respectively--and actually graphicsmagick) to extract. Resultant palette and image will have (n * 2) colors.

# DEPENDENCIES
# nodejs, imagemagick. On Mac imagemagick perhaps ideally via macports; re: https://www.imagemagick.org/script/binary-releases.php -- and node installs should be global:
# npm install -g jimp
# npm install -g color-thief-jimp

# INTERESTING AND UNRELATED; posterizes:
# http://stackoverflow.com/a/27882332/1397555


# ==== CODE

# $(($2 + 1)) because it's only giving e.g. 7 colors if I ask for 8:
node color-thief-jimp-pallete.js $1 $(($2 + 1)) > $1.ctj-colors-hex.txt
# re: http://stackoverflow.com/questions/26889358/generate-color-palette-from-image-with-imagemagick
# possibly more useful parameter omitted: -colorspace LAB
gm convert $1 -format %c -colorspace LAB -colors $2 histogram:info:- > $1.mg-colors-hex.txt

# NOTES: hrm. it seems that perhaps on Mac that -n switches here (with -i) make it work, and on cygwin they make it *not* work.
sed -i "s/.*'\([aA-fF0-9]\{6\}\).*/#\1/g" $1.ctj-colors-hex.txt
sed -i 's/.*\(#[aA-fF0-9]\{6\}\).*/\1/g' "$1".mg-colors-hex.txt
# paste and sort the two into one file:
paste -s -d '\n\n' ./$1.ctj-colors-hex.txt ./$1.mg-colors-hex.txt > tmp.txt
# UPPERCASE all that:
tr '[:lower:]' '[:upper:]' < tmp.txt > tmp2.txt

# re some genius breath yon: http://www.unix.com/302548935-post6.html?s=b4b6b3ed50b6831717f6429113302ad6
awk '{printf("%050s\t%s\n", toupper($0), $0)}' tmp2.txt | LC_COLLATE=C sort -r -k1,1 | cut -f2 > $1.hybrid-colors-hex.txt

# cleanup
# Mac OS only' because some bug in OSX sed or summat is leaving behind files ending with -n:
if [ -e ./$1.ctj-colors-hex.txt-n ]
then
	rm ./$1.ctj-colors-hex.txt-n ./$1.mg-colors-hex.txt-n
fi

rm ./$1.ctj-colors-hex.txt ./$1.mg-colors-hex.txt ./tmp.txt ./tmp2.txt
