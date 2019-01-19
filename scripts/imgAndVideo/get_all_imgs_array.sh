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
-iname \*$_MTPL*.tif \
-o -iname \*"$_MTPL"var*.tif \
-o -iname \*$_MTPL*.tiff \
-o -iname \*"$_MTPL"VAR*.tiff \
-o -iname \*$_MTPL*.png \
-o -iname \*"$_MTPL"VAR*.png \
-o -iname \*$_MTPL*.psd \
-o -iname \*"$_MTPL"VAR*.psd \
-o -iname \*$_MTPL*.psb \
-o -iname \*"$_MTPL"*.psb \
-o -iname \*$_MTPL*.ora \
-o -iname \*"$_MTPL"VAR*.ora \
-o -iname \*$_MTPL*.rif \
-o -iname \*"$_MTPL"VAR*.rif \
-o -iname \*$_MTPL*.riff \
-o -iname \*"$_MTPL"VAR*.riff \
-o -iname \*$_MTPL*.jpg \
-o -iname \*"$_MTPL"VAR*.jpg \
-o -iname \*$_MTPL*.jpeg \
-o -iname \*"$_MTPL"VAR*.jpeg \
-o -iname \*$_MTPL*.gif \
-o -iname \*"$_MTPL"VAR*.gif \
-o -iname \*$_MTPL*.bmp \
-o -iname \*"$_MTPL"VAR*.bmp \
-o -iname \*$_MTPL*.cr2 \
-o -iname \*"$_MTPL"VAR*.cr2 \
-o -iname \*$_MTPL*.raw \
-o -iname \*"$_MTPL"VAR*.raw \
-o -iname \*$_MTPL*.crw \
-o -iname \*"$_MTPL"VAR*.crw \
-o -iname \*$_MTPL*.svg \
-o -iname \*"$_MTPL"VAR*.svg \
 \) -printf '%f\n' | sort $invisibl_switch`)