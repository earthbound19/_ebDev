# DESCRIPTION
# Variant of `printAllIMGfileNames.sh` but for video files. Prints a list of all files matching many video file types in the current directory, and optionally all subdirectories. To create an array from the list, see USAGE.

# USAGE
# Run without any parameter:
#    printAllVideoFileNames.sh
# To use this from another script to create an array from the output, do this:
#    allIMGfileNamesArray=($(printAllIMGfileNames.sh))
# -- you may then iterate through it like this:
#    for element in ${allIMGfileNamesArray[@]}; do <something with $element>; done
# By default, the script only prints files in the current directory, but if you pass any parameter to the script (for example the word 'BROGNALF'), it will also (find and) print image file names from subdirectories:
#    printAllVideoFileNames.sh BROGNALF


# CODE
# If no parameter one, maxdepthParameter will be left at default, which causes find to search only the current directory:
maxdepthParameter='-maxdepth 1'
# If parameter one is passed to script, that changes to nothing, and find's default recursive search will be used (as no maxdepth switch will be passed) :
if [ "$1" ]; then maxdepthParameter=''; fi

find . $maxdepthParameter \( \
-iname \*.3g2 \
-o -iname \*.3gp \
-o -iname \*.3gp2 \
-o -iname \*.3gpp \
-o -iname \*.amv \
-o -iname \*.asf \
-o -iname \*.avi \
-o -iname \*.bik \
-o -iname \*.divx \
-o -iname \*.dpg \
-o -iname \*.dv \
-o -iname \*.dvr-ms \
-o -iname \*.evo \
-o -iname \*.f4v \
-o -iname \*.flv \
-o -iname \*.hdmov \
-o -iname \*.k3g \
-o -iname \*.m1v \
-o -iname \*.m2t \
-o -iname \*.m2ts \
-o -iname \*.m2v \
-o -iname \*.m4b \
-o -iname \*.m4p \
-o -iname \*.m4v \
-o -iname \*.mk3d \
-o -iname \*.mkv \
-o -iname \*.mov \
-o -iname \*.mp2v \
-o -iname \*.mp4 \
-o -iname \*.mp4v \
-o -iname \*.mpe \
-o -iname \*.mpeg \
-o -iname \*.mpg \
-o -iname \*.mpv2 \
-o -iname \*.mpv4﻿﻿ \
-o -iname \*.mqv \
-o -iname \*.mts \
-o -iname \*.mxf \
-o -iname \*.nsv \
-o -iname \*.ogm \
-o -iname \*.ogv \
-o -iname \*.qt \
-o -iname \*.ram \
-o -iname \*.rm \
-o -iname \*.rmvb \
-o -iname \*.skm \
-o -iname \*.swf \
-o -iname \*.tp \
-o -iname \*.tpr \
-o -iname \*.trp \
-o -iname \*.ts \
-o -iname \*.vob \
-o -iname \*.webm \
-o -iname \*.wm \
-o -iname \*.wmv \
-o -iname \*.xvid \
 \) -printf "%P\n"