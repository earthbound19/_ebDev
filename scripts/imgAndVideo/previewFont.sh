# TO DO:
# - Document this
# - parameterize font, pointsize, size and caption
# - Base image name on font name
# - caption in courier font giving font name (see gibberish_computer_generated/quasiNayme-pub/getShareAsugarDopeWithQuasiNaymeImages.sh)
# - merge all images into one (see ")
# - MOVE THIS TO DO to that and other similar scripts: remove texteffect.sh dependency--what I am doing is too simple to need that.


# CODE
magick convert -background white -fill indigo -font fontFile.otf -pointsize 72 -size 1000 caption:'SQUADILLY FJNORBLET\nSquadilly Fjnorblet\nsquadilly fjnorblet' out.png

# cygstart out.png