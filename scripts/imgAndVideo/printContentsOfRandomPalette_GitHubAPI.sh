# DESCRIPTION
# Retrieves the contents of a random .hexplt file from the _ebPalettes repository (at GitHub) via the GitHub API. To do the same from a local copy of the repository, see `printContentsOfRandomPalette_ls.sh`.

# DEPENDENCIES
# - a current tree SHA of the current palettes subdirectory from the GitHub repository earthbound19/_ebPalettes, stored in your .bashrc file this way:
#    export EBPALETTES_PLT_DIR_SHA_TREE='the_actual_tree_SHA'
# -- where `the_actual_tree_SHA` is not that literal value, but is (as that placeholder text suggests) the actual tree SHA; re https://stackoverflow.com/a/2833142/1397555
# - a GitHub personal access token, usable with the API, re: https://github.com/settings/tokens -- stored in your .bashrc file this way:
#    export GITHUBAPIKEY=the_actual_API_token
# -- where `the_actual_API_token` is not that literal value, but is the actual API key.
# You'll also need:
# - jq installed and in your PATH

# DETAILS ON DEPENDENCIES
# - The tree SHA updates every time there's a change to anything in the /palettes subfolder (apparently) of the _ebPalettes repository. To obtain that, from the root of a cloned _ebPalettes repository, run this command:
#    git rev-parse master:palettes
# SEE also ebPalettes/setBASHRC_palettesTreeHash.sh to automatically update that when it's changed.
# Also note that from any folder in the _ebPalettes repository, you may type:
#    git ls-tree HEAD
# -- to get any other tree SHA you may wish to use (and set in EBPALETTES_PLT_DIR_SHA_TREE) from a current checkout out git state/branch.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Anything, for example the word THURF, which will cause this script to write the contents of a randomly retrieved palette to a file with the same name as what the palette is stored in. If omitted, only the contents of the file print to stdout (the terminal screen).
# For example, to retrieve and print to stdout (the terminal) the colors of a randomly selected palette, run:
#    printContentsOfRandomPalette_GitHubAPI.sh
# Or for example to retrieve the colors of a randomly selected palette and write them to the same file name the palette is associated with, run:
#    printContentsOfRandomPalette_GitHubAPI.sh THURF
# NOTE: original sources of any palette may have comments or layout markup in addition to sRGB hex color codes, but this script parses a retrieved source and prints only the color codes (eliminating anything else), one per line. If you want those comments etc., hack the script to remove this pipe to grep from the color retrieval command: | grep -i -o '#[0-9a-f]\{6\}


# CODE
# Uncomment the following to override the global (expected to have exported from .bashrc into the environment of this script); for example for testing: a subfolder with fewer palettes and another subfolder in it:
# EBPALETTES_PLT_DIR_SHA_TREE=df2fcfd22e637da93f34d4bc33eaa7124e0fca66

# Retrieve the entire directory contents of the palettes subdir, re https://docs.github.com/en/rest/git/trees?apiVersion=2022-11-28#get-a-tree -- adding the ?recursive=1 API parameter -- and store it in a variable; printing feedback to /dev/null:
PALETTES_TREE=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUBAPIKEY"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/earthbound19/_ebPalettes/git/trees/$EBPALETTES_PLT_DIR_SHA_TREE?recursive=1 )

# Check that grep of result for the string "Bad credentials" (meaning I can't access the API) *fails*, and if it succeeds, exit with error:
echo $PALETTES_TREE | grep ': "Bad credentials'
if [[ $? == 0 ]]; then echo "ERROR: bad credentials. Make sure that GITHUBAPIKEY is set and a valid token, as described in comments of this script. Exit."; exit 1; fi

# Otherwise it will continue:
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
