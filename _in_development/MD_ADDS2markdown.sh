# DESCRIPTION
# Generates markdown and HTML for web publication of media from ~MD_ADDS.txt metadata prep files. Relies on the wp-json REST API to query published media by name at wordpress blog.

# USAGE
# Pass this script one parameter, being a correctly populated ~MD_ADDS.txt metadata prep file name (which file this script will process).

# DEPENDENCIES
# publish-markdown-style.sh and its dependencies (see the comments therein). An image published at a wordpress blog using the "WP REST API filter fields" (maybe? maybe not needed) plugin installed, the image bearing the same name in the wordpress media database as in the ~MD_ADDS.txt file $(1) this script reads from.

# TO DO
# - Correct markdown inline image code? I don't even know where I was going with this when I left off and FORGOT about it and started solving the same (or a similar) problem with WPmedia2gallery.sh :(
# - Rework to more elegantly use jq re WPmedia2gallery.sh?
# - turn linked stylesheets into inline via some tool? font references into google or other fonts? :/
# - AND/OR strip styles and unused html info from html via some tool?
# - turn plain URL texts in markdown into links? Already done for HTML conversion, because when converted to HTML via markdown-styles (generate-md), it automatically makes them URLs.


# CODE

# Only execute the code in this script if the ~MD_ADDS.txt file from parameter $1 exists.
if [ -f $1 ]
then
	echo File \"$1\" found\; will proceed.
	# Get object name (title) from ~MD_ADDS.txt metadata prep file:
	title=`sed -n 's/.*ObjectName="\(.*\)".*/\1/p' $1`
	description=`sed -n 's/.*Description="\(.*\)".*/\1/p' $1`

	# Replace any terminal unfriendly characters from that title--including spaces--with underscores; code adapted from ftun.sh:
	titleFileNameTFC=$(echo $title | tr \=\@\`~\!#$%^\&\(\)+[{]}\;\ , _)
	HTMLintermediaryFileName="$titleFileNameTFC.md"
	HTMLfinalFileName="$titleFileNameTFC.html"

	tmp_md_fileName=tmp_AxXHR6dzAy9BZQQKA95FARpY.md

	echo Creating markdown and HTML publication-ready text for work titled\:
	echo $title
	echo . . .

	# WRITE TITLE to markdown file
	printf "## $title\n\n" > $tmp_md_fileName

		# URLencode title else the curl query gets messed up by any spaces in the title:
		titleURLencoded=`echo "$title" | sed -f /cygdrive/c/_ebdev/scripts/urlencode.sed`
	# QUERY wp-json for image information by title string match:
		# -g removes globbing and thereby allows a bracket in the URL.
# EXTREMELY PAINFUL bug found (took hours) : jq produces a "Segmentation fault" error if you pass it a command line and/or file name that is too long; shortening the ~.json file I output to fixed it:
	curl -g --request GET --url "earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title,media_details.sizes.medium_large.source_url,media_details.sizes.full.source_url&search=$titleURLencoded" > tmp_MD_ADDS2md_JSON_AG2FesS3.json
	# NOTE: if various thumbnail sizes are not returned for queries, try using the wordpress media library's built-in (?) thumbnail regeneration function (after that, e.g. 00088 returns thumbnail sizes).

	# EXTRACT MEDIUM LARGE source_url value from that result:
	jq -r '.[] | "# \(.media_details.sizes.medium_large.source_url)" ' tmp_MD_ADDS2md_JSON_AG2FesS3.json

	# EXTRACT FULL IMAGE source_url value from that result, then strip \ escapes from it:
	fullIMGsourceURL=`sed 's/.*full":{"source_url":"\([^"]\{1,\}\).*/\1/g' tmp_MD_ADDS2md_JSON_AG2FesS3.json`
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
exit
CONTINUE CODING HERE	

	# WRITE TAP OR CLICK to open largest available resolution prompt to markdown file
	printf "*Tap or click image to open largest available resolution.*\n\n" >> $tmp_md_fileName

	# WRITE DESCRIPTION to markdown file
	printf "$description\n\n" >> $tmp_md_fileName

	# CONVERT MARKDOWN TO HTML
	cp $tmp_md_fileName $HTMLintermediaryFileName
		if [ ! -d ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm ]; then mkdir ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm; fi

	# TWO OPTIONS here; uncomment the one you wish to use:
	# --
	# GENERATE-MD (MARKDOWN-STYLES) OPTION; which is prettier but requires support files in a subfolder to be with the html file:
	# publish-markdown-style.sh $HTMLintermediaryFileName
	# --
	# PANDOC OPTION; which produces very portable but less pretty HTML:
	pandoc $HTMLintermediaryFileName -o ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm/$HTMLfinalFileName

	# MOVE ALL RESULT files into ./_dist
	# Create _dist folder if it doesn't exist:
	if [ ! -d ./_dist ]; then mkdir ./_dist; fi
	# move results from publish-markdown-style.sh script-specific folder name to _dist:
	mv ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm/* ./_dist
	mv $HTMLintermediaryFileName ./_dist

	# OPTIONAL open of resultant html file, assuming the result file name matches that produced by publish-markdown-style.sh:
	cygstart ./_dist/$HTMLfinalFileName

	# DELETE THIS SCRIPTS' TEMP FILES
	rm -rf tmp_AxXHR6dzAy9BZQQKA95FARpY.md tmp_MD_ADDS2md_JSON_AG2FesS3.json publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm
else
	echo File \"$1\" not found\; functions skipped.
fi