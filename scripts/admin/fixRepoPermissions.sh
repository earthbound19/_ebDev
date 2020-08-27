# DESCRIPTION
# Updates the index for every file in a repo of .sh and .py types to regard them as executable (in Unix-style file systems that care), and also sets folder and file permissions to avoid permission changes triggering a git change detection.

# USAGE
# Run this script without any parameter:
#    fixRepoPermissions.sh
# NOTES
# - For batch file permissions management on Mac, see: http://www.lagentesoft.com/batchmod/
# - This is a shotgun approach to fixing permissions, but I have tested this and permissions show up correctly in a freshly cloned repo which has had this script run against it and then every file update added, committed and pushed.


# CODE

# Fix any mucked up permission situation on file systems (which may negatively affect git usage) that may need it, re: https://stackoverflow.com/a/1580644
find . -type d -exec chmod a+rwx {} \;    # Make folders traversable and read/write
find . -type f -exec chmod a+rw {} \;     # Make files read/write

# Re: https://stackoverflow.com/a/24704900/1397555
allExecutableFilesArray=($(find . -type f -name '*.sh' -o -name '*.py'))
for file in ${allExecutableFilesArray[@]}
do
  echo $file
  chmod +x $file
  git update-index --chmod=+x $file
done

# Re: https://stackoverflow.com/questions/1580596/how-do-i-make-git-ignore-file-mode-chmod-changes#comment47788079_2083563
# git diff --summary | grep --color 'mode change 100644 => 100755' | cut -d' ' -f7-|tr '\n' '\0'|xargs -0 chmod -x