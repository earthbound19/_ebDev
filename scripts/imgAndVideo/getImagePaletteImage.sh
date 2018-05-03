echo THIS SCRIPT PROVIDES EXAMPLE COMMANDS for scripts that get a color palette from an image, then an image from that color palette.
# KLUGE: YOU WILL NOTE, with annoyance, that the latter script simply farts most of the time on Mac. It seems imagemagick/graphicsmagick montage is/are buggy (kinda doubtful) or my builds are wrong. Just keep running it until it works--as done here.

# NOTE FOR WINDOWS: at this writing I've only figured out how to get this working by manually adding a NODE_PATH variable with value %AppData%\npm\node_modules to System re: http://stackoverflow.com/questions/9587665/nodejs-cannot-find-installed-module-on-windows#9588052 WHICH you may open via control.exe sysdm.cpl,System,3 -- ALSO NOTE that you must expand that path by pasting it into the address bar of Windows Explorer before actually entering the value as a system PATH variable. -- ALSO NOTE that at this writing the script color-thief-jimp-pallete.sh must be copied to whatever directory you invoke this script from.

source getHybridPalette.sh $1 $2
source colorsGrid.sh $1