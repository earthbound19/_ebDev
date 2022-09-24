# DESCRIPTION
# Finds all unique prompts from metadata logs of Stable Diffusion UI, and groups them and their accompanying renders into unique sobfolder names by prompt. Result: all renders and metadata that have the same prompt are in their own unique folders.

# DEPENDENCIES
# - A folder with metadata and render files resulting from use of https://github.com/cmdr2/stable-diffusion-ui/ to run this script against.
# - Other scripts from _ebDev which this script uses, which scripts must be in your PATH.

# WARNINGS
# This script perhaps erroneously assumes the following:
# - all files of type .txt are prompt metadata files
# - everything up to a start of a new line containing the phrase (and punctuation) "Width: " is the prompt.
# - it is safe to replace newlines in prompts with spaces. In tests this maintains the same deterministic Stable Diffusion output. So, while it can technically alters prompts, it does not functionally alter them.

# USAGE
# From a directory of renders, run the script:
#    StableDiffusionUI_organize_renders_by_prompt.sh
# NOTE
# Works only for files in the current directory (not recursive).
# KNOWN ISSUES
# This script is inefficient, looping over all the same files twice.

# CODE
# TO DO:
# recurse through subdirectories and perform core function??
# Make array of all .txt files:
allMetaDataFiles=($(find . -type f -iname \*.txt))

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
	printf "$counter..."
	# reformat prompt from file for adding to prompt collection file; remove newlines for processing:
	reformattedPrompt=$(cat $metaDataFile | tr -d '\n' | tr -d '\15\32')
	echo $reformattedPrompt >> $prompts_collection_file_name
	counter=$((counter + 1))
done
# remove any starting tag of "Prompt: " from the prompts (which could be there because I can add it to metadata files with a script, to indicate it for wedging it into non-standard metadata that doesn't have field labels); this pattern requires it to be at the start, has ':' and ' ' after it optional, and is case-insensitive:
sed -i 's/^prompt[\: ]\{0,\}//gI' $prompts_collection_file_name
# remove trailing things I don't want:
sed -i -n "s/\(.*\).*Width: .*/\1/p" $prompts_collection_file_name

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

	printf "\n\n~\nSorting image and metadata files for prompt:\n\n$prompt"
	for file in ${allMetaDataFiles[@]}
	do
		# reformat what's in the file into a variable structured the same as when they were all written to a file before:
		comparison_prompt=$(cat $file | tr -d '\n' | tr -d '\15\32')
		comparison_prompt=$(sed -n "s/\(.*\).*Width: .*/\1/p" <<< $comparison_prompt)
		comparison_prompt=$(echo $comparison_prompt | sed 's/^prompt[\: ]\{0,\}//gI')
#echo $comparison_prompt
#printf ".........\n"
#echo $prompt
#print "\n\n"
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