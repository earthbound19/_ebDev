# DESCRIPTION
# Makes a markdown gallery of remote images from a title query to the Wordpress JSON REST API.

# USAGE
#  WPmedia2markdownGallery.sh $1 "An image title name"

# DEPENDENCIES
# Unix-y environment, jq CLI json parser, an image in a wordpress media database (NOTE: hard-coded--TO DO--? make the WP-json URL a parameter?) bearing the same title (in metadata) which you pass this script via $1.


# TO DO
# - Have MD_ADDS2markdownGallery.sh call this after extracting a title from an ~MD_ADDS.txt file? Adapt code for that here?
# - Turn any URL in the text pattern "See http://replaceThisURL for original, print and usage" into a markdown URL. OR turn all URLs into markdown links?
# - HTML conversion: turn linked stylesheets into inline via some tool? Font references into google or other fonts? :/
# - AND/OR strip styles and unused html info from html via some tool?

# DEVELOPER NOTES
# The WP-JSON REST API, it seems, forcibly farts if you set per_page greater than 100. If it ever comes to wanting more than 100 results per query, I'll have to hack Wordpress to overcome that or make this script paginate. Ugh.


# CODE
# Make $1 bash-filename-friendly if it isn't:
fileNameFriendlyString=`ftunStr.sh "$1"`
# Build gallery target markdown file name from that:
target_md_fileName=$fileNameFriendlyString
target_md_fileName="$target_md_fileName"_gallery.md

# Before building markdown gallery, write user directions in the header:
printf "*Tap or click any image to open the largest available resolution.*\n\n" > $target_md_fileName

# reference REST API queries:
# - Get image by title:
# earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title&search=narmth
# - Get image URL and title by title search:
# earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title,media_details.sizes.medium_large.source_url&search=narmth
# - Get all image info by title (in quotes)
# earthbound.io/blog/wp-json/wp/v2/media?filter[image]&search="Work 00088 Fractal Flame"

# URLencode query string passed to script (in preparation for curl query to REST API) :
queryString=$1
queryString=`echo "$queryString" | sed -f /cygdrive/c/_ebdev/scripts/urlencode.sed`
	# Retrieves all json data related to any media matching query:
	# queryString="earthbound.io/blog/wp-json/wp/v2/media?filter\[image\]&search=\"$queryString\""
# Embed the urlencoded query string in a REST API query; query filters results for media title and medium large thumbnail URL; help via wp-api docs, postman and https://jqplay.org/ :
queryString="earthbound.io/blog/wp-json/wp/v2/media?filter\[image\]&search=\"$queryString\"&per_page=100&order=asc&fields=media_details.image_meta.title,media_details.sizes.medium_large.source_url,media_details.sizes.full.source_url,alt_text"
# Make use of that query string with curl and redirect the output to a temp .json file:
# UNCOMMENT THE NEXT LINE after development:
curl $queryString > tmp_DVGXNAUaQe9298.json
		# For legible working with in development:
		jq -r '.[]' tmp_DVGXNAUaQe9298.json > tmp_DVGXNAUaQe9298_prettyPrinted.json
		# REFERENCE string interpolation from another script:
		# jq -r '.[] | "\(.title) ___NERB___ [\(.number)](\(.html_url)) ___NERB___ \(.labels) ___NERB___ \(.user.login) ___NERB___ \(.updated_at)" ' tmp_cgvQnYAYzDep3A.json
		# REFERENCE interpolation of media titles:
		# jq -r '.[] | "\(.media_details.image_meta.title)" ' tmp_DVGXNAUaQe9298.json
		# MARKDOWN REFERENCE psuedo-code of img linking to full img size:
		# [ ![Alt text](addr of med large image to load) ](URL of full res image to make that img a link)
# Write title header and medium image linking to full image with alt text of image title to temp markdown file:
jq -r '.[] | "## \(.media_details.image_meta.title)\n\n[ ![\(.media_details.image_meta.title)](\(.media_details.sizes.medium_large.source_url)) ](\(.media_details.sizes.full.source_url))\n\n\(.alt_text)\n\n" ' tmp_DVGXNAUaQe9298.json >> $target_md_fileName

rm tmp_DVGXNAUaQe9298.json tmp_DVGXNAUaQe9298_prettyPrinted.json

# ALSO TEH BOUNOOS! Convert to HTML!

# CONVERT MARKDOWN TO HTML
publish-markdown-style.sh $target_md_fileName

# OPTIONAL open of resultant html file, assuming the result file name matches that produced by publish-markdown-style.sh:
	# cygstart ./_dist/$HTMLfinalFileName