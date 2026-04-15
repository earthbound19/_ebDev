# DESCRIPTION
# Via call of `stableDiffusionRenderGetSamplerMethodFromMetadata.sh` gets array of sampler type used for all images of type $1 in the current directory (from Stable Diffusion renders), then sorts the files into subfolders named after the sampler type.

# USAGE
# Run with the following parameters:
# - $1 OPTIONAL. File type of source renders. If omitted, defaults to png.
# For example, to use the default file type, run the script without any parameter:
#    stableDiffusionSortRendersIntoFoldersBySamplerType.sh
# Or to use a different file type, for example jpg, pass that as the first parameter:
#    stableDiffusionSortRendersIntoFoldersBySamplerType.sh jpg


# CODE
if [ "$1" ]; then srcFileType=$1; else srcFileType=png ; fi

echo building array via call of stableDiffusionRenderGetSamplerMethodFromMetadata.sh . . .
samplerTypesAndFileNamesArray=($(stableDiffusionRenderGetSamplerMethodFromMetadata.sh $srcFileType))

for element in ${samplerTypesAndFileNamesArray[@]}
do
	sampleMethod=$(echo $element | sed 's/\([^:]\{0,\}\).*/\1/g')
	fileName=$(echo $element | sed 's/.*:\([^:]\{0,\}\)/\1/g')
	echo sampleMethod is $sampleMethod
	echo fileName is $fileName
	# Totally inefficient but in case sampler methods evolve, I'm checking for a folder named after it and creating it if it doesn't exist, on every loop; also replacing any spaces with underscores first:
	sampleMethodTerminalFriendly=$(echo $sampleMethod | tr ' ' '_')
	if [ ! -d $sampleMethodTerminalFriendly ]; then mkdir $sampleMethodTerminalFriendly; fi
	# The actual file sort (move) :
	mv $fileName ./$sampleMethodTerminalFriendly/
done