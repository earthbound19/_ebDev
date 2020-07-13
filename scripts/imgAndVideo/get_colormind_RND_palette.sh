# DESCRIPTION
# Fetches a randomly served color scheme from http://colormind.io and converts it to a .hexplt file named after the colors in the palette.

# DEPENDENCIES
# curl and sed from a 'nixy environment (MSYS2 on Windows may be best) to run this bash script, and the colormind API documented at: http://colormind.io/api-access/ and https://github.com/dmi3kno/colormind

# USAGE
#  get_colormind_RND_palette.sh
# results in a new file e.g. colormind_dot_io__0C4F4F_D8CBAA_FD7A07_FC2515_720B17.hexplt, with one hex color code per line of those respective color codes in the file name itself.
# To retrieve and render so many palettes, see USAGE in fetch_and_render_Ncolormind_palettes.sh.


# CODE
paletteJSON=`curl 'http://colormind.io/api/' --data-binary '{"model":"default"}'`
# {"result":[[155,247,24],[218,143,29],[217,43,126],[72,39,74],[31,33,49]]}

# replace all non-numbers with spaces via sed:
palette=`echo $paletteJSON | sed 's/[^0-9]/ /g'`

# weirdly, print or echo strips redundant whitespace from that, but it turns out the printf format command I use strips it, so there's no need to strip it otherwise:
fileNameString=`printf '%02X%02X%02X_' $palette`
# strip trailing _ off that:
fileNameString="colormind_dot_io__"${fileNameString:0:34}".hexplt"

printf '#%02X%02X%02X\n' $palette > $fileNameString