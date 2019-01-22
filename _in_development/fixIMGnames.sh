# DESCRIPTION:
# DOES STUFF, in conjunction with getCorrectedImageName.ahk/exe, to rename image file names for 'nix/Windows/web compatibility. POSSIBLE FUNCTIONAL DUPLICATE of ftun.sh, which at this writing I've used for some while for this function. This script and the .ahk/exe dependency I may deprecate. NOTE: I wonder if the ahk executable generated some random characters in shortening file names to avoid overwriting one file with another if they end up having duplicate names? If so this script still might have use.

# FIX IMAGE NAMES

		# DEVELOPMENT ONLY; *_COMMENT OUT_* these indented lines in production:
		# echo RESETTING development test files . . .
		# rm *.jpg
		# rm *.jpeg
		# rm *.png
		# rm *.tif
		# rm *.tiff
		# 7z x -y devCopiedSelection.7z

		# I discovered there is a command built into 'nix that will do this with regular expressions, again thanks to a genius breath at: http://unix.stackexchange.com/questions/33060/linux-script-or-program-to-shorten-filenames
		# The tool is simply called "rename," and it's built into my install of cygwin! TO DO: learn about *all* 'nix commands/tools/executables that ship therewith (or on any system). HOWEVER, that tool, like the cygwin shell itself (I think?) will also not rename files longer than 100 chars! Sheesh. My own windows-only :( AutoHotkey solution (which this script calls) will, however.

# START WARNING AND PROMPT ========================================================================
# Thanks to: http://stackoverflow.com/questions/226703/how-do-i-prompt-for-input-in-a-linux-shell-script
# TO DO: Severely abridge the following warning to avoid tl;dr

# TO DO: UNCOMMENT THESE INDENTED LINES in production:
	echo "!============================================================"
	echo "WARNING: This script will rename all the image files in the directory you run this script against--to be friendlier to scripts e.g. by replacing spaces with underscores, and possibly other changes, depending on the commands in this script which are (or are not) commented out (which you should examine, if you haven't). If you understand and accept this, please feel free to continue. If you don't, please type 2 and press enter. Also please note: until/unless this script is fixed, it will throw an error message about two files being the same. This means nothing (or that nothing has happened), so it's not anything to be concerned about. But maybe you will be anyway. Maybe you have an undiagnosed anxiety disorder. Please get help if you might. Or laugh at the silly writer of this script."
	echo "Do you wish to run this script?"
	echo "!============================================================"
	echo "IF YOU HAVE READ the above warning, type the number corresponding to your answer, then press <enter>. If you haven't read the warning, your answer is 2 (No)."
	select yn in "Yes" "No"
	do
		case $yn in
			Yes ) echo Dokee-okee! Working . . .; break;;
			No ) echo Doh!; exit;;
		esac
	done

# END WARNING AND PROMPT ========================================================================

# Blank the following file and fill it with a list of images:
printf "" > imgs_oldNames.txt
# OR do the following this way: find . -type f -iregex '\.\/.*.\(tif\|tiff\|png\|.psd\|ora\|kra\|rif\|riff\|jpg\|jpeg\|gif\|bmp\|cr2\|crw\|pdf\|ptg\)' -printf '%TY %Tm %Td %TH %TM %TS %p\n' | sort -g > _batchNumbering/fileNamesWithNumberTags.txt
gfind . -maxdepth 1 \( -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.kra -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.crw -o -iname \*.pdf -o -iname \*.ptg \) -printf '%f\n' | sort > imgs_oldNames.txt

# Also convert forward slashes to Windows' @#*$^! backslashes:
tr '/' '\' < imgs_oldNames.txt > temp_OOOO0o0Oo0oO00ooooO.txt
rm imgs_oldNames.txt
mv temp_OOOO0o0Oo0oO00ooooO.txt imgs_oldNames.txt

# !=======================================
# CREATE ARRAY OF NEW FILE NAMES and RENAME them. IN ALL CAPS. Except not in all caps.
# NOTE the following is unused at this writing; but the value 57 may be preferred:
shortenFileLengthTo=175
mapfile -t imgs_oldNames < imgs_oldNames.txt
rm imgs_oldNames.txt
rm imgs_original_names.txt
rm imgs_new_names.txt
rm _call_getCorrectedImageName.bat
rm _call_getCorrectedImageName-bat.txt
# USED BY getCorrectedImageName.ahk/exe; needs to be blanked/deleted by this before it is used by that:
rm _rename_images.txt
rm _rename_images.bat

progressString="Arbeiten . . ."

for file in "${imgs_oldNames[@]}"
do
	cygCurrDir=`pwd`
	DOScurrDir=`cygpath -p -w $cygCurrDir`
	printf ". . . "
	echo "getCorrectedImageName.exe \"$DOScurrDir\" \"$file\"" >> _call_getCorrectedImageName.txt
	# For the option to shorten the file name to a specific length:
	# echo "getCorrectedImageName.exe \"$DOScurrDir\" \"$file\" $shortenFileLengthTo" >> _call_getCorrectedImageName.txt
	echo >> _call_getCorrectedImageName.txt
done

# EXECUTE the newly created batch file which repeatedly calls getCorrectedImageName.exe, which gives us a batch file that will create junction links and/or shorten filenames
# TO DO: COMMENT OUT THE NEXT LINE IN PRODUCTION
echo Repeatedly calling getCorrectedImageName.ahk/.exe to create a batch of proposed image file renames. Your task bar may annoyingly flicker for a while.
echo . . .
mv _call_getCorrectedImageName.txt _call_getCorrectedImageName.bat
source _call_getCorrectedImageName.bat
# I think the - in the filename throws it unless it's surrouned by single quote marks:
mv '_call_getCorrectedImageName.bat' '_call_getCorrectedImageName-bat.txt'

echo -~-~-~-~-~-~-~-~ File renaming batch creation DONE. -~-~-~-~-~-~-~-~ NOTE: Right-click _rename_images.txt, open it in a text editor, examine the proposed rename operations in it, and if they all look good, rename the extension to .bat, then double-click it. ALSO, NOTE: Pending further debugging, this can miss renaming files with unwanted characters. Use a tool like Flexible Renamer to fix any stragglers. -~-~-~-~-~-~-~-~

# LEFTOVER for reference:
			# echo $file >> imgs_newNames.txt
			# echo mv "\"$oldFileName\" \"$newFileName\"" >> renCommand.sh
		# echo \\NOT RENAMED\\ $oldFileName >> imgs_newNames.txt
# !=======================================

# ===== REVISION HISTORY =====
# 2015-09-28 v0.9 essential algorithms complete
# 10/05/2015 v0.95 v1 file renaming functionality via fixIMGnames.sh complete.
# 10/07/2015 v1 Debugging of minor errors complete.
# 10/10/2015 v1.01 BUG FIX; it will not properly shorten file names longer than 100 chars from cygwin; replaced that failed functionality by creating getCorrectedImageName.ahk/.exe and invoking that from this for file renaming/shortening/junction link creation.
# 01/31/2016 08:14:23 PM Re-verify functionlity, comments/documentation fixup.