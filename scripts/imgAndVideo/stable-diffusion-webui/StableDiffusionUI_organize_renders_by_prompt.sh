# DESCRIPTION
# Finds all unique prompts from metadata files (from renders from Stable Diffusion UI), and groups them and their accompanying renders into unique sobfolder names by prompt. Result: all renders and metadata that have the same prompt are in their own unique folders.

# DEPENDENCIES
# - A folder with metadata and render files to run this script against, resulting from use of https://github.com/cmdr2/stable-diffusion-ui/
# - Other scripts from _ebDev which this script uses, which scripts must be in your PATH.

# WARNINGS
# MORE really important notes; SEE.

# USAGE
# SEE NOTES.
# First, if txt metadata sidecars do not have the text to image synthesis prompt explicitly labeled as "Prompt: ", remedy that, as follows.
# FOR STABLE-DIFFUSION-UI, from a directory full of renders and .txt metadata sidecars (that have the same base file name as the .png files), run this script with one parameter, which can be anything, for example the word HYAERF:
#    StableDiffusionUI_organize_renders_by_prompt.sh HYAERF
# -- which will cause the script to reformat all .txt sidecars with the required "Prompt: " tag at the start of the first line (assumed to be the prompt). This will prepare them for running this script with no parameter, to organize them.
# FOR STABLE-DIFFUSION-WEBUI, from a directory full of render .pngs, first run another script:
#    StableDiffusion_webUI_2txt.sh
# -- which will cause the script to create .txt metadata sidecars with corresponding base file names for pngs.
# WITH THOSE CRITERIA met for either or both circumstances:
# From a directory of renders, run this script with no parameters:
#    StableDiffusionUI_organize_renders_by_prompt.sh
# This will organize images and prompts into folders as described.
# NOTES
# This script requires the following for metadata format:
# - All files of type .txt are prompt metadata files.
# - The data for a prompt begins at the start of the first line of a metadata file, and ends at the end of that line (at the newline). This is not ideal; this is necessarily hacky.
# - Any negative prompt, tagged "Negative prompt: " is on the first line with the (positive) prompt. It would be ideal to signal both the start of a prompt with a label like "Prompt: ", and the same for a negative prompt, but as we have neither, they are both going on the first line, yet with a label for the negative prompt. The reason for this first and second rule (and notes) is that at this writing, both stable-diffusion-webUI (in PNG block metadata) and stable-diffusion-ui both put labels with a colon on all data _except_ the prompt. Which, frankly, is just bad and inconsistent data recording and standards. Thus the need for this hacky data standard for this script. Which, as a hack, works, because both do put the prompt on the first line of metadata.
# - Although in testing it has been found to be safe to put newlines in prompts (it maintains the same deterministic Stable Diffusion output), that breaks the previous requirement, so it is not allowed. Therefore, if your metadata has newlines in the prompt, take them out. It will give exactly the same result without them.
# - works only for files in the current directory (not recursive).
# - for any of these operations to work on the files, you may need to rename the files to have terminal-friendly characters only, via ftun.sh.
# KNOWN ISSUES
# This script is inefficient, looping over many files twice.

# CODE
# TO DO:
# recurse through subdirectories and perform core function??

# Make array of all .txt files:
allMetaDataFiles=($(find . -type f -iname \*.txt))

if [ "$1" ]
then
	echo 'Will attempt to reformat all .txt metadata (sidecar) files in the current directory to have the required "Prompt: " tag.'
	for metaDataFile in ${allMetaDataFiles[@]}
	do
		echo working on file $metaDataFile . . .
		sed -i -e '1 s/^/Prompt: /' $metaDataFile
	done
	echo DONE.
	exit 0
fi

# sets/changes a global variable rndStr:
function setRNDstr {
   RNDstr=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 8)
}

prompts_collection_file_name=StableDiffusionUI_prompts.md
printf "" > $prompts_collection_file_name
echo scanning metadata files . . .
counter=1
for metaDataFile in ${allMetaDataFiles[@]}
do
	# grab first line, which standards say must be the prompt:
	sed -n '1p' $metaDataFile >> $prompts_collection_file_name
	counter=$((counter + 1))
done
# remove any starting tag of "Prompt: " from the prompts collection, which could be there if it's added by calling this script with one parameter:
sed -i 's/^prompt[\: ]\{0,\}//gI' $prompts_collection_file_name
# Reduce that to unique entries:
OIFS="$IFS"
IFS=$'\n'
prompts=($(sort $prompts_collection_file_name | uniq))
# write final sorted list of unique prompts back to file:
printf '%s\n' "${prompts[@]}" > $prompts_collection_file_name

for prompt in ${prompts[@]}
do
	setRNDstr
	# make file system-friendly copy of prompt string before shortening it for use in a folder name; the \\\\ is to escape a backslash:
	fileSystemFriendlyPrompt=$(echo $prompt | tr /\\\\\"\'\=\@\`~\!#$%^\&\(\)+[{]}\;\ ,. _)
	abridgedUnlabeledPrompt=${fileSystemFriendlyPrompt:0:40}
	sortFolderName="$abridgedUnlabeledPrompt"_"$RNDstr"
	mkdir $sortFolderName
	# write prompt to a markdown file in sorting subfolder for more handy reference (markdown to avoid mixing .txt files I don't want with metadata .txt files) :
	printf "# Prompt grouping folder\n\nAll of the media in this folder is related to the following image synthesis prompt:\n\n$prompt" > ./$sortFolderName/PROMPT.md

	printf "\n~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-"
	printf "\nSorting image and metadata files for prompt:\n\n$prompt"
	for file in ${allMetaDataFiles[@]}
	do
		# comparison_prompt=$(sed -n '1p' $file)
		# ^ use that, but add a filter out of the phrase "prompt: " at the start of that:
		comparison_prompt=$(sed -n '1s/^prompt: //pI' $file)
		if [ "$comparison_prompt" == "$prompt" ]
		then
			printf "\n\nPrompt match for file $file, attempting to move it and related files into sort folder \n\n$sortFolderName . . ."
			matchedFiles=($(listMatchedFileNames.sh $file))
			for matchedFile in ${matchedFiles[@]}
			do
				mv $matchedFile ./$sortFolderName
				# prevent redundant file move attempts on successive loops by removing the file from the array, effectively: change the array to a copy of itself with everything but that element, by printing everything but that element and assigning that to the array itself, re: https://linuxhint.com/remove-specific-array-element-bash/
				allMetaDataFiles=("${allMetaDataFiles[@]/$file}")
			done
		fi
	done
done
IFS="$OIFS"

echo DONE. Unique prompts are listed in $prompts_collection_file_name.