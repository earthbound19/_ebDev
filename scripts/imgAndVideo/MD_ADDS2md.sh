# DESCRIPTION
# Generates markdown and HTML for web publication of media from ~MD_ADDS.txt metadata prep files. Relies on the wp-json REST API to query published media by name at wordpress blog.

# USAGE
# Pass this script one parameter, being a correctly populated ~MD_ADDS.txt metadata prep file name (which file this script will process).

# DEPENDENCIES
# publish-markdown-style.sh and its dependencies (see the comments therein). An image published at a wordpress blog using the "WP REST API filter fields" (maybe? maybe not needed) plugin installed, the image bearing the same name in the wordpress media database as in the ~MD_ADDS.txt file $(1) this script reads from.

# TO DO
# - turn linked stylesheets into inline via some tool? font references into google or other fonts? :/
# - AND/OR strip styles and unused html info from html via some tool?
# - turn plain URL texts in markdown into links? Already done for HTML conversion, because when converted to HTML via markdown-styles (generate-md), it automatically makes them URLs.


# CODE
# Get object name (title) from ~MD_ADDS.txt metadata prep file:
title=`sed -n 's/.*ObjectName="\(.*\)".*/\1/p' $1`
description=`gsed -n 's/.*Description="\(.*\)".*/\1/p' $1`

tmp_md_fileName=tmp_AxXHR6dzAy9BZQQKA95FARpY.md
HTMLfileName="$title.md"

echo Creating markdown and HTML publication-ready text for work titled\:
echo $title
echo . . .

# WRITE TITLE to markdown file
printf "## $title\n\n" > $tmp_md_fileName

	# URLencode title else the curl query gets messed up by any spaces in the title:
	titleURLencoded=`echo "$title" | sed -f /cygdrive/c/_ebdev/scripts/urlencode.sed`
# QUERY wp-json for image information by title string match:
	# -g removes globbing and thereby allows a bracket in the URL.
curl -g --request GET --url "earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title,media_details.sizes.medium_large.source_url,media_details.sizes.full.source_url&search=$titleURLencoded" > tmp_MD_ADDS2md_JSON_AG2FesS3dkNV7W56gxMy8fdQ.txt
# NOTE: if various thumbnail sizes are not returned for queries, try using the wordpress media library's built-in (?) thumbnail regeneration function (after that, e.g. 00088 returns thumbnail sizes).

# EXTRACT MEDIUM LARGE source_url value from that result:
medium_largeIMGsourceURL=`sed 's/.*medium_large":{"source_url":"\([^"]\{1,\}\).*/\1/g' tmp_MD_ADDS2md_JSON_AG2FesS3dkNV7W56gxMy8fdQ.txt`
	# Remove \ escapes from that result; here double-escaped because from a terminal it needs an escape and from a script streaming to terminal it needs another escape:
	medium_largeIMGsourceURL=`echo "$medium_largeIMGsourceURL" | tr -d '\\\\'`

# EXTRACT FULL IMAGE source_url value from that result, then strip \ escapes from it:
fullIMGsourceURL=`sed 's/.*full":{"source_url":"\([^"]\{1,\}\).*/\1/g' tmp_MD_ADDS2md_JSON_AG2FesS3dkNV7W56gxMy8fdQ.txt`
	fullIMGsourceURL=`echo "$fullIMGsourceURL" | tr -d '\\\\'`

# WRITE IMAGE AS ANCHOR link to largest available resolution image to markdown file:
	# reference image markdown: ![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 1")
		# DEPRECATED, but useful reference; write image display markdown to markdown file:
		# printf "![$title, by RAH]($medium_largeIMGsourceURL)\n\n" >> $tmp_md_fileName
	# reference anchor markdown: [ alt text or other element such as text or image ](http://somelink)
	# reference markdown combining those, to make a medium large image an anchor to the full size image:
		# [ ![Electric Sheep 202-11969 and 202-41223 alternate DRAGON EYE (work 00007B), by RAH](http://earthbound.io/blog/wp-content/uploads/2016/11/Electric-Sheep-202-11969-and-202-41223-alternate-DRAGON-EYE-work-00007B-768x576.jpg) ](http://earthbound.io/blog/wp-content/uploads/2016/11/Electric-Sheep-202-11969-and-202-41223-alternate-DRAGON-EYE-work-00007B.jpg)
		# That structure condensed into psuedo-code:
		# [ ![Alt text](addr of med large image to load) ](URL of full res image to make that img a link)
printf "[ ![$title, by RAH]($medium_largeIMGsourceURL) ]( $fullIMGsourceURL )\n\n" >> $tmp_md_fileName

# WRITE TAP OR CLICK to open largest available resolution prompt to markdown file
printf "*Tap or click image to open largest available resolution.*\n\n" >> $tmp_md_fileName

# WRITE DESCRIPTION to markdown file
printf "$description\n\n" >> $tmp_md_fileName

# CONVERT MARKDOWN TO HTML
publish-markdown-style.sh $tmp_md_fileName

# DELETE THIS SCRIPTS' TEMP FILES
rm tmp_AxXHR6dzAy9BZQQKA95FARpY.md tmp_MD_ADDS2md_JSON_AG2FesS3dkNV7W56gxMy8fdQ.txt