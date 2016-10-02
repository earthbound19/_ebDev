# Lists all files that have the tag FINAL in them:
# find . -type f -iregex '.*FINAL.*'

# OPTION that severs the paths off the start of the result:
find . -type f -iregex '.*FINAL.*' | sed 's/.*\/\(.*\)/\1/g'