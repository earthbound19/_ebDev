# DESCRIPTION
# Takes a flat file list of display (and/or multi-display) resolutions in format `NNNNxNNNN`, one per line, and calculates and prints their aspects and number of pixels to:
#    export_resolutions_list_with_aspects.csv
# Sorted by:
# aspect, width, height, number of pixels. Obtain such a list here:
# https://graphicdesign.stackexchange.com/a/137727/46736
# In my files I have that in export_resolutions_list.txt

# DEPENDENCIES
# Such a list in the current directory, named export_resolutions_list.txt

# USAGE
# Run this script without any parameters:
#    resolutionsList2details.sh
# NOTE
# This script sorts and deduplicates the input list, overwriting it in-place, sorting by numeric rank largest first.


# CODE
# Slightly different than what I could do with my script sortuniq.sh:
sort export_resolutions_list.txt -n -r | uniq -i > _tmp_HWPqYyXjv7pGCN.txt
mv -f _tmp_HWPqYyXjv7pGCN.txt export_resolutions_list.txt

printf "" > tmp_axdTM39jAC38cr.txt
OIFS="$IFS"
IFS=
while read -r line || [ -n "$line" ]; do
	width=`echo $line | sed 's/\([0-9]\{1,\}\)x.*/\1/g'`
	height=`echo $line | sed 's/.*x\([0-9]\{1,\}\)/\1/g'`
	aspect=`echo "scale=2; $width / $height" | bc`
	aspect=`echo $aspect | sed 's/\(^\.\)/0\1/'`
	nPixels=`echo "scale=0; $width * $height" | bc`
	echo "Logging information on $line to temp file . . ."
	echo "$line"",""$aspect"",""$nPixels" >> tmp_axdTM39jAC38cr.txt
done < export_resolutions_list.txt
IFS="$OIFS"

# alter the x in NNNNxNNNN format in that to comma (,)
sed -i 's/x/,/' tmp_axdTM39jAC38cr.txt
# NOTE: sort doesn't delineate on colons AND commas (or I don't know how to tell it to),
# so I'll introduce colons in the aspect through reformatting after sort:
echo "Sorting temp file, then putting a CSV header on it . . ."
# I'm mystified by the reasoning and syntax for how GNU sort sorts.
# https://ftp.gnu.org/old-gnu/Manuals/textutils-2.0/html_node/textutils_23.html
# Wikipedia clarified key sorting. Yes, you do actually have to specify 2,2 to sort
# by column 2 independent of considerations of data in other columns.
# Because, you know, humans always think of sort columns as actually groups of
# other columns. NOT.
# https://en.wikipedia.org/wiki/Sort_(Unix)#Columns_or_fields
# Also telling it to use comma as delimiter with -t ,:
sort -t , -k 3,3 -k 1,1 -k 2,2 -k 4,4 -r -n tmp_axdTM39jAC38cr.txt | uniq > tmp_deQKEUSjKc9bcB.txt
	# add :1 to end of last column (making it an aspect ratio expression) :
	# EXCEPT DON'T (deprecated) :
	# sed -i 's/\(.*$\)/\1:1/g' tmp_deQKEUSjKc9bcB.txt
printf "width,height,aspect (x:1),pixels\n" > tmp_ANQX4MsYRSFkU2.txt
cat tmp_ANQX4MsYRSFkU2.txt tmp_deQKEUSjKc9bcB.txt > export_resolutions_list_with_aspects.csv
rm tmp_ANQX4MsYRSFkU2.txt tmp_axdTM39jAC38cr.txt tmp_deQKEUSjKc9bcB.txt

echo "DONE. Result is in export_resolutions_list_with_aspects.csv."