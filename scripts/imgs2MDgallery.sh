# DESCRIPTION
# Creates a markdown top-down image gallery from all image files in the current path (at this writing only png, jpg, gif, and tif are suppored). Gallery file is README.md. WARNING: this will overwrite any other such file without warning!

# USAGE
# Invoke this script without any parameters:
# ./thisScript.sh

# CODE
gfind *.png *.jpg *.gif *.tif *.tiff > all_imgs.txt

printf "# Palettes\n\nClick any image or title header to go to the source image." > README.md

while IFS= read -r element || [ -n "$element" ]
do
    # echo current image is\: $element
	imageFileName="${element%.*}"
    # Create header which is image file name linking to image file:
	printf "### [$imageFileName]($element)\n\n" >> README.md
    # Show image under that header, with alt text of full image name, also linking to image file:
	printf "[ ![$element]($element) ]($element)\n\n" >> README.md
	# printf "bruh\n\n" >> README.md
done < all_imgs.txt

rm all_imgs.txt