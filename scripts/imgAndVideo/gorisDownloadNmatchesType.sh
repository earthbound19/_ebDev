# DESCRIPTION
# Invokes gorisDownloadNmatches.sh against every (image) file of a given type in the current path.

# USAGE
# Invoke this script with one parameter, being an image file type extension (without a dot). Every image of that type in the current directory will be passed to gorisDownloadNmatches.sh, which will perform a Google reverse image search and download N results (whatever the default is).
# EXAMPLE command:
#  gorisDownloadNmatchesType.sh png
# NOTES
# To get all images back up to this level which gorisDownloadNmatches.sh moves down one level into a folder named after a file (for every file of the type you specify here, respectively), run e.g. :
#  cpTYpeHereDepth1.sh png
# -- which would e.g. copy all png files one path down up to the path you run this script from.

# TO DO: have this script optionally pass parameter $2 to the script it calls.


# CODE
img_format=$1
allTypeIMGSlistFileName=all_"$img_format".txt

# -maxdepth 1 limits the search to only the current path (and no subpaths), else running this script twice attempts to find matches for matches in sub-subfolders (and creates sub-sub-subfolders) :
find . -maxdepth 1 -iname \*.$1 > $allTypeIMGSlistFileName
while read element
do
	gorisDownloadNmatches.sh $element
done < $allTypeIMGSlistFileName

rm $allTypeIMGSlistFileName