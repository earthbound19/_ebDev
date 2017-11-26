# UNTESTED: imgFileNoExt val.
# If I ever use it (I thought I might, but maybe not), I'll fix it up if necessary and remove this first comment.

# USAGE
# Invoke this script with three parameters, being:
# $1 input file
# $2 output format
# $3 px wide to resize to by nearest neighbor method, maintaining aspect

# template command; resizes to x800 px maintaining aspect ratio:
# nconvert -ratio -rtype quick -resize 800 -ratio -out jpeg -o outPutFileName.jpg inputFile.png

imgFileNoExt=`echo $1 | gsed 's/\(.*\)\..\{1,4\}/\1/g'`
nconvert -ratio -rtype quick -resize $3 -ratio -out $2 -o outPutFileName.jpg $imgFileNoExt.$2