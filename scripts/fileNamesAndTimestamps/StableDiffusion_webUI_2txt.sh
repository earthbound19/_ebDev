# DESCRIPTION
# Very special purpose extract of PNG metadata as embedded by StableDiffusion_webUI () to metadata text files for reference. Specifically, to sort of match the metadata format of files made by stable-diffusion-ui, which is a different but similarly named (and purposed) thing.

# SEE
# https://github.com/AUTOMATIC1111/stable-diffusion-webui
# https://www.nayuki.io/page/png-file-chunk-inspector
# https://github.com/cmdr2/stable-diffusion-ui

# DEPENDENCIES
# PNG files in the current directory, which are renders stable-diffusion-ui, with non-standard PNG block metadata.

# USAGE
# Run without any parameters:
#    StableDiffusion_webUI_2txt.sh
# Resulting files will have the same base file name as the source file, but with the .txt extension.
# NOTE:
# This works on a perhaps faulty assumption that everything after "Parameters" and before "\nSteps" is the prompt. That's the best I can do with metadata that doesn't label one of the attributes (the prompt). Also, if there's a negative prompt, it's tacked on to the prompt without a space, as a result of this.

# CODE
srcFiles=($(find . -maxdepth 1 -type f -iname \*.png -printf "%P\n"))
for file in ${srcFiles[@]}
do
	metadataTargetFileName=${file%.*}".txt"
	metadataString=$(exiftool -Parameters $file)
	# only write to metadata target if it does not exist; otherwise skip and warn (don't clobber) :
	if [ ! -f $metadataTargetFileName ]
	then
		echo "Working on $file . . ."
		# write first line of metadata to file; it's weird that it prints ellipses between tag names; the . in front of .Steps eliminates part of an ellipses I don't want:
		echo $metadataString | sed 's/^Parameters[ :]\{0,\}\(.*\).Steps: .*/Prompt: \1/gI' > $metadataTargetFileName
		# get label/value pair section of metadata:
		keysValues=$(echo $metadataString | sed 's/^Parameters[ :]\{0,\}\(.*\)\(Steps: .*\)/\2/gI')
		# break those into newlines on commas and append to metadata file -- with a sed call to delete spaces from start of line:
		echo $keysValues | tr ',' '\n' | sed 's/^ //g' >> $metadataTargetFileName
	else
		printf "WARNING: metadata target $metadataTargetFileName already exists; will not clobber. Skip.\n\n"
	fi
done

echo DONE.