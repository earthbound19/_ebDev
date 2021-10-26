# DESCRIPTION
# Downloads all images from earthview.withgoogle.com. Yes, that was me querying every possible numbered image at your domain from 0 to 10,000 on Dec 27 2018. I paused substantially between each query, though, so as to not hog your server bandwidth.

# DEPENDENCIES
# wget.

# USAGE
# From a directory into which you want all such images to be downloaded, run this script:
#    get_all_earthviews_from_withgoogle_com.sh


# CODE
# REFERENCE to chop logos/credit off bottom of image (sorry!), because they get mangled looking in composite works:
# Crop the bottom 36 pixels (rows) off every png image in the current path, via GraphicsMagick:
# gm mogrify -gravity south -chop 0x36 *.png

# crop single image via oiitool:
# oiiotool $1 --crop 1800x1136 -o tst.tif
# page that lists tools in package and has (outdated) help info: https://www.mankier.com/1/oiiotool

# DON'T crop 36 off the bottom of all input images with XNconvert, because it broke (glitched) the images!
# Upper bound apparently 7023--this script found nothing between 7023-10,000. Also apparently there's nothing between 0 and 1002.
for id in $( seq 1003 7023 )
do
	padded_id=`printf "%04d" $id`
	# Example wget query: wget https://earthview.withgoogle.com/download/1734.jpg ;
	# Happily, wget saves nothing if nothing is found (404); so the following will only save valid images:
	query_URL="https://earthview.withgoogle.com/download/""$padded_id"".jpg"
	wget $query_URL
	sleep 3.1
	echo $padded_id > query_log.txt
done