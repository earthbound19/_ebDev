# DESCRIPTION
# Creates a markdown top-down image gallery from all image files in the current path (at this writing only png, jpg, gif, and tif are supported). Gallery file is README.md.

# WARNING
# This script will overwrite any README.md gallery that already exists in the directory you run it from, without warning!

# USAGE
# Run this script without any parameters:
#    imgs2MDgallery.sh
# (Omit the ./ if the directory which contains this script is in your PATH environment variable.)


# CODE
find *.png *.jpg *.gif *.tif *.tiff > all_imgs.txt

printf "# Images Markdown Gallery\n\nClick any image or title header to go to the source image.\n\n" > README.md

while IFS= read -r element || [ -n "$element" ]
do
    # echo current image is\: $element
	imageFileName="${element%.*}"
    # Create header which is image file name linking to image file:
	printf "### [\`$imageFileName\`]($element)\n\n" >> README.md
    # Show image under that header, with alt text of full image name, also linking to image file:
	printf "[ ![$element]($element) ]($element)\n\n" >> README.md
	# printf "bruh\n\n" >> README.md
done < all_imgs.txt

rm all_imgs.txt

printf "*Created with [img2MDgallery.sh](https://github.com/earthbound19/_ebDev/blob/master/scripts/imgAndVideo/imgs2MDgallery.sh).*" >> README.md

echo "
~
DONE. README.md with image gallery created (or re-created)."