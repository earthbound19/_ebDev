# DESCRIPTION
# Wrapper for goris Google Reverse Image Search CLI tool. Downloads N (from parameter $2) images matching or near matching file $1. See NOTES for details on where results and the original image are moved/saved to. SEE ALSO gorisDownloadNmatchesType.sh and the comments therein.

# KNOWN ISSUE
# The API this relies on has a number of downloads limit per day (100, I read). I believe the error you'll see when this is hit is "panic: runtime error: invalid memory address or nil pointer dereference--" which tells nothing direct about hitting the limit. Also, even before you hit that limit, it may not download the full number of images you specify. Maybe Google throttles the API?

# USAGE
# Run this script with these parameters:
# - $1 imageFile to perform a Google Reverse Image search for.
# - $2 OPTIONAL. How many matches or near matches of that file to download.
# Example that searches for imageFile.png and downloads the 6 top matches:
#    gorisDownloadNmatches.sh imageFile.png 6
# NOTE
# Because the CLI tool this wraps downloads all matches to the current directory--which could clutter up your workspace fast--this script organizes search result downloads per the echo information at the end of this script.


# CODE
# BEGIN SETUP GLOBALS
# Throw error and exit if no $1.
if ! [ "$1" ]; then printf "\nNo parameter \$1 (image file name) passed to script. Exit."; exit 1; else fileName=$1; fi

# If no parameter $2 passed to script, set a default value:
if [ -z "$2" ]
then
	numberToDownload=7
else
	numberToDownload=$2
fi
echo numberToDownload is $numberToDownload
# END SETUP GLOBALS

goris_matches_subdir=${1%.*}
		# echo goris_matches_subdir is $goris_matches_subdir
# Create a directory named after the file, only if it doesn't already exist:
if [ ! -d $goris_matches_subdir ]; then mkdir $goris_matches_subdir; fi
# Move into that directory and execute a reverse image search and download for $1 (which will be one directory up) :
		pushd . >/dev/null
cd $goris_matches_subdir
		echo "Working in directory: $goris_matches_subdir . . ."
goris search --fromfile "../$1" --number $numberToDownload --download

exit
# create a matches sub-subdir, and move matches into it:
mkdir _goris_matches
cd _goris_matches
mv ../* .

# move search image file into this subdir:
cd ..
mv "../$1" .

		popd >/dev/null

echo DONE. The search image was moved into the a new $gorisDownloadNmatchesThe subdirectory\, with the search results below that in ./$goris_matches_subdir/matches, for easy reference.