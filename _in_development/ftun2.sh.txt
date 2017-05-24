# FAIL at first blush; throws error about improper use of basename command.
# TO DO: investigate (unless I find a better solution).

# DESCRIPTION
# A more elegant version of ftun.sh (see comments for description of).
# Source: http://www.techrepublic.com/blog/linux-and-open-source/how-to-remove-weird-characters-from-file-and-directory-names-automatically/

# DEPENDENCIES
# perl. For cygwin, install perl re: http://slu.livejournal.com/17395.html

# USAGE
# Invoke this from the terminal from a directory for which you want to rename so many files re comments of ftun.sh.

# SCRIPT WARNING ==========================================
echo "Dude. In the wrong hands this script is a weapon. You sure you wanna do that? If this is something you mean to do, press y and enter. Otherwise press n and enter, or close this terminal."
	echo "!============================================================"
	# echo "DO YOU WISH TO CONTINUE running this script?"
    read -p "DO YOU WISH TO CONTINUE running this script? : y/n" CONDITION;
    if [ "$CONDITION" == "y" ]; then
		echo Ok! Working . . .
	else
		echo D\'oh!; exit;
    fi
# END SCRIPT WARNING =======================================


rm -f /tmp/clean_dir_file_names*
# cd $1
find .  | awk '{ print length(), $0 | "sort -n -r" }' | \
grep -v '^1 \.$' | cut -d/ -f2- > /tmp/clean_dir_file_names_1

touch /tmp/clean_dir_file_names_2
while read line
do
	BASE=`basename "$line"`
	NEWBASE=`basename "$line" | perl -e '$N = <>; chomp ($N); $N =~ s/[^a-zA-Z0-9-_.]/_/g; $N =~ s/_+/_/g;' `
	if [ "$BASE" != "$NEWBASE" ]
		then
		OLDPATH=$(echo "$line" | sed -r 's/([^a-zA-Z0-9./_-])/\\\1/g')
		DIR=$(dirname "$line" | sed -r 's/([^a-zA-Z0-9./_-])/\\\1/g')
		echo "mv -i $OLDPATH $DIR/$NEWBASE" >> /tmp/clean_dir_file_names_2
	fi
done </tmp/clean_dir_file_names_1
exit