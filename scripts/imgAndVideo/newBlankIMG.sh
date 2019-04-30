# DESCRIPTION
# Creates a blank, transparent background png image of dimensions $1 (nn..Xnn..), via graphicsmagick

# USAGE
# Invoke the script with one parameter, being the dimensions in format nXn, e.g. 1200x800 or 4000x4000 or 640x480:
# newBlankIMG.sh 5240x2626

# DEPENDENCIES
# graphicsmagic (gm) in your PATH.


# CODE
gm convert -size $1 xc:transparent "$1"_blank.png