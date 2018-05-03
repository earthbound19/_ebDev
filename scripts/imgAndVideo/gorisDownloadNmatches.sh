# DESCRIPTION
# Wrapper for goris Google Reverse Image Search CLI tool. Downloads N (from parameter $2) images matching or near matching file $1. See NOTES for details on where results and the original image are moved/saved to. SEE ALSO gorisDownloadNmatchesType.sh and the comments therein.

# USAGE
# Invoke this script with two parameters, the second optional (and it will default to 10 if not provided):
# $1 imageFile to perform a Google Reverse Image search for.
# $2 How many matches or near matches of that file to download.
# Example that searches for imageFile.png and downloads the 6 top matches:
# ./thisScript.sh imageFile.png 6

# NOTES
# Because the CLI tool this wraps downloads all matches to the current directory--which could clutter up your workspace fast--this script organizes search result downloads per the echo information at the end of this script.

# KNOWN ISSUES
# The API this relies on has a number of downloads limit per day (100, I read). I believe the error you'll see when this is hit is "panic: runtime error: invalid memory address or nil pointer dereference--" which tells nothing direct about hitting the limit. Also, even before you hit that limit, it may not download the full number of images you specify. Maybe Google throttles the API?


# CODE

# If no parameter $2 passed to script, set a default value:

# ====
# BEGIN SETUP GLOBALS
fileName=$1

if [ -z ${2+x} ]
then
	numberToDownload=7
else
	numberToDownload=$2
fi
echo numberToDownload is $numberToDownload
# END SETUP GLOBALS
# ====

# Get the filename from $1, minus the file extension:
		# To append to the next command between backticks `` if cygwin mangles variables by using windows linefeeds:  | tr -d '\15\32'
fileNameNoExt=`rev <<< "$1" | cut -d"." -f2- | rev `
		# echo filenameNoExt is\: $fileNameNoExt

goris_matches_subdir=$fileNameNoExt
		# echo goris_matches_subdir is $goris_matches_subdir
# Create a directory named after the file, only if it doesn't already exist:
if [ ! -d $goris_matches_subdir ]; then mkdir $goris_matches_subdir; fi
# Move into that directory and execute a reverse image search and download for $1 (which will be one directory up) :
		pushd .
cd $goris_matches_subdir
goris search --fromfile "../$1" --number $numberToDownload --download

exit
# create a matches sub-subdir, and move matches into it:
mkdir _goris_matches
cd _goris_matches
mv ../* .

# move search image file into this subdir:
cd ..
mv "../$1" .

popd

echo DONE. The search image was moved into the a new $gorisDownloadNmatchesThe subdirectory\, with the search results below that in ./$goris_matches_subdir/matches, for easy reference.