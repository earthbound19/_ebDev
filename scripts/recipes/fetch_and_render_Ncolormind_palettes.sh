# DESCRIPTION
# Retrieves N ($1) palettes from colormind.io, and renders them with renderAllHexPalettes-gm.sh.

# USAGE
# Invoke with the number of palettes you wish to retrieve and render, e.g.:
#  fetch_and_render_Ncolormind_palettes.sh 100


# CODE
if ! [ "$1" ]; then echo "No parameter \$1 (number of palettes to get and render). Exit."; exit; fi

for i in `seq 0 $1`; do get_colormind_RND_palette.sh; sleep 1; done

renderAllHexPalettes-gm.sh NULL 250 NULL 5