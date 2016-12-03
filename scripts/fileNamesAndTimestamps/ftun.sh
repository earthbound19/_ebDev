# DESCRIPTION
# FTUN stands for "Fix Terminal Unfriendly [folder and file] Names." This script does just that by building a proposed mv command shell script for every folder and file name under the path from which this script is executed.

# USAGE
# From a terminal, in a folder with terminal-processing-unfriendly names, execute this script and follow the prompts.

# TO DO
# Eliminate "rename" commands that would attempt to rename a directory or file to itself.
# NOT TO DO
# Use the elegant means I found somewhere of eliminating lines that are identical between alles and alles2.txt etc. (as this would avoid time-wasting and error-trowing renames of a file to itself) before further marking up and pasting them.
# Reason: I couldn't manage to find that.


# SCRIPT WARNING ==========================================
echo "Dude. In the wrong hands this script is a weapon. You sure you wanna do that? If this is something you mean to do, press y and enter. Otherwise press n and enter, or close this terminal. NOTE: any folder starting with a - (minus or dash) in the folder name will cause this script to fail. You'll want to avoid ever naming any folder thus. ALSO: this script will ignore all files containing the string 'alles'. For technical reasons."
	echo "!============================================================"
	# echo "DO YOU WISH TO CONTINUE running this script?"
    read -p "DO YOU WISH TO CONTINUE running this script? : y/n" CONDITION;
    if [ "$CONDITION" == "y" ]; then
		echo Ok! Working . . .
	else
		echo D\'oh!; exit;	
    fi
# END SCRIPT WARNING =======================================


# FAIL, as near I can tell:
# shopt -s nullglob
# for i in *\'* ; do mv -v "$i" "${i/\'/}" ; done

