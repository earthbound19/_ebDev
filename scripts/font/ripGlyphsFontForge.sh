# DESCRIPTION
# Rips all glyphs out of any TrueType (~.ttf) font, saving each glyph into a vector file (eps or svg is possible, maybe other formats).

# DEPENDENCIES
# FontForge, ImageMagick, both in your PATH.

# USAGE
# Invoke with two parameters:
# $1 the input font file name
# $2 the output format for ripped glyphs
# For example:
#  ripGlyphsFontForge.sh inFontFile.ttf eps
# NOTES
# A way to get fontforge must in your %PATH% is to run fontforge-console.bat from the install directory of fontforge. Then, to get into the directory you want to work in:
# cd "/path/to/working/directory"
# -- and then type e.g.:
#  path/to/ripGlyphsFontForge.sh inFontFile.tff eps
# --Where inFontFile.ttf is the font file name to extract glyphs from, and eps is the output format for ripped glyphs.
# ALSO NOTE that ripGlyphs.pe and the font file must both be in your %PATH% and/or working directory. Maybe. I just copy the files I want to work on into the fontforge directory temporarily, then copy out the results and clean up.


# CODE
# Template command; meaning use the ripGlyphs.pe script, and rip arial.ttf into individual eps glyph files:
# fontforge.exe -script ripGlyphs.pe arial.ttf eps
fontforge -script ripGlyphs.pe $1 $2