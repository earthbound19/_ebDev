# DESCRIPTION
# Retrieves the contents of a random .hexplt file from the _ebPalettes repository (at GitHub) via the GitHub API. To do the same from a local copy of the repository, see `printContentsOfRandomPalette_ls.sh`.

# DEPENDENCIES
# - A hard-coded current tree SHA of the current palettes subdirectory from the repository https://github.com/earthbound19/_ebPalettes/tree/master/palettes -- re: https://stackoverflow.com/a/2833142/1397555
# - jq
# - a GitHub personal access token (usable with the API) -- re: https://github.com/settings/tokens -- stored in your .bashrc file this way, where `the_actual_API_token` is not that literal value, but is (as that placeholder text suggests) the actual API key:
#    export GITHUBAPIKEY=the_actual_API_token
# git (for obtaining hash info of a folder if you wish to update or change a hard-coded variable)

# USAGE
# - Set the global variable SHA_TREE to the hash of a folder for which you wish to retrieve all .hexplt files via API call (to randomly select one of them). One for the final/production /palettes subfolder is hard coded already. To obtain that (if it changes) or any other, from the root of a cloned _ebPalettes repository, run this command:
# Run without any parameters:
#    printContentsOfRandomPalette_GitHubAPI.sh


# CODE
# UNCOMMENT ONLY ONE of the following SHA_TREE options:
# for testing: a subfolder with fewer palettes and another subfolder in it:
# SHA_TREE=df2fcfd22e637da93f34d4bc33eaa7124e0fca66
# for production: the whole palettes subfolder:
SHA_TREE=0688719693baf392fa3c03d7830d1ee2e0f513a3

# Retrieve the entire directory contents of the palettes subdir, re https://docs.github.com/en/rest/git/trees?apiVersion=2022-11-28#get-a-tree -- adding the ?recursive=1 API parameter -- and store it in a $JSON variable; printing feedback to /dev/null:
JSON=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUBAPIKEY"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/earthbound19/_ebPalettes/git/trees/$SHA_TREE?recursive=1 )
# filter JSON to only objects whose paths contain .hexplt, and print the .sha of those; the -r removes the quote marks from around the value:
FILTERED_JSON=( $(jq -r '.tree[] | select(.path | contains(".hexplt")) .sha' <<< $JSON | tr -d '\15\32') )

# dev print test of that array:
# for field in ${FILTERED_JSON[@]}
# do
	# echo feee $field FLEIJFIF
# done

# shuffle the array in print and print only first line:
BLOB_OF_RND_SELECTION=$(printf '%s\n' ${FILTERED_JSON[@]} | shuf | head -n 1)

# - get an rnd SHA from that
# - with that SHA, get the base64-encoded content of it via the following, re: # https://docs.github.com/en/rest/git/blobs?apiVersion=2022-11-28#get-a-blob
JSON=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUBAPIKEY"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/earthbound19/_ebPalettes/git/blobs/$BLOB_OF_RND_SELECTION)

# -- and convert the base64-encoded to binary; filter everything other the sRGB hex color codes out of that via grep, and print it! :
jq -r '.content' <<< $JSON | base64 -d -i | grep -i -o '#[0-9a-f]\{6\}'