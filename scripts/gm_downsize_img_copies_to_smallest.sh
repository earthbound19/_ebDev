# DESCRIPTION
# For every image (of many types) in the current directory, resizes them to fit inside the smallest dimension of the smallest found image. The shrunk images are useful as bases for composites or comparisons (where otherwise those would operate on pixels in one image out of range of another).

# USAGE
# Hack the image format list in the list= command if you need to.


# CODE
list=(`gfind . -maxdepth 1 \( -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.raw  -o -iname \*.crw -o -iname \*.pdf \) -printf '%f\n' | sort`)

printf '' > imgs_dimensions.txt
for element in ${list[@]}
do
	# print all dimensions to a flat list (not regarding whether it's width or height):
	gm identify -format "%w\n%h" $element >> imgs_dimensions.txt
done

# sort all those lowest first:
sort -n imgs_dimensions.txt > tmp_723Qz8KV4fRH5.txt
mv -f ./tmp_723Qz8KV4fRH5.txt imgs_dimensions.txt

# extract the lowest dimension from this list and store it in a variable:
lowest_dimension=`ghead -n 1 imgs_dimensions.txt`

if [ -d __smaller_img ]; then rm -rf __smaller_img; fi
mkdir __smaller_img

# shrink all images into subfolder with their longest edge at lowest dimension:
for element in ${list[@]}
do
	filename_no_ext=${element%.*}
	gm convert $element -resize $lowest_dimension "$filename_no_ext"__shr_.png
	mv "$filename_no_ext"__shr_.png ./__smaller_img
done