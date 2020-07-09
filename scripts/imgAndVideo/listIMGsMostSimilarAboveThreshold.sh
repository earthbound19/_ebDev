# DESCRIPTION
# Lists pairs of images that are visually similar to each other above a threshold, $1. Operates on a file created by imgsGetSimilar.sh, which must be run before this, and creates a list of all image pairs in a directory ranked by nearness of similarity one to another. This script filters results from that above float parameter $1. See USAGE.

# USAGE
# First, run imgsGetSimilar.sh as instructred in its comments. This is necessary to create the file IMGlistByMostSimilarComparisons.txt, which this script relies on. Then run this, with one parameter, being a float value between 0 and 1. Image pairs that have a nearness comparison value above that float will be written to a new file: IMGlistSimilarComparisonsAboveThreshold
# Example invocation that will list every pair where the nearness value is 9.4 or higher:
#  listIMGsMostSimilarAboveThreshold.sh 9.4
# NOTES:
# - You can use any decimal precision you want, e.g. 4.2, 6.54, 9.874, etc.
# - After you have examined image pairs of a given nearness resulting from this filter, you may delete the second of every pair that is above that nearness threshold by running deleteIMGsMostSimilarAboveThreshold.sh.


# CODE
# See DEVELOPER NOTES comments at end of script.
sed -n "s/^\($1\)/\1/p" IMGlistByMostSimilarComparisons.txt > IMGlistSimilarComparisonsAboveThreshold.txt

printf "\nDONE. Examine IMGlistSimilarComparisonsAboveThreshold.txt, and if you're willing to delete every second image (for every pair) in it, run deleteIMGsMostSimilarAboveThreshold.sh."


# DEVELOPER NOTES
# sed stream editing example for my purposes here: if you have a text file tst.txt which has four lines starting with "weeb", and other lines that do not; like this:
# weeble
# wobble
# weeblet
# weeblor
# weeb
# waelf
# welf
# -- this sed command will not print lines that don't start with "weeb", and it will print the extracted lines beginning with 'weeb':
# sed -n "s/^\(weeb\)/\1/p" tst.txt
# That prints:
# weeble
# weeblet
# weeblor
# weeb