# DESCRIPTION
# Prints all directories in the current directory, and optionally all their subdirectories. Print is relative to the current directory (so sub-subdirectories etc. will show their parent, then /). Prints sorted by default sort of the `find` command.

# USAGE
# Call this script with these parameters:
# - $1 OPTIONAL. Any string (for example "FLORFELNAUT"), which will cause this script to _not_ search folders within subfolders (it will only search one level deep). If omitted, all folders in all subfolders (to whatever the depth limit of `find` is) will be listed.
# Example command to print folders of unlimited depth:
#    listAllSubdirs.sh
# Example command to search and print folder names only in the current directory (one level deep) for folders:
#    listAllSubdirs.sh FLORFELNAUT
# To call this from another script and create an array of the output, do:
# allSubdirectoriesArray=( $(listAllSubdirs.sh) )


# CODE
if [ "$1" ]; then subdirSearchCommand="-maxdepth 1"; fi

# previously added a `sort -n` pipe after find:
# find . $subdirSearchCommand -type d -printf "%P\n" | sort -n
find . $subdirSearchCommand -type d -printf "%P\n"