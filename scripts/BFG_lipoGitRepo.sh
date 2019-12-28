# DESCRIPTION
# Via the BFG java tool, destroys all blob revisions in a git repo larger than 1K; lipo-suction for obese repositories. Operates on a new copy of a repo to avoid permanent damage if there are errors; to do this it creates a fresh, bare mirror repo in a sub-subfolder to operate on, and backs up the repo database in a .7z archive in the folder above that before any change operations (so that you have an archived state to revert to if necessary). WARNING: this pushes a scrubbed repo state for *every reference* (branch) straight back up to every reference at your repo, without asking!

# USAGE
# Because Java apparently doesn't scan environment paths (maybe that's a security feature), first copy bfg.jar into the directory from which you invoke this script. Then invoke this script with one parameter, being the clone (etc.) URL of a git repo, e.g.:
# thisScript.sh https://github.com/earthbound19/_ebSuperBin.git

# REFERENCE
# https://rtyley.github.io/bfg-repo-cleaner/
# https://repository.sonatype.org/service/local/repositories/central-proxy/content/com/madgag/bfg/1.12.16/bfg-1.12.16.txt

# DEV NOTES
# Question: what is meant in the page at that first URL by: "If you want the BFG to delete something you need to make sure your current commits are *clean*?"


# CODE
# Save current path to come back to after script execution finishes:
pushd .


echo Starting git repo clone of $1 for lipo-suction\, as it were . . .

if [ ! -d BFG_lipoGitRepoTMP ]
then
	mkdir BFG_lipoGitRepoTMP
	mkdir BFG_lipoGitRepoTMP/bare
fi

cd BFG_lipoGitRepoTMP/bare

git clone --mirror $1

# Backup bare mirror repo database to the folder above:
7za a -y ../repoDatabase.7z *

# store git repo folder name in a variable for later use; we can do this because it is the only folder in our current path:
repoFolderName=`ls`
cp ../../bfg.jar .

# OPTIONAL; uncomment if you want this; you must have lfs in your PATH to do this; the following extracts all files of the specified extensions into lfs (which makes cloning and checkout far less painful with large repos) :
# extraParams="--convert-to-git-lfs '*.{zip,7z,exe,dll,clbin,chm,bin,pyd,pdf,png,jpg,gif,psd,tif,tiff,bmp,ppm,ico,mp4,mov,mgk}'"

java -jar bfg.jar --strip-blobs-bigger-than 1K --massive-non-file-objects-sized-up-to 10M $extraParams $repoFolderName
rm ./bfg.jar

cd *.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
# NOTE the following will fail if you have no cached git credentials; you'll have to use a CLI environment or tool that knows those:
git push

echo DONE. If everything went well\, the remote repo is now lipo-suctioned\, as it were.

# Return to saved directory:
popd