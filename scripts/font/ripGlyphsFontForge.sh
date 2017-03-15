# DESCRIPTION
# Rips all glyphs out of any TrueType (~.ttf) font, saving each glyph into a vector file (eps or svg is possible, maybe other formats).

# DEPENDENCIES
# FontForge, ImageMagick

# USAGE
# Invoke with two parameters:
# $1 the input font file name
# $2 the output format for ripped glyphs
# For example:
# thisScript.sh inFontFile.ttf eps

# NOTES
# fontforge must be in your %PATH% for this to work; e.g. open:
# C:\Program Files (x86)\FontForgeBuilds\fontforge-console.bat
# --and then type:
# cd "this directory path"
# -- and then type e.g.:
# ripAllFontGlyphs.bat inFontFile.tff eps
# --Where inFontFile.ttf is the font file name to extract glyphs from, and eps is the output format for ripped glyphs.
# ALSO NOTE that ripGlyphs.pe and the font file must both be in your %PATH%.

# Template command; meaning use the ripGlyphs.pe script, and rip arial.ttf into individual eps glyph files:
# fontforge.exe -script ripGlyphs.pe arial.ttf eps

fontforge -script ripGlyphs.pe $1 $2