# DESCRIPTION
# Performs a series of preferred tasks for preparing metadata from/in stable-diffusion-webUI renders (or potentially renders from other sources):
# - terminal-friendly and short-path friendly render file renaming
# - metadata extraction to sidecars
# - organizing into subfolders by (Stable Diffision) prompt (the text that was given an AI to make the image)
# - creating web-friendly conversions and embedding prompt etc. metadata in them

# DEPENDENCIES
# The variety of scripts called in CODE (SEE) and their dependencies.

# USAGE
# From a folder that contains only png format files from stable-diffusion-webUI (or similar) renders, and no subfolders nor png files in any subfolders, run this script without any parameters:
#    organizeAndMetadataPrepStableDiffusionRenders.sh


# CODE
# terminal friendly renaming
ftun.sh png
# shorten the file names that are probably way too long; works for pngs alone even if they have no matching files of the same name:
shortenMatchedFileNames.sh png
# metadata extract from PNG data block to sidecar
StableDiffusion_webUI_2txt.sh
# organize renders into subfolders by prompt (the text that was given an AI to make the image):
StableDiffusionUI_organize_renders_by_prompt.sh
# make web-friendly jpg versions of all the renders:
imgs2imgs.sh png jpg NULL HOIHOI
# embed metadata in all those jpgs and also overwrite the original PNGs with the changed metadata format from sidecards:
txts2imgsMetadata.sh txt FLUPAR

echo "DONE. jpgs with metadata are alongside the original pngs. To prepare a folder structure by prompt with only the jpgs for web gallery publication (for web galleries that can make use of that), copy all the subfolders somewhere else, then delete all but the jpgs from the copy."