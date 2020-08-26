# DESCRIPTION
# Crawls all directories in the current path and runs palettesMarkdownGallery.sh (see) in every one.


# CODE
# VASTLY simplified from previous incarnations of this script, and works recursively besides
# (those didn't) :
find . -type d -exec sh -c 'cd "{}" && palettesMarkdownGallery.sh' \;

echo "DONE running palettesMarkdownGallery.sh in every directory in this path."