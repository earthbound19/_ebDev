# DESCRIPTION
# Prints only line additions of git diff of the most previous and current commit, chopping off the resulting lead characters '+# ' as well.

# USAGE
# Run without any parameters:
#    printGitDiffMostRecentAndCurrentCommit.sh


# CODE
# re: https://stackoverflow.com/questions/18810623/git-diff-to-show-only-lines-that-have-been-modified -- tweaked to remove '+' from the start of lines:
git diff HEAD^ HEAD -U0 | grep '^[+]' | grep -Ev '^(--- a/|\+\+\+ b/)' | sed 's/^+//g'