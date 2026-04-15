# DESCRIPTION
# Extracts seeds from metadata of Stable Diffusion renders, from all file types $1 in the current directory, and prints them. May only work from a custom metadata setup I have. To get sample methods from metadata, see stableDiffusionRenderGetSamplerMethodFromMetadata.sh.

# USAGE
# Run with these parameters:
# - $1 file type to scan all files in the current directory for render method metadata
# For example, if the metadata is stored in .jpg images, run:
#    stableDiffusionRenderGetSamplerMethodFromMetadata.sh jpg

# CODE
if [ "$1" ]; then srcFileType=$1; else printf "\nNo parameter \$1 (file type to scan all files in the current directory for render method metadata) passed to script. Exit."; exit 1; fi

exiftool "*.$srcFileType" | sed -n 's/.*, Seed: \([^,]\{0,\}\)\,.*/\1/p'
