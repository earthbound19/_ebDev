# DESCRIPTION
# Fetches N random images from earthview.withgoogle.com and runs `diff_avg_supercomposites.sh`.

# USAGE
# Run with one parameter, which is how many random images you want to retrieve before this script calls diff_avg_supercomposites_nested_loop.sh; for example:
#    rnd_withgoogle_earth_view_diff_avg_supercomposites.sh 12
# NOTES
# - Unless you intend for images other than what this script retrieves to be supercompositied, you probably best run this script from an empty, new project folder.
# - If you alternately want to run `diff_avg_supercomposites_nested_loop.sh` after image colleciton instead, comment out the line for `.sh`, and uncomment the line for the other option.
# - Some image numbers in the constructed URLs this script makes may not be available. If you don't get enough images, cancel the script run and try again.


# CODE

for a in $( seq 1 $1 )
do
echo is $a
	rndNum=$(shuf -i 1003-7023 -n 1)
	padded_id=$(printf "%04d" $rndNum)
	# Example wget query: wget https://earthview.withgoogle.com/download/1734.jpg ;
	# Happily, wget saves nothing if nothing is found (404); so the following will only save valid images:
	query_URL="https://earthview.withgoogle.com/download/""$padded_id"".jpg"
	wget $query_URL
	sleep 3.1
	echo $padded_id > rnd_withgoogle_earth_view_diff_avg_supercomposites-sh_query_log.txt
done

diff_avg_supercomposites.sh
# OR TRY ALTERNATELY:
# diff_avg_supercomposites_nested_loop.sh