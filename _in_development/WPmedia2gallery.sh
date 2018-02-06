# USAGE
# $1 "query string"

# reference REST API queries:
# Get image by title:
# earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title&search=narmth
# Get image URL and title by title search:
# earthbound.io/blog/wp-json/wp/v2/media?filter[image]&fields=media_details.image_meta.title,media_details.sizes.medium_large.source_url&search=narmth
# get all image info by title (in quotes)
# earthbound.io/blog/wp-json/wp/v2/media?filter[image]&search="Work 00088 Fractal Flame"

queryString=$1
queryString=`echo "$queryString" | sed -f /cygdrive/c/_ebdev/scripts/urlencode.sed`
queryString="earthbound.io/blog/wp-json/wp/v2/media?filter\[image\]&search=\"$queryString\""
curl $queryString > wut.txt