# DESCRIPTION
# Rips all glyphs out of any TrueType (~`.ttf`) font, saving each glyph into a vector file (`eps` or `svg` are possible, and maybe other formats).

# DEPENDENCIES
# FontForge, ImageMagick, and getFullPathToFile.sh, all in your PATH.

# USAGE
# Run with these parameters:
# - $1 the input font file name
# - $2 the output format for ripped glyphs
# For example:
#    ripGlyphsFontForge.sh inFontFile.ttf eps
# NOTES
# A way to get FontForge in your PATH is to run FontForge-console.bat from the install directory of FontForge. Then, run commands to get into the directory you want to work in and run this script:
#    cd /path/to/working/directory
#    path/to/ripGlyphsFontForge.sh inFontFile.tff eps
# -- where `inFontFile.ttf` is the font file name to extract glyphs from, and eps is the output format for ripped glyphs.
# Also, `ripGlyphs.pe` and the font file must both be in your PATH and/or working directory. Maybe. I just copy the files I want to work on into the FontForge directory temporarily, then copy out the results and clean up.


# CODE
# Template command; meaning use the ripGlyphs.pe script, and rip arial.ttf into individual eps glyph files:
# FontForge.exe -script ripGlyphs.pe arial.ttf eps

# Previously this worked without a full path to the script file (I thought?), but as of this writing it seems to need a full path, so get it and store it in a variable:
scriptPath=$(getFullPathToFile.sh ripGlyphs.pe)

FontForge -script $scriptPath $1 $2