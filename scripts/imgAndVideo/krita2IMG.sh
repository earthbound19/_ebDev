# DESCRIPTION
# krita CLI wrapper to convert from a krita source image to another destination image format (you might call this e.g. effectively kra2png).

# DEPENDENCY
# An install of krita http://krita.org in your $PATH.

# USAGE
# Pass this script two parameters, being:
# $1 input .kra (or other formats too?) filename
# $2 desired output extension, without a period, e.g. png
# e.g.
#  krita2IMG.sh input.kra png
# re: https://userbase.kde.org/Krita/Manual/CommandLine (it is actually enabled, apparently, on Windows) :


# CODE
krita $1 --export --export-filename $1.$2