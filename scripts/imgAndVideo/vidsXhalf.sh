# DESCRIPTION
# Makes half-resolution re-encodings (but copies audio streams -- does not re-encode audio) of all supported video types in the current directory. Does this by calling vidXhalf.sh once for every supported video type in the current directory. Note this is vidS~ (plural) where that script is vid~.

# USAGE
# Run with one optional parameter:
# - $1 OPTIONAL. Anything, such as the word FROURBELF, which causes the script to operate on all supported video file types in all subdirectories in the current directory. If omitted, only operates on the files in the current directory.
# For example, to only operate on videos in the current directory, run without any parameters:
#    vidsXhalf.sh
# Or to operate on all supported files in all subdirectories also, run:
#    vidsXhalf.sh FROURBELF


# CODE
if [ "$1" ]; then subDirSearchParam="FROURBELF"; fi
# if no parameter $1 is passed, then subDirSearchParam isn't defined by the previous line (code block), so attempts to print the content of any such variable return empty, and it's effectively not passed in the following call:
mediaList=$(printAllVideoFileNames.sh "$subDirSearchParam")

for file in ${mediaList[@]}
do
	vidXhalf.sh $file
done