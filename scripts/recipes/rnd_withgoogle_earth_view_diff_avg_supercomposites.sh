#!/bin/bash
# DESCRIPTION
# Fetches N random images from earthview.withgoogle.com and runs `diff_avg_supercomposites.sh`.

# USAGE
# Run with one parameter, which is how many random images you want to retrieve before this script calls diff_avg_supercomposites_nested_loop.sh; for example:
#    rnd_withgoogle_earth_view_diff_avg_supercomposites.sh 12
# NOTES
# - Unless you intend for images other than what this script retrieves to be supercompositied, you probably best run this script from an empty, new project folder.
# - If you alternately want to run `diff_avg_supercomposites_nested_loop.sh` after image colleciton instead, comment out the line for `.sh`, and uncomment the line for the other option.
# - Some image numbers in the constructed URLs this script makes may not be available. If you don't get enough images, cancel the script run and try again.
# - This script now uses a cached list of known-valid IDs from the get_all script.

# CODE

# Check for recent cache data of discovered valid IDs, as made by get_all_earthviews_from_withgoogle_com.sh:

CACHE_DIR="${HOME}/.cache/earthview"
CACHE_FILE="${CACHE_DIR}/valid_ids.txt"
CACHE_TTL=86400  # 24 hours in seconds

# Check if cache exists
if [ ! -f "$CACHE_FILE" ]; then
	echo "ERROR: Cache file $CACHE_FILE does not exist."
	echo "Run get_all_earthviews_from_withgoogle_com.sh first to build the cache."
	exit 1
fi

# Check if cache is empty
if [ ! -s "$CACHE_FILE" ]; then
	echo "ERROR: Cache file $CACHE_FILE is empty."
	echo "Run get_all_earthviews_from_withgoogle_com.sh to rebuild the cache."
	exit 1
fi

# Check freshness and warn if stale
file_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null)))
if [ $file_age -ge $CACHE_TTL ]; then
	echo "WARNING: Cache is stale (age: $((file_age / 3600)) hours)."
	echo "Run get_all_earthviews_from_withgoogle_com.sh to refresh the cache."
	echo "Continuing with existing cache anyway..."
else
	echo "Cache is fresh (age: $((file_age / 3600)) hours). Using cached valid_ids.txt"
fi

# Read valid IDs from cache
mapfile -t valid_ids < "$CACHE_FILE"

# Verify we have some IDs
if [ ${#valid_ids[@]} -eq 0 ]; then
	echo "ERROR: No valid IDs found in cache file."
	exit 1
fi

echo "Found ${#valid_ids[@]} valid IDs in cache."

# Fetch N random images
for a in $( seq 1 $1 )
do
	echo "Fetching image $a of $1..."
	
	# Pick a random ID from the cached list of valid IDs
	rnd_index=$((RANDOM % ${#valid_ids[@]}))
	rnd_id="${valid_ids[$rnd_index]}"
	padded_id=$(printf "%04d" $rnd_id)
	
	# Example wget query: wget https://earthview.withgoogle.com/download/1734.jpg ;
	# Happily, wget saves nothing if nothing is found (404); so the following will only save valid images:
		# DEPRECATED; NO LONGER ONLINE:
		# query_URL="https://earthview.withgoogle.com/download/""$padded_id"".jpg"
	# UPDATED url for where the set has been moved to:
	query_URL="https://www.gstatic.com/prettyearth/assets/full/""$padded_id"".jpg"
	
	# Only download if not already present
	if [ ! -e "$padded_id.jpg" ]; then
		wget $query_URL
		if [ $? -eq 0 ]; then
			echo "Downloaded: $padded_id.jpg"
			echo $padded_id >> rnd_withgoogle_earth_view_diff_avg_supercomposites-sh_query_log.txt
		else
			echo "Failed to download: $query_URL"
		fi
	else
		echo "File $padded_id.jpg already exists, skipping..."
	fi
	
	sleep 1  # Reduced from 3.1 since gstatic is more forgiving
done

echo "Download complete. Running composite script..."

diff_avg_supercomposites.sh
# OR TRY ALTERNATELY:
# diff_avg_supercomposites_nested_loop.sh