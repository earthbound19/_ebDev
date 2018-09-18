# DESCRIPTION
# Converts a fountain format plain text file screenplay into a formatted PDF via a CLI tool (two options, uncomment the option you want). The optional last line of this script opens the output pdf on Mac, which (I think) won't work on Windows, and if it annoys you, leave that commented out.

# USAGE
# thisScript.sh fountain-source-file.fountain


# CODE

fileNameNoExt=${1%.*}

# "wrap" CLI option, uses specific fonts:
# wrap pdf $1 --no-scene-numbers --font "CourierMegaRS-SemiCondensed.ttf, CourierMegaRS-SemiCondensedBold.ttf, CourierMegaRS-SemiCondensedItalic.ttf, CourierMegaRS-SemiCondensedBoldItalic.ttf"

# "afterwriting" CLI option:
afterwriting --source $1 --overwrite --pdf

# open ./$fileNameNoExt.pdf