# DESCRIPTION
# Invokes svgo_optimize.sh repeatedly. See comments in that script.

CLIopts="--disable=mergePaths --enable=removeRasterImages --disable=convertShapeToPath"
# OTHER ADDITIONAL OPTIONS; comment out if you don't want them:
# moreCLIopts="--enable=removeDimensions --enable=removeRasterImages --enable=removeUnknownsAndDefaults"
# UNUSED option(s):
# --enable=removeViewBox

find *.svg > allSVGs.txt
mapfile -t allSVGs < allSVGs.txt
rm allSVGs.txt
for element in "${allSVGs[@]}"
do
	svgo_optimize.sh "$element"
done