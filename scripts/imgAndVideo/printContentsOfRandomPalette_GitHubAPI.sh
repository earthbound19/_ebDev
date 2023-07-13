# DESCRIPTION
# Retrieves the contents of a random .hexplt file from the _ebPalettes repository (at GitHub) via the GitHub API. To do the same from a local copy of the repository, see `printContentsOfRandomPalette_ls.sh`.

# DEPENDENCIES
# - A hard-coded current tree SHA of the current palettes subdirectory from the repository https://github.com/earthbound19/_ebPalettes/tree/master/palettes, as descrbied in USAGE. Re: https://stackoverflow.com/a/2833142/1397555
# - jq installed and in your PATH
# - a GitHub personal access token, usable with the API, re: https://github.com/settings/tokens -- stored in your .bashrc file this way, where `the_actual_API_token` is not that literal value, but is (as that placeholder text suggests) the actual API key:
#    export GITHUBAPIKEY=the_actual_API_token
# git (for obtaining hash info of a folder if you wish to update or change a hard-coded variable)

# USAGE PRECONDITIONS
# - Set the global variable SHA_TREE to the hash of a folder for which you wish to retrieve a list of all .hexplt files via API call (to randomly select one of them). The hash of the final/production /palettes subfolder is hard coded already. To obtain that (if it changes) or any other hash, from the root of a cloned _ebPalettes repository -- or from within any other subdirectory of the repository for which you wish to list the hashes of its subfolders -- run this command:
#    git ls-tree HEAD
# -- and copy the hash shown alongside the directory name you wish to obtain the hash for.
# - Set up a GitHub access token and store in .bashrc as detailed in DEPENDENCIES.
# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Anything, for example the word THURF, which will cause this script to write the contents of a randomly retrieved palette to a file with the same name as what the palette is stored in. If omitted, only the contents of the file print to stdout (the terminal screen).
# For example, to retrieve and print to stdout (the terminal) the colors of a randomly selected palette, run:
#    printContentsOfRandomPalette_GitHubAPI.sh
# Or for example to retrieve the colors of a randomly selected palette and write them to the same file name the palette is associated with, run:
#    printContentsOfRandomPalette_GitHubAPI.sh THURF
# NOTE: sources of any palette may have comments or layout markup in addition to sRGB hex color codes, but this script parses and prints only the color codes (eliminating anything else), one per line. If you want those comments etc., hack the script to remove this pipe to grep from the color retrieval command: | grep -i -o '#[0-9a-f]\{6\}

# CODE
# UNCOMMENT ONLY ONE of the following SHA_TREE options:
# for testing: a subfolder with fewer palettes and another subfolder in it:
# SHA_TREE=df2fcfd22e637da93f34d4bc33eaa7124e0fca66
# for production: the whole palettes subfolder:
SHA_TREE=0688719693baf392fa3c03d7830d1ee2e0f513a3

# Retrieve the entire directory contents of the palettes subdir, re https://docs.github.com/en/rest/git/trees?apiVersion=2022-11-28#get-a-tree -- adding the ?recursive=1 API parameter -- and store it in a variable; printing feedback to /dev/null:
PALETTES_TREE=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUBAPIKEY"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/earthbound19/_ebPalettes/git/trees/$SHA_TREE?recursive=1 )
# filter PALETTES_TREE to only objects whose paths contain .hexplt, and print the .sha of those; the -r removes the quote marks from around the value:
FILTERED_PALETTES_TREE=( $(jq -r '.tree[] | select(.path | contains(".hexplt")) .sha' <<< $PALETTES_TREE | tr -d '\15\32') )

# dev print test of that array:
# for field in ${FILTERED_PALETTES_TREE[@]}
# do
	# echo feee $field FLEIJFIF
# done

# shuffle the array in print and grab the first line of the shuffle:
RND_SELECTED_SHA=$(printf '%s\n' ${FILTERED_PALETTES_TREE[@]} | shuf | head -n 1)

# - with that SHA, get the base64-encoded content of it via the following, re: # https://docs.github.com/en/rest/git/blobs?apiVersion=2022-11-28#get-a-blob
BASE64_CONTENT=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUBAPIKEY"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/earthbound19/_ebPalettes/git/blobs/$RND_SELECTED_SHA)

# Convert the base64 encoding to binary; filter everything other than the sRGB hex color codes out of that via grep:
colors=$(jq -r '.content' <<< $BASE64_CONTENT | base64 -d -i | grep -i -o '#[0-9a-f]\{6\}')
# Write the colors out! Either to stdout or to the .hexplt file name the palette was originally stored in, depending on the existence of switch $1:
if [ "$1" ]
then
	# get the path (file name) assocaited with that randomly selected SHA (where the SHAs were filtered to .hexplt paths to begin with) :
	PATH=$(jq -r ".tree[] | select(.sha | contains(\"$RND_SELECTED_SHA\")) .path" <<< $PALETTES_TREE | tr -d '\15\32')
	# trim any folder names off the start of that:
	PATH="${PATH##*/}"
	# check if the target file already exists, and write to it if it does not; otherwise notify it already exists and skip:
	if [ ! -f "$PATH" ]
	then
		printf "\nTarget file $PATH does not exist; will create and write palette colors to it."
		printf "$colors" > $PATH
	else
		printf "\nThe target file $PATH already exists. Skipping overwrite. The contents of the retrieved palette, for reference, are (after adding two newlines here) :"
		printf "\n\n$colors"
	fi
else
	printf "$colors"
fi
