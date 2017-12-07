# DESCRIPTION
# Generates markdown and HTML for web publication of media from ~MD_ADDS.txt metadata prep files and wp-json REST API query of published media by name at wordpress blog (to include an image tag loading from the blog).

# USAGE
# Pass this script one parameter, being a ~MD_ADDS.txt metadata prep file name to process.

# DEPENDENCIES
# publish-markdown-style.sh and its dependencies (see the comments therein). An image published at a wordpress blog using the "WP REST API filter fields" (maybe? maybe not needed) plugin installed, the image bearing the same name in the wordpress media database as in the ~MD_ADDS.txt file $(1) this script reads from.

# Get object name (title) from ~MD_ADDS.txt metadata prep file:
title=`sed -n 's/.*ObjectName="\(.*\)".*/\1/p' $1`
description=`gsed -n 's/.*Description="\(.*\)".*/\1/p' $1`

tmp_md_fileName=tmp_AxXHR6dzAy9BZQQKA95FARpY.md
HTMLfileName="$title.md"

echo Creating markdown and HTML publication-ready text for work titled\:
echo $title
echo . . .

echo "## $title" > $tmp_md_fileName
# get medium image by that title from wp-json plugin query of media database (image must be already uploaded to wordpress media manager) :
		# DEV NOTES:
		# ex. query that returns something (not what I want) from the wp-json api:
		# http://earthbound.io/blog/wp-json/wp/v2/media?filter[type]=image&per_page=1&page=4&fields=media_details.sizes.medium_large.source_url
		# dev query fragment; re:
		# https://wordpress.org/plugins/rest-api-filter-fields/
		# https://wordpress.org/support/topic/any-support-for-filtering-search-queries-in-the-future/#post-9261694
		# media_details.sizes.medium.source_url
		# -g removes globbing and thereby allows a bracket in the URL:
		# curl -g earthbound.io/blog/wp-json/wp/v2/media?filter[image]
		# curl -g earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title&search=narmth
		# QUERY THAT WORKS as I intend, worked out with the help of the free postman app also; returns every image matching the search term:
		#  curl -g --request GET --url 'http://earthbound.io/blog/wp-json/wp/v2/media?filter[image]=&fields=media_details.image_meta.title&search=narmth'
		# gets medium image URL of an image that matches the title query "narmth:"
		# earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.sizes.medium_large.source_url&search=narmth
		# gets medium image URL and full title of image matching query "narmth:"
		# earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title,media_details.sizes.medium_large.source_url&search=narmth
# URLencode title else the curl query gets messed up by any spaces in the title:
# PROBLEM at blog to be aware of: the various thumbnail sizes for some images are not returned by queries; I need the medium one. For example work 00010 returns all thumbnail sizes from a query, but work 00088 does not. This could be a bug or problem in the wordpress install; TO DO: check if the UI says those images exist. Either way, find a way to force them to exist (force regenerate? I thought I've already got a plugin that does that; maybe the plugin is broken) -- SOLUTION that fixed at least one missing query return: use media library's built-in (?) thumbnail regeneration (after that, 00088 returns thumbnail sizes).
titleURLencoded=`echo "$title" | sed -f /cygdrive/c/_ebdev/scripts/urlencode.sed`
# curl -g --request GET --url "earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title,media_details.sizes.medium_large.source_url&search=00010" > tmp_MD_ADDS2md_JSON_AG2FesS3dkNV7W56gxMy8fdQ.txt
curl -g --request GET --url "earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title,media_details.sizes.medium_large.source_url&search=00088"

echo "$description" >> $tmp_md_fileName
# publish-markdown-style.sh $tmp_md_fileName

# rm tmp_AxXHR6dzAy9BZQQKA95FARpY.md tmp_MD_ADDS2md_JSON_AG2FesS3dkNV7W56gxMy8fdQ.txt