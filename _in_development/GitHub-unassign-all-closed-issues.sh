echo IN DEVELOPMENT.
exit

# DESCRIPTON
# Creates a bash array which is a list of the issue number of all closed issues in a GitHub repo,
# then iterates over the issue numbers to generate a command that unassigns all users from all
# closed issues.

# WHY?
# So that issue assignments are actually meaningful; so that I'm not "assigned"
# to hundreds of closed issues, where there's apparently no other batch facility for unassigning
# closed issues.

# DEPENDENCES
# hub (on Mac: brew install hub) (a CLI interface for the GitHub API), gsed (gnu gsed)

# CODE
# use the GitHub API to assign no users [] to the issue,
# re: https://hub.github.com/hub-api.1.html
# and re: https://developer.github.com/v3/issues/#edit-an-issue
# and re: https://developer.github.com/v3/issues/assignees/#remove-assignees-from-an-issue
# hub api repos/{owner}/{repo}/issues/$ISSUE --assignees [] 

# First create an array of closed issue numbers:
ARRAY=`hub issue -s closed | gsed 's/.*#\([0-9]\{1,\}\).*/\1/g'`

# Then unassign all users from all those issues:
for ISSUE in ${ARRAY[@]}
do
# TO DO: find a command +/ tool that unassigns everyone from an issue (all of the closed issues
# that will be listed by this loop).
  echo $ISSUE
done