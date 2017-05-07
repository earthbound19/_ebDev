# DESCRIPTION: get shortened image names as junction links in a subfolder.

# TO DO: Maybe just make this all an AHK script. Blegh in two parts. BUT: it works, and time to rework it is money. If it works don't fix it . . . I now overrule my speculation. NO. Shall not. 10/10/2015 10:38:02 PM -RAH

		# DEVELOPMENT ONLY; comment out these indented lines in production:
		# echo RESETTING development test files . . .
		# rm *.jpg
		# rm *.png
		# 7z x -y devCopiedSelection.7z

		# ARGH! After going through the extreme pains of creating this script with so many steps to shorten names according to so many rules, I discover there is a command built into 'nix that will do this with regular expressions, again thanks to a genius breath at: http://unix.stackexchange.com/questions/33060/linux-script-or-program-to-shorten-filenames
		# The tool is simply called "rename," and it's built into my install of cygwin! TO DO: learn about *all* 'nix commands/tools/executables that ship therewith (or on any system).
		# EXCEPT that tool also will not rename files longer than 100 chars! Sheesh. My own AutoHotkey solution (windows only :() will, however.

# START WARNING AND PROMPT ========================================================================
# Thanks to: http://stackoverflow.com/questions/226703/how-do-i-prompt-for-input-in-a-linux-shell-script
# TO DO: Severely abridge the following warning to avoid tl;dr

# TO DO: UNCOMMENT THESE INDENTED LINES in production:
	echo "!============================================================"
	echo "This script will create shorter named junction links of all images in the directory you run this from. It will create the shorter name junctions in a subdirectory named _short_symlinks. The junction links will also correct characters in file names (such as spaces) which can louse up scripts. If you understand and accept this, please feel free to continue. If you don't, please type 2 and press enter. Also please note: until/unless this script is fixed, it will throw an error message about two files being the same. This means nothing (nothing has happened), so it's not anything to be concerned about. But maybe you will be anyway. Maybe you have an undiagnosed anxiety disorder. Please get help if you might. Or laugh at the silly writer of this script."
	echo "Do you wish to run this script?"
	echo "!============================================================"
	echo "IF YOU HAVE READ the above warning, type the number corresponding to your answer, then press <enter>. If you haven't read the warning, your answer is 2 (No)."
	select yn in "Yes" "No"
	do
		case $yn in
			Yes ) echo Dokee-okee!; break;;
			No ) echo Doh!; exit;;
		esac
	done

# END WARNING AND PROMPT ========================================================================

# Blank the following file and fill it with a list of images:
printf "" > imgs_oldNames.txt
find *.tif *.tiff *.png *.jpg *.jpeg *.gif *.bmp *.psd *.cr2 *.crw *.pdf -maxdepth 1 -type f >& /dev/null > imgs_oldNames.txt

# !=======================================
# CREATE ARRAY OF NEW FILE NAMES and RENAME them. IN ALL CAPS. Except not in all caps.
# 57 preferred:
shortenFileLengthTo=57
mapfile -t imgs_oldNames < imgs_oldNames.txt
rm imgs_oldNames.txt
# USED BY makeIMGjunctionsBatch.ahk/exe; needs to be blanked by this before it is used by that:
printf "" > imgs_original_names.txt
# SAME AS previous line of code:
printf "" > imgs_new_names_or_junction_links.txt
printf "" > call_makeIMGjunctionsBatch.bat
printf "" > call_makeIMGjunctionsBatch-bat.txt
printf "" > _createLinksTemp.bat
printf "" > _createLinksTemp-bat.txt

progressString="Arbeiten . . ."

printf "" > call_makeIMGjunctionsBatch.txt
for file in "${imgs_oldNames[@]}"
do
	cygCurrDir=`pwd`
	DOScurrDir=`cygpath -p -w $cygCurrDir`
	makeIMGjunctionsBatch.exe makeIMGjunctionsBatch.exe
	echo "makeIMGjunctionsBatch.exe \"$DOScurrDir\" \"$file\" $shortenFileLengthTo" >> call_makeIMGjunctionsBatch.txt
	echo >> call_makeIMGjunctionsBatch.txt
done

# EXECUTE the newly created batch file which repeatedly calls makeIMGjunctionsBatch.exe (which gives us a batch file that will create junction links and/or shorten filenames)
# TO DO: COMMENT OUT THE NEXT LINE IN PRODUCTION
	# rm -d -r _short_symlinks
mv call_makeIMGjunctionsBatch.txt call_makeIMGjunctionsBatch.bat
source call_makeIMGjunctionsBatch.bat
cp call_makeIMGjunctionsBatch.bat call_makeIMGjunctionsBatch-bat.txt
rm call_makeIMGjunctionsBatch.bat

	# CALL the junction link creation batch created by call_makeIMGjunctionsBatch.sh (which calls makeIMGjunctionsBatch.exe)
	# THANK YOU to the smart folks at: http://stackoverflow.com/a/11878147/1397555
	# If the following batch file is not invoked via CMD with the full path as per the next line, it will not properly work--my tests got weird results with anything but the following; and yet prior invokes of batches have no problem, with no explanation :/
cmd "/C $DOScurrDir\_createLinksTemp.bat"
cp _createLinksTemp.bat _createLinksTemp-bat.txt
rm _createLinksTemp.bat

echo Junction links subfolder creation DONE.


# LEFTOVER for reference:
			# echo $file >> imgs_newNames.txt
			# echo mv "\"$oldFileName\" \"$newFileName\"" >> renCommand.sh
		# echo \\NOT RENAMED\\ $oldFileName >> imgs_newNames.txt
# !=======================================

# ===== REVISION HISTORY =====
# 2015-09-28 v0.9 essential algorithms complete
# 10/05/2015 v0.95 v1 file renaming functionality via fixIMGnames.sh complete.
# 10/07/2015 v1 Debugging of minor errors complete.
# 10/10/2015 v1.01 BUG FIX; it will not properly shorten file names longer than 100 chars from cygwin; replaced that failed functionality by creating makeIMGjunctionsBatch.ahk/.exe and invoking that from this for file renaming/shortening/junction link creation.