# DESCRIPTION
# Extracts sampler method from metadata of Stable Diffusion renders, from all file types $1 in the current directory, and prints them with the file name. May only work from a custom metadata setup I have.

# USAGE
# Run with these parameters:
# - $1 file type to scan all files in the current directory for render method metadata
# For example, if the metadata is stored in .jpg images, run:
#    stableDiffusionRenderGetSamplerMethodFromMetadata.sh jpg


# CODE
if [ "$1" ]; then srcFileType=$1; else printf "\nNo parameter \$1 (file type to scan all files in the current directory for render method metadata) passed to script. Exit."; exit 1; fi

srcFiles=($(find . -maxdepth 1 -iname \*.$srcFileType -printf "%P\n"))
for srcFile in ${srcFiles[@]}
do
	sampleMethodFromMetadata=$(exiftool $srcFile | sed -n 's/.*Sampler: \([^.]\{0,\}\)\..*/\1/p')
	printf "SOURCE FILE: $srcFile -- METHOD: $sampleMethodFromMetadata\n"
	printf "\n"
done