# DESCRIPTION
# Takes the second page of a screenplay (ostensibly one that has a title page) and generates
# a `.png` format image preview of it, named `<fileNameNoExt>_preview.png`

# DEPENDENCIES
# - `GraphicsMagick`
# - `gs` (ghostscript).
# - A Unix or emulated Unix envrionment
# - An input pdf

# USAGE
# Run with one parameter, which is the file name of the screenplay to get an image excerpt of:
#    pdfScreenplayPreview.sh screenplay.pdf


# CODE
fileNameNoExt=${1%.*}

# command adapted from: http://duncanlock.net/blog/2013/11/18/how-to-create-thumbnails-for-pdfs-with-ImageMagick-on-linux/
gm convert -set option:size '%[fx:min(w,h)]x%[fx:min(w,h)]' -gravity center $1[1] "$fileNameNoExt"_preview.png
# crop to square over the same image adapted from: https://www.ImageMagick.org/discourse-server/viewtopic.php?t=28283#p125413
DD=`identify -format "%[fx:min(w,h)]" "$fileNameNoExt"_preview.png`
convert "$fileNameNoExt"_preview.png -gravity center -crop ${DD}x${DD}+0+0 +repage "$fileNameNoExt"_preview.png
