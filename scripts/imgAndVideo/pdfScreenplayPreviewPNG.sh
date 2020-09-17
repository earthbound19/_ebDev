# DESCRIPTION
# Takes the second page of a screenplay (ostensibly one that has a title page) and generates
# a `.png` format image preview of it, named `<fileNameNoExt>_preview.png`

# DEPENDENCIES
# - GraphicsMagick (`gm`)
# - A Unix or emulated Unix envrionment
# - An input pdf

# USAGE
# Run with one parameter, which is the file name of the screenplay to get an image excerpt of:
#    pdfScreenplayPreview.sh screenplay.pdf


# CODE
renderTargetFileName="${1%.*}"_preview.png
# command adapted from: http://duncanlock.net/blog/2013/11/18/how-to-create-thumbnails-for-pdfs-with-ImageMagick-on-linux/
gm convert -set option:size '%[fx:min(w,h)]x%[fx:min(w,h)]' -gravity center $1[2] "$renderTargetFileName"
# crop to square over the same image adapted from: https://www.ImageMagick.org/discourse-server/viewtopic.php?t=28283#p125413
W=$(gm identify -format "%w" $renderTargetFileName)
gm convert $renderTargetFileName -gravity center -crop ${W}x${W}+0+0 +repage $renderTargetFileName