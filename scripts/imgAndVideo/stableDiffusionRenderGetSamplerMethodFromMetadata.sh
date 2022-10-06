# DESCRIPTION
# Extracts sampler method from metadata of Stable Diffusion renders, from all file types $1 in the current directory, and prints them with the file name in csv format "Sampler method:filename". May only work from a custom metadata setup I have. To get seeds from metadata, see stableDiffusionRenderGetSeedsFromMetadata.sh.

# USAGE
# Run with these parameters:
# - $1 file type to scan all files in the current directory for render method metadata
# For example, if the metadata is stored in .jpg images, run:
#    stableDiffusionRenderGetSamplerMethodFromMetadata.sh jpg
# NOTE: if you're not concerned with printing file names, you can far more quickly print all sampler methods wit this command, assuming you're searching through png files metadata:
#    exiftool "*.png" | sed -n 's/.*Sampler: \([^,]\{0,\}\)\,.*/\1/p'


# CODE
if [ "$1" ]; then srcFileType=$1; else printf "\nNo parameter \$1 (file type to scan all files in the current directory for render method metadata) passed to script. Exit."; exit 1; fi

srcFiles=($(find . -maxdepth 1 -iname \*.$srcFileType -printf "%P\n"))
for srcFile in ${srcFiles[@]}
do
	sampleMethodFromMetadata=($(exiftool $srcFile | sed -n 's/.*Sampler: \([^.]\{0,\}\)\..*/\1/p'))
	# because that can be an array (because there can be more than one line/field of metadata giving the Sampler method), print only the first one via array subscripting; it will be the same as the second if there is more than one; although just "printing" the array might also always only print the first element:
	printf "${sampleMethodFromMetadata[0]}:$srcFile\n"
done