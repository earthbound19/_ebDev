# DESCRIPTION
# Runs toTypeFolder.sh for every file of every type in the current directory, and optionally also for all subdirectories.

# USAGE
# Run with or without an optional parameter:
# - $1 OPTIONAL. Any string (for example 'FLIBFLUB'), which will cause the script to search subfolders also for all files of all types.
# Example that will sort all files of every discovered extension from the current directory (for example txt and png) into subdirectories named after those types (for example '/txt' and '/png') :
#    allToTypeFolders.sh
# Example that will sort all files of every discovered extension from the current directory _and_ subdirectories (for example txt, hexplt and png) into subdirectories named after those types (for example '/txt', '/hexplt' and '/png') :
#    allToTypeFolders.sh FLIBFLUB


# CODE
# list all directories in path.
optionalParam=''
# Override that if $1 exists:
if [ "$1" ]; then optionalParam='FLIBFLUB'; fi

allFileTypes=( $(printAllFileTypes.sh $optionalParam) )
for fileType in ${allFileTypes[@]}
do
	toTypeFolder.sh $fileType $optionalParam
done