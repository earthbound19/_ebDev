# DESCRIPTION
# Invokes svgo_optimize.sh repeatedly. See comments in that script.

find *.svg > allSVGs.txt
while read line
do
	svgo_optimize.sh "$line"
done < allSVGs.txt

rm ./allSVGs.txt