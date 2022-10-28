# DESCRIPTION
# Extracts sampler method, CFG, and steps from metadata of Stable Diffusion renders, from all file types $1 in the current directory, and prints them with the file name in csv format. May only work from a custom metadata setup I have. To get seeds from metadata, see stableDiffusionRenderGetSeedsFromMetadata.sh.

# USAGE
# Run with these parameters:
# - $1 file type to scan all files in the current directory for render method metadata
# For example, if the metadata is stored in .jpg images, run:
#    stableDiffusionRenderGetCoreParametersFromMetadata.sh jpg


# CODE
if [ "$1" ]; then srcFileType=$1; else printf "\nNo parameter \$1 (file type to scan all files in the current directory for render method metadata) passed to script. Exit."; exit 1; fi

srcFiles=($(find . -maxdepth 1 -iname \*.$srcFileType -printf "%P\n"))

echo "Sampler,Steps,CFG"
for srcFile in ${srcFiles[@]}
do
	sampleMethodFromMetadata=($(exiftool $srcFile | sed -n 's/.*Sampler: \([^.]\{0,\}\)\,..*/\1/p'))
	# because that can be an array (because there can be more than one line/field of metadata giving the Sampler method), reduce that to only the first one via array subscripting:
	sampleMethodFromMetadata=${sampleMethodFromMetadata[0]}

	stepsFromMetadata=($(exiftool $srcFile | sed -n 's/.*Steps: \([^,]\{0,\}\)\,.*/\1/p'))
	stepsFromMetadata=${stepsFromMetadata[0]}

	CFGfromMetadata=($(exiftool $srcFile | sed -n 's/.*CFG scale: \([^,]\{0,\}\)\,.*/\1/p'))
	CFGfromMetadata=${CFGfromMetadata[0]}

	echo $sampleMethodFromMetadata,$stepsFromMetadata,$CFGfromMetadata
done