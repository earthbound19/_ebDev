echo THIS SCRIPT PROVIDES EXAMPLE COMMANDS for scripts that get a color palette from an image, then an image from that color palette.
# KLUGE: YOU WILL NOTE, with annoyance, that the latter script simply farts most of the time. It seems imagemagick/graphicsmagick montage is/are buggy. Just keep running it until it works--as done here.

source ./getHybridPalette.sh $1 $2
sleep 1
source ./colorsGrid.sh $1
