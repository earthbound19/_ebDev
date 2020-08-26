# DESCRIPTION
# Runs `gorisDownloadNmatches.sh` against every (image) file of a given type in the current path.

# USAGE
# Run this script with this parameter:
# - $1 an image file type extension (without a dot). Every image of that type in the current directory will be passed to gorisDownloadNmatches.sh, which will perform a Google reverse image search and download N results (whatever the default is).
# For example:
#    gorisDownloadNmatchesType.sh png


# CODE
# TO DO
# - Have this script optionally pass parameter $2 to the script it calls.
img_format=$1
allTypeIMGSlistFileName=all_"$img_format".txt

# -maxdepth 1 limits the search to only the current path (and no subpaths), else running this script twice attempts to find matches for matches in sub-subfolders (and creates sub-sub-subfolders) :
find . -maxdepth 1 -iname \*.$1 > $allTypeIMGSlistFileName
while read element
do
	gorisDownloadNmatches.sh $element
done < $allTypeIMGSlistFileName

rm $allTypeIMGSlistFileName