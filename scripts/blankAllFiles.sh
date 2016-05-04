# DESCRIPTION: Wipe the contents of all files in a given path (including subfolders), making them null or zero byte files. This dangerous code must be uncommented to accomplish this; as this is "shipped" with the whole control block commented out for safety.

# LICENSE: I wrote and I release this to the Public Domain. 02/21/2016 04:23:24 PM Richard Alexander Hall

# UNCOMMENT THE FOLLOWING BLOCK TO ACTIVATE THIS SCRIPT; it is commented out for safety.
	# List all files matching a specific date file name pattern to a file:to a text file

# !!===============DANGER ZONE===============!!
thisDir=`pwd`
find $thisDir/ -type f > allFiles.txt
while read p
do
	rm "$p"
	dd count=0 if=/dev/zero of="$p"
done < allFiles.txt
rm allFiles.txt
# !!===============DANGER ZONE===============!!

# Version history:
# Wrote this script, which it turns out has a bug [unknown when].
# Updated with a much simpler command to empty files (it didn't always work before now; now it does). 02/21/2016 08:20:22 PM PM -RAH