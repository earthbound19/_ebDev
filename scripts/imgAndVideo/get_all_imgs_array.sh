# DESCRIPTION
# Prints a list of all files matching many image file types (images etc.) in the current directory. To create an array from the list, see USAGE.

# USAGE
# Invoke without any parameter:
#  get_all_imgs_array.sh
# To create an array from the output from another script, do this:
# allIMGsArray=(`get_all_imgs_array.sh`)
# -- you may then iterate through it like: for element in ${allIMGsArray[@]}; do <code things with $element>; done


# CODE
if [ "$1" ]; then invisibl_switch='-r'; else invisibl_switch=''; fi

find . -maxdepth 1 \( \
-iname \*.tif \
-o -iname \*.tiff \
-o -iname \*.png \
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
-o -iname \*.crw \
-o -iname \*.kra \
-o -iname \pdf \
 \) -printf '%f\n'

# Other possible formats: 
# m4a \
# mov \
# mp4 \
# ptg \
# eps \
# svg \