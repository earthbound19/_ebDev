# DESCRIPTION
# This is a destructive script which should not exist, and it prompts you to type two different passwords before proceeding. It rewrites the entire master branch of any cloned repo so that there is only one commit: what had been the tip commit of master. It then force pushes that over remote master, so that master then only has one commit, being what had been the most recent (and then becomes the only commit). This destructive kludge is to keep bloated git repositories (which should not exist because they are using large binaries in git) smaller.

# USAGE
# Don't use this script.
exit

# CODE
# get rnd string to name our tmp file after
git checkout master
rndString=`cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 12`
git log > wut_tmp_"$rndString".txt
# write git log to temp file, then get first commit hash and git checkout that:
commit_hash=`head -n 1 wut_tmp_"$rndString".txt`
rm wut_tmp_"$rndString".txt
commit_hash=`echo $commit_hash | sed 's/\(commit \)\(.*\)/\2/'`
# do teh DESTRUCTIVE THINGS!!!!
git checkout $commit_hash
git checkout -b tmp_branch_"$rndString"

 # . . . and then what?