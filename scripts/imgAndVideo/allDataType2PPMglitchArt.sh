# IN PROGRESS.

# DESCRIPTION: converts all files of a given type in a directory to "glitch" (really data-bent?) art via repeated calls to data2PPMglitchArt.sh.

# USAGE: invoke this script with these parameters:
# $1 file type to operate on (e.g. .dat, bug give the parameter as just dat)
# Example:
# ./thisScript.sh txt

img_format_1=$1

find . -iname \*.$img_format_1 > all_"$img_format_1".txt
while read fileName
do
	data2PPMglitchArt00padded.sh $fileName
	# OR, and not prefered at this writing:
	# data2PPMglitchArt.sh $fileName
done < all_"$img_format_1".txt

rm all_"$img_format_1".txt
