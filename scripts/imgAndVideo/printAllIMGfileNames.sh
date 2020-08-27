# DESCRIPTION
# Prints a list of all files matching many image etc. file types in the current directory, and optionally all subdirectories. To create an array from the list, see USAGE.

# USAGE
# Run without any parameter:
#    printAllIMGfileNames.sh
# To use this from another script to create an array from the output, do this:
#    allIMGfileNamesArray=($(printAllIMGfileNames.sh))
# -- you may then iterate through it like this:
#    for element in ${allIMGfileNamesArray[@]}; do <something with $element>; done
# By default, the script only prints files in the current directory, but if you pass any parameter to the script (for example the word 'BROGNALF'), it will also (find and) print image file names from subdirectories:
#    printAllIMGfileNames.sh BROGNALF


# CODE
# If no parameter one, maxdepthParameter will be left at default, which causes find to search only the current directory:
maxdepthParameter='-maxdepth 1'
# If parameter one is passed to script, that changes to nothing, and find's default recursive search will be used (as no maxdepth switch will be passed) :
if [ "$1" ]; then maxdepthParameter=''; fi

find . $maxdepthParameter \( \
-iname \*.tif \
-o -iname \*.tiff \
-o -iname \*.png \
-o -iname \*.tga \
-o -iname \*.psd \
-o -iname \*.psb \
-o -iname \*.ora \
-o -iname \*.rif \
-o -iname \*.riff \
-o -iname \*.jpg \
-o -iname \*.jpeg \
-o -iname \*.gif \
-o -iname \*.bmp \
-o -iname \*.cr2 \
-o -iname \*.raw \
-o -iname \*.dng \
-o -iname \*.crw \
-o -iname \*.kra \
-o -iname \*.ptg \
 \) -printf "%P\n"