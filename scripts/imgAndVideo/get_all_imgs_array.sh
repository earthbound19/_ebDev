# DESCRIPTION
# Creates a bash array of many image types from all such files in the current path. Must be invoked via `source` to be useful. See USAGE.

# DEPENDENCIES
# a 'nixy environment, gfind

# USAGE Invoke with or without an optional parameter. If invoked without a parameter:
# source get_all_imgs_array.sh
# -- this script creates an array named imgs_arr in default sort returned by gfind. If invoked with an optional parameter which may be any string:
# source get_all_imgs_array.sh foo
# -- the -r switch is appended to sort, which causes the array (list) to reverse order.
# NOTE: to be useful, this script must be invoked via `source`, as directed. This causes the array named imgs_arr to persist in the local bash environment after this script terminates.

if ! [ -z ${1+x} ]; then invisibl_switch='-r'; else invisibl_switch=''; fi
echo "invisibl_switch set to $invisibl_switch"
echo "(if that was a sentence fragment, invisibl_switch was blank)"

# CODE
imgs_arr=(`gfind . -maxdepth 1 \( \
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
 \) -printf '%f\n' | sort $invisibl_switch`)