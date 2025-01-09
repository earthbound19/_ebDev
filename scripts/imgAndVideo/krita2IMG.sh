# DESCRIPTION
# krita CLI wrapper to convert from a krita source image to another destination image format (you might call this e.g. effectively kra2png).

# DEPENDENCY
# An install of krita http://krita.org in your PATH.

# USAGE
# Run this script with these parameters:
# - $1 input .kra (or other formats too?) filename
# - $2 desired output extension, without a period, e.g. png
# For example:
#    krita2IMG.sh input.kra png


# CODE
# re: https://userbase.kde.org/Krita/Manual/CommandLine (it is actually enabled, apparently, on Windows) :
fileNameNoExt=${1%.*}
krita $1 --export --export-filename $fileNameNoExt.$2