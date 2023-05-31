# DESCRIPTION
# Makes data bent art from a diff of the most recent and current commits in a git repository, via other scripts.

# DEPENDENCIES
# `printGitDiffMostRecentAndCurrentCommit.sh`
# `data_bend_2PPMglitchArt00padded.sh`

# USAGE
# Run without any parameters:
#    dataBendGitDiffMostRecentAndCurrentCommit.sh


# CODE
# TO DO: add check that tells whether a git command will work (whether we are in fact in the path of a functioning git repository).

printGitDiffMostRecentAndCurrentCommit.sh > gitDiffMostRecentAndCurrentCommit_data_bent.txt
data_bend_2PPMglitchArt00padded.sh gitDiffMostRecentAndCurrentCommit_data_bent.txt
# remove temp intermediary:
rm gitDiffMostRecentAndCurrentCommit_data_bent.txt
# that data bend script ran resulted in the file gitDiffMostRecentAndCurrentCommit_data_bent_asPPM.ppm; convert it to png:
img2imgNN.sh gitDiffMostRecentAndCurrentCommit_data_bent_asPPM.ppm png 1200

printf "\nDONE. Result files are gitDiffMostRecentAndCurrentCommit_data_bent_asPPM.ppm and gitDiffMostRecentAndCurrentCommit_data_bent_asPPM.png.\n"