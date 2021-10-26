# DESCRIPTION
# Finds the oldest commit date for every file in this directory and all subdirectories, and sets the modification date of the file to the date and time of that earliest commit.

# DEPENDENCIES
# Git, and for Windows, ExifTool. For Unix-like environments, GNU coreutils that come with most of them, including touch.


# USAGE
# With this script in your PATH, and from the root directory of a repo, run:
#    setFileTimestampsToEarliestGitCommit.sh
# NOTES
# - If you run this on a large repository (many files), it can take a LOOONNG time. It scans git history for every file in the repo and modifies file change (and for Windows, creation) date stamps for. Every. File. Excluding the .git folder, thank goodness.
# - This logs time stamps of first commits for each file in a file named firstGitCommitTimeStamps.txt. On subsequent runs, it searches that log first (which hopefully is faster), and if it doesn't find entries, it searches git log, then appends any finds to firstGitCommitTimeStamps.txt.
# - There's no point to running this script if you don't do so from within a folder of a git repository (the root of the repo or any subfolder).
# - If you have ridiculously long history with a file, and/or the file was ever renamed, you may want to first run:
#        git config diff.renameLimit 999999
# - This script was created for the data archaeology curiosity of listing what files I created first in a git repository, and sorting them by newest first to see what is "newest" in terms of when I first committed it. Also, it tries to track renames in git history.
# - Adapted from gitDumpAllFileVersions.sh, which is adapted from information it references.


# CODE
# The -printf '%P\n' removes the ./ from the start of listings, and prints each on its own line (newline); also, `-path ./.git -prune -o` excludes the .git directory:

if [ ! -e firstGitCommitTimeStamps.txt ]; then printf "" > firstGitCommitTimeStamps.txt; fi

allFilesRecursive=( $(find . -path ./.git -prune -o -type f -printf '%P\n') )
lengthOfAllFilesRecursive=${#allFilesRecursive[@]}
count=0
for file in ${allFilesRecursive[@]}
do
	count=$((count + 1))
	# If file name and time stamp are found in custom log file, update file from that; otherwise, search git log for it and use that and add it to custom log file. THE FOLLOWING SED EXPRESSION returns the time stamp after the file name in the custom log only if that is found; otherwise it returns nothing; we can therefore check if it is nothing to follow that logic:
	# ! BEGIN GLARFARFARBARG !
	fileNameForSEDsearch=$(echo $file | sed 's/\//\\\//g')
	# ! END GLARFARFARBARG !
	printf "\n$count of $lengthOfAllFilesRecursive: will search for time stamp for file $file . . .\n"
	TIMESTAMP=$(sed -n "s/^\($fileNameForSEDsearch\)|\(.*\)/\2/gp" firstGitCommitTimeStamps.txt)
	if [ "$TIMESTAMP" == "" ]
	then
		printf "NOT FOUND in custom log file; will search git log . . .\n"
		git log --follow $file > tmp_qgF23WNAz8Hkwe.txt
		# we can test errorlevel $? immediately after that command in the following expression, to see if there was _not_ an error (if $? is 0); and only proceed if there was not. If there _was_ an error, the following block will therefore not be executed, and TIMESTAMP will remain having a value equal to "", which we want:
		if [ $(echo $?) == "0" ]
		then
			# Filter that result to just the hashes of commits for that file, printed from the log command:
			sed -i -n 's/^commit \([0-9a-z]\{1,\}\)\(.*\)/\1/p' tmp_qgF23WNAz8Hkwe.txt
			# last line of that will be the oldest commit for that file; get and use that to get date stamp of original commit for file:
			OLDEST_HASH_FOR_FILE=$(tail -n 1 tmp_qgF23WNAz8Hkwe.txt)
			# retrieve and apply original time stamp of file when committed;
			# re another genius breath: https://stackoverflow.com/a/30143117/1397555
			GIT_TIME_INFO=$(git show -s --format=%ci $OLDEST_HASH_FOR_FILE)
			# printf "\nTimestamp for revision $HASH of file $file is:\n"
			# echo $TIMESTAMP
			TIMESTAMP=$(echo $GIT_TIME_INFO | sed 's/-//g;s/ //;s/://;s/:/\./;s/ .*//' | tr -d '\15\32')
			# write file and time stamp to custom log in custom format:
			printf "$file|$TIMESTAMP\n" >> firstGitCommitTimeStamps.txt
		fi
	else
		printf "FOUND in custom log file with timestamp $TIMESTAMP; will use that . . .\n"
	fi
	
	# update from timestamp only if any was found in custom log or git log (only if it isn't "") :
	if [ "$TIMESTAMP" ]
	then
			# 'nix:
		touch -a -m -t $TIMESTAMP $file
			# WINDOWS use of ExifTool for a purpose other than it was intended for: update the Windows file creation date stamp:
		ExifTool -overwrite_original "-FileModifyDate>FileCreateDate" $file
		printf "\nChanged file modification (and for Windows, also creation date) stamp for file:\n~\n$file\n~\nTo Unix timestamp $TIMESTAMP.\n"
	else
		printf "\nTimestamp for file $file was NOT found in custom log or git log (value: $($TIMESTAMP)), so the script did not update the file timestamp.\n"
	fi
done

rm tmp_qgF23WNAz8Hkwe.txt

printf "\nDONE.\n"