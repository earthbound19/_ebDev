# DESCRIPTION
# Gets an image title from metadata prep ~MD_ADDS.txt files and runs WPmedia2gallery.sh with that title as a parameter.

# USAGE
# Pass this script one parameter, which is a correctly populated ~MD_ADDS.txt metadata prep file name (which file this script will process) ; e.g.
#    MD_ADDS2markdownGallery.sh _EXPORTED_work_00001__2011-10-16-nearNovatek-IMG_0616-b-postP-layersMerged_MD_ADDS.txt


# CODE
# Get object name (title) from ~MD_ADDS.txt metadata prep file:
title=`sed -n 's/.*ObjectName="\(.*\)".*/\1/p' $1`

WPmedia2markdownGallery.sh "$title"