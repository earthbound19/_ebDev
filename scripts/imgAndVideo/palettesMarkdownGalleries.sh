# DESCRIPTION
# Crawls all directories in the current path and runs palettesMarkdownGallery.sh (see) in every one.


# CODE
# VASTLY simplified from previous incarnations of this script, and works recursively besides
# (those didn't) :
find . -type d -not -path "./.git*" -exec sh -c 'cd "{}" && current_dir=$(pwd) && echo working in path $current_dir . . . && palettesMarkdownGallery.sh' \;

echo "DONE running palettesMarkdownGallery.sh in every directory in this path."