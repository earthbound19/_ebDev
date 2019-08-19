# CLEANS UP git local branches which have no remote
# CLEANS UP expired / orphaned local git objects.

# BRANCH CLEANUP, re: https://stackoverflow.com/a/7727380/1397555
git checkout master &&
for r in $(git for-each-ref refs/heads --format='%(refname:short)')
do
  if [ x$(git merge-base master "$r") = x$(git rev-parse --verify "$r") ]
  then
    if [ "$r" != "master" ]
    then
      git branch -d "$r"
    fi
  fi
done

# LOCAL OBJECTS backups etc. cleanup, re: https://stackoverflow.com/a/52230031/1397555
git reflog expire --expire=now --all && git gc --prune=now --aggressive