# === BEGIN FOLDERS RENAMING ===
# NOTE that all of these find commands add an exclusion of every file with the string 'alles' in it via grep; re: http://stackoverflow.com/a/8525459/1397555
cygwinFind * -type d | grep -v '.*alles.*' > alles1.txt
# Build second part of move command by replacing all terminal-unfriendly characters in listed folder names, via tr:
cygwinFind * -type d | grep -v '.*alles.*' | tr \=\@\`~\!#$%^\&\(\)+[{]}\;\ , _ > alles2.txt
				# Example bad folder name that was tested against:
				# WUT`'''''~!@#$%^&a()-=hi hi HEY+[{]};' ,
# Prune all triplicate+ underscores to double (for target folder names) :
sed -i "s/_\{3,\}/__/g" alles2.txt

# Interleave all lines from alles1.txt and alles2.txt, then eliminate all lines that are duplicated (delete both the line and the line that has a duplicate, per each duplicate), then work them up to a mv command (which includes joining every other line to the previous line before prefixing the mv command:
# Interleave (re above):
paste -d '\n' alles1.txt alles2.txt > ZERP.txt
# eliminate all lines that have a duplicate (re above):
uniq -u ZERP.txt > badPathsRename.sh.txt
# remove temp files:
rm ZERP.txt alles1.txt alles2.txt
# pad all lines with single quote marks so that the mv command won't be thrown by spaces in the first parameter of the command:
sed -n -i "s/\(.*\)/'\1'/p" badPathsRename.sh.txt
# Replace every other newline with a space, starting on the first newline--to merge every pair of lines into one command, prepended with mv; BUT FIRST you must append a newline with some content at the end of the file (and subsequently remove the that last line of appended content:
echo OHHAI_DELETE_THIS_LINE_6D7C3qwFyXe2K4WMxevdf355tR27tESbpr_KTHXBAI >> badPathsRename.sh.txt
sed -i ':a;N;$!ba;s/\([^\n]*\)\n\([^\n]*[\n|$]\)/mv \1 \2/g' badPathsRename.sh.txt
# Print everything of the result except that extraneous last line to a new temp file, delete badPathsRename.sh.txt, and rename the temp file to badPathsRename.sh.txt:
head --lines=-1 badPathsRename.sh.txt > temp.txt
rm badPathsRename.sh.txt
mv temp.txt badPathsRename.sh.txt

echo !=======================!
echo \! WARNING \! AND NOTE\: This rename script may choke and fail or cause DRASTICALLY WRONG file renames IF ANY folders and files have single-quote marks \(\'\)\ in their name \(never put that in a file name--that\'s terminal-unfriendly\)\. You will want to take care of those via the free FlexibleRenamer.exe or metamorphose utilities\; for the latter\, with noQuotes.cfg. PROGRAMMER TO DO\: Clarify that by elaborating on it.
echo !=======================!
echo DONE creating proposed folders rename script. Examine badPathsRename.sh.txt\, and correct any errors. EXAMINE EVERY LINE of that file for correctness\, and fix any errors. \(You must understand the mv command\). Once you\'re certain the proposed mv \(rename\) commands in it are all good\, press y\, and I will rename that \.txt file to a \.sh script and execute it\, to actually do the renames. NOTE\: any folder names prefixed with a dash \(\-\) will not rename\, and throw an error--but the script will continue and properly rename anything else. You can abuse this as a strategy to avoid renaming particular folders \(not recommended\)\.
read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo Dokee-okee! Working . . .;
        ;;
    *)
        echo D\'oh! Terminating script.; exit;
        ;;
esac

mv badPathsRename.sh.txt badPathsRename.sh
./badPathsRename.sh
rm ./badPathsRename.sh
# === END FOLDERS RENAMING ===


# === BEGIN FILES RENAMING ===
# DO all of the same things again, but for files only (now that paths have been fixed up, eliminating problems that would otherwise cause in path renaming, and because fixing paths at the same time as files would mean wasted and error-throwing duplicate path rename commands.) All comments deleted here--code copied and adapted from folders renaming section (see). TWEAK: exclude (alles*.txt) named files via !(alles*.txt).
# shopt -s extglob
cygwinFind * -type f | grep -v '.*alles.*' > alles1.txt
cygwinFind * -type f | grep -v '.*alles.*' | tr \=\@\`~\!#$%^\&\(\)+[{]}\;\ , _ > alles2.txt
sed -i "s/_\{3,\}/__/g" alles2.txt
paste -d '\n' alles1.txt alles2.txt > ZERP.txt
uniq -u ZERP.txt > badFilesRename.sh.txt
rm ZERP.txt alles1.txt alles2.txt
sed -n -i "s/\(.*\)/'\1'/p" badFilesRename.sh.txt
echo OHHAI_DELETE_THIS_LINE_6D7C3qwFyXe2K4WMxevdf355tR27tESbpr_KTHXBAI >> badFilesRename.sh.txt
sed -i ':a;N;$!ba;s/\([^\n]*\)\n\([^\n]*[\n|$]\)/mv \1 \2/g' badFilesRename.sh.txt
head --lines=-1 badFilesRename.sh.txt > temp.txt
rm badFilesRename.sh.txt
mv temp.txt badFilesRename.sh.txt

echo !=======================!
echo \! WARNING \! AND NOTE\: This rename script may choke and fail or cause DRASTICALLY WRONG file renames IF ANY folders and files have single-quote marks \(\'\)\ in their name \(never put that in a file name--that\'s terminal-unfriendly\)\. You will want to take care of those via the free FlexibleRenamer.exe or metamorphose utilities\; for the latter\, with noQuotes.cfg. PROGRAMMER TO DO\: Clarify that by elaborating on it.
echo !=======================!
echo DONE creating proposed folders rename script. Examine badFilesRename.sh.txt\, and correct any errors. EXAMINE EVERY LINE of that file for correctness\, and fix any errors. \(You must understand the mv command\). Once you\'re certain the proposed mv \(rename\) commands in it are all good\, press y\, and I will rename that \.txt file to a \.sh script and execute it\, to actually do the renames. NOTE\: any folder names prefixed with a dash \(\-\) will not rename\, and throw an error--but the script will continue and properly rename anything else. You can abuse this as a strategy to avoid renaming particular folders \(not recommended\)\.
read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo Dokee-okee! Working . . .;
        ;;
    *)
        echo D\'oh! Terminating script.; exit;
        ;;
esac

mv badFilesRename.sh.txt badFilesRename.sh
./badFilesRename.sh
rm ./badFilesRename.sh
# === END FILES RENAMING ===


# CHANGE LOG
# Pre 09/14/2016: correct.
# 09/14/2016 10:06:07 PM made folder renaming much more reliable (unknown characters or patterns could mess it up). Plan to implement same new process for file renaming.
# 09/17/2016 04:11:38 PM Bug fix: don't list temp files created during run of this script.

# DEVELOPMENT NOTES
# Re: http://dimitar.me/quickly-remove-special-characters-from-file-names/
# How to remove the characters ' -~' (everything between those single quote marks) using tr:
# for f in *; do mv "$f" "`echo $f | tr -cd ' -~'`"; done
# Another possibility (maybe not as thorough for removing terminal-unfriendly characters) is::
# tr -dc '[:print:]'

# List of unwanted characters (and a reference bad folder name); with more problematic characters at the start and the problematic minus at the end:
# '@=`~!#$%^&()+[{]};. ,-
# How to figure out which of those need escaping: type them into notepad++ in this saved .sh file; the characters not recognized as part of a string showed in a color other than orange (using the Solarized Dark color scheme), e.g. :
# \`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \.

# Built also with help from:
# http://www.cyberciti.biz/faq/howto-find-a-directory-linux-command/
# Find directories in the current path:
# cygwinFind * -type d
# I like it but probably re http://stackoverflow.com/a/9612232/1397555 it's problematic [SEE COMMENTS ON THAT POST for an explanation that could potentially make for a far simpler version of this script]:
# for file in "`cygwinFind . -name "*.txt"`"; do echo "$file"; done
# Re http://stackoverflow.com/a/30911798/1397555

# Example command that WORKS as far as demonstrating replacing characters:
# echo A\`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \.B | tr \`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \. _