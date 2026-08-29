#!/bin/bash
# DESCRIPTION
# Downloads all images from earthview.withgoogle.com. Yes, that was me querying every possible numbered image at your domain from 0 to 10,000 on Dec 27 2018. I paused substantially between each query, though, so as to not hog your server bandwidth.

# DEPENDENCIES
# wget
# jq (for parsing JSON from GitHub dataset)

# USAGE
# From a directory into which you want all such images to be downloaded, run this script:
#    get_all_earthviews_from_withgoogle_com.sh
# The script uses or creates a cache file of valid earthview IDs, located at:
#    ${HOME}/.cache/earthview/valid_ids.txt"
# -- by exploiting the fact that other wonderful humans maintain a list of valid IDs, at:
#    https://github.com/dqbd/earthview/blob/master/dataset.json
# If that cache file is not found or has an update stamp older than 24 hours, this
# script creates or updates the file.

# CODE

CACHE_DIR="${HOME}/.cache/earthview"
CACHE_FILE="${CACHE_DIR}/valid_ids.txt"
CACHE_TTL=86400  # 24 hours in seconds

# Create directory to contain valid earthview ids in a file, if it doesn't exist
mkdir -p "$CACHE_DIR"

# Someone extracted JSON image source info from somewhere here which shows the
# same range?? (see comment under USAGE)
# Use that! Fetch the current list of valid Earth View IDs from GitHub,
# but only if the cached copy is older than 1 day:
# Function to fetch and parse the JSON (two possible conditions exist in this script to do so; hence a function:
refresh_google_earth_view_valid_IDs_cache() {
	echo "Downloading fresh valid IDs from GitHub..."
	curl -s https://raw.githubusercontent.com/dqbd/earthview/master/dataset.json | \
		jq -r '.[].photoUrl' | \
		grep -o '[0-9]*' | \
		sort -n | \
		uniq > "$CACHE_FILE.tmp"

	# Only replace if download succeeded
	if [ $? -eq 0 ] && [ -s "$CACHE_FILE.tmp" ]; then
		mv "$CACHE_FILE.tmp" "$CACHE_FILE"
		echo "Updated valid_ids.txt with $(wc -l < $CACHE_FILE) IDs"
		return 0
	else
		rm -f "$CACHE_FILE.tmp"
		echo "ERROR: Failed to download or parse dataset. Using cached file if it exists."
		if [ ! -f "$CACHE_FILE" ]; then
			echo "FATAL: No cached file exists. Cannot continue."
			return 1
		else
			return 0  # Continue with existing cache
		fi
	fi
}

# Check if cache exists and needs refreshing
need_refresh=0
if [ ! -f "$CACHE_FILE" ]; then
	echo "Cache file of valid earthview IDs does not exist. Creating it..."
	need_refresh=1
else
	file_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null)))
	if [ $file_age -ge $CACHE_TTL ]; then
		echo "Cache file of valid earthview IDs is stale (age: $((file_age / 3600)) hours). Refreshing it..."
		need_refresh=1
	else
		echo "Cache is fresh (age: $((file_age / 3600)) hours). Using cached valid_ids.txt"
	fi
fi

# Refresh if needed
if [ $need_refresh -eq 1 ]; then
	refresh_google_earth_view_valid_IDs_cache
	if [ $? -ne 0 ]; then
		echo "FATAL: Failed to refresh cache. Exiting."
		exit 1
	fi
fi

# Verify cache file exists and is not empty before proceeding
if [ ! -f "$CACHE_FILE" ] || [ ! -s "$CACHE_FILE" ]; then
	echo "FATAL: Cache file is missing or empty. Cannot continue."
	exit 1
fi

# REFERENCE to chop logos/credit off bottom of image (sorry!), because they get mangled looking in composite works:
# Crop the bottom 36 pixels (rows) off every png image in the current path, via GraphicsMagick:
# gm mogrify -gravity south -chop 0x36 *.png

# crop single image via oiitool:
# oiiotool $1 --crop 1800x1136 -o tst.tif
# page that lists tools in package and has (outdated) help info: https://www.mankier.com/1/oiiotool

# DON'T crop 36 off the bottom of all input images with XNconvert, because it broke (glitched) the images!
# Upper bound apparently 7023--this script found nothing between 7023-10,000. Also apparently there's nothing between 0 and 1002.

# Now download all images from the cached list of valid IDs
echo "Starting download of $(wc -l < $CACHE_FILE) images..."
mapfile -t valid_ids < "$CACHE_FILE"

for id in "${valid_ids[@]}"
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
		echo "--target file $targetFileName does not exist; attempting to retrieve.."
			# DEPRECATED base URL; NO LONGER ONLINE:
			# query_URL="https://earthview.withgoogle.com/download/""$padded_id"".jpg"
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
		echo "--target file $targetFileName already exists; will not clobber: skip."
	fi
done

echo "Download complete."