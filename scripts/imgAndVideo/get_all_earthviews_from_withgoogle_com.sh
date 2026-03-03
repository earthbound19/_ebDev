# DESCRIPTION
# Downloads all images from earthview.withgoogle.com. Yes, that was me querying every possible numbered image at your domain from 0 to 10,000 on Dec 27 2018. I paused substantially between each query, though, so as to not hog your server bandwidth.

# DEPENDENCIES
# wget.

# USAGE
# From a directory into which you want all such images to be downloaded, run this script:
#    get_all_earthviews_from_withgoogle_com.sh
# SEE ALSO COMMENT HEADER "ANOTHER APPROACH" before wget loop, as it uses a data source that doesn't construct URLs which are apparently invalid (many numbers in the image collect range are skipped at the host apparently).

# CODE
# REFERENCE to chop logos/credit off bottom of image (sorry!), because they get mangled looking in composite works:
# Crop the bottom 36 pixels (rows) off every png image in the current path, via GraphicsMagick:
# gm mogrify -gravity south -chop 0x36 *.png

# crop single image via oiitool:
# oiiotool $1 --crop 1800x1136 -o tst.tif
# page that lists tools in package and has (outdated) help info: https://www.mankier.com/1/oiiotool

# DON'T crop 36 off the bottom of all input images with XNconvert, because it broke (glitched) the images!
# Upper bound apparently 7023--this script found nothing between 7023-10,000. Also apparently there's nothing between 0 and 1002.
# ALSO someone extracted JSON image source info from somewhere here which shows the same range?? https://github.com/dqbd/earthview/blob/master/dataset.json
# SO -- OR:
# ANOTHER APPROACH which won't have so any failed attempts (see comments under USAGE) ; to use that JSON data at that URL to get the URLs, download it and try this manually from bash ; here again the doom is had of needing to trim windows newlines off the end of returned data:
#	allURLs=($(jq '.[].photoUrl' dataset.json | tr -d "\"" | tr -d '\15\32' | shuf))
#	for URL in ${allURLs[@]}
#	do
#		wget --no-check-certificate $URL
#		sleep 4.3
#		echo $padded_id > query_log.txt
#	done

# create shuffled list of all IDs (to get them in random order but get all of them) :
ids=($(seq 1003 7023 | shuf))
for id in ${ids[@]}
do
	padded_id=$(printf "%04d" $id)
	# Example wget query: wget https://earthview.withgoogle.com/download/1734.jpg ;
	# Happily, wget saves nothing if nothing is found (404); so the following will only save valid images:
		# previous URL structure -- deprecated:
		# query_URL="https://earthview.withgoogle.com/download/""$padded_id"".jpg"
	# only attempt retrieval if constructed target file name does not already exist:
	targetFileName="$padded_id"".jpg"
	if [ ! -e $targetFileName ]
	then
		echo "--DOES NOT EXIST target file $targetFileName; attepting to retrieve.."
		query_URL="https://www.gstatic.com/prettyearth/assets/full/""$padded_id"".jpg"
		wget $query_URL &>/dev/null
		# if there was no error (errorlevel is 0) retrieving file, briefly sleep; otherwise log an error:
		if [ "$?" == "0" ]
		then
			sleep 3.1
		else
			echo "error retrieving $query_URL ($targetFileName)" >> query_error_log.txt
			echo "error retrieving $query_URL ($targetFileName); logged to query_error_log.txt."
		fi
	else
		echo "--EXISTS TARGET FILE $targetFileName; will not clobber; skip."
	fi
done