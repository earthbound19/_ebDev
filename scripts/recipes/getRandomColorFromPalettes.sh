# DESCRIPTION
# Pretty wasteful way to retrieve one random color from among all colors in the _ebPalette repository, but what if you want to do that? :) Uses other scripts to do so. Prints the selected color to stdout.

# DEPENDENCIES
# printContentsOfRandomPalette_ls.sh OR printContentsOfRandomPalette_GitHubAPI.sh (the former default, the latter hackable to use)

# USAGE
# Run without any parameters:
#    getRandomColorFromPalettes.sh
# NOTES
# To retrieve the palette file name see notes under USAGE in printContentsOfRandomPalette_ls.sh. Note that this calls a script that will get that via `source` per the notes there.

# CODE
# print only one randomly chosen color from the palette this way; print the contents of that randomly chosen palette, pipe that to the shuffle command, and pipe that to a command that prints the first line:
source printContentsOfRandomPalette_ls.sh | cat $pathToPalette | shuf | head -n 1