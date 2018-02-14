# TO DO
# - Reverse media query results sort? Wordpress is returning newest first; I want oldest first. Can I tell the rest API query to do that? Do that with jq?
# - Name file after first result of query.
# - Have MD_ADD2markdownGallery call this after extracting a title from an ~MD_ADDS.txt file? Adapt code for that here?

# DESCRIPTION
# Makes a markdown gallery of remote images from a title query to the Wordpress JSON REST API.

# USAGE
# $1 "query string"

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
queryString="earthbound.io/blog/wp-json/wp/v2/media?filter\[image\]&search=\"$queryString\"&fields=media_details.image_meta.title,media_details.sizes.medium_large.source_url,media_details.sizes.full.source_url"
# Make use of that query string with curl and redirect the output to a temp .json file:
# curl $queryString > tmp_DVGXNAUaQe9298.json
		# For legible working with in development:
		jq -r '.[]' tmp_DVGXNAUaQe9298.json > tmp_DVGXNAUaQe9298_prettyPrinted.json
		# REFERENCE string interpolation from another script:
		# jq -r '.[] | "\(.title) ___NERB___ [\(.number)](\(.html_url)) ___NERB___ \(.labels) ___NERB___ \(.user.login) ___NERB___ \(.updated_at)" ' tmp_cgvQnYAYzDep3A.json
		# REFERENCE interpolation of media titles:
		# jq -r '.[] | "\(.media_details.image_meta.title)" ' tmp_DVGXNAUaQe9298.json
		# MARKDOWN REFERENCE psuedo-code of img linking to full img size:
		# [ ![Alt text](addr of med large image to load) ](URL of full res image to make that img a link)
# Write title header and medium image linking to full image with alt text of image title to temp markdown file:
jq -r '.[] | "# \(.media_details.image_meta.title)\n\n[ ![\(.media_details.image_meta.title)](\(.media_details.sizes.medium_large.source_url)) ](\(.media_details.sizes.full.source_url))\n\n" ' tmp_DVGXNAUaQe9298.json > tmp_wdNZgFrpg.md