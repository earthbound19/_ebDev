# DESCRIPTION
# Runs a series of scripts to prepare and embed metadata in final exported (pre-publication) art etc. files.

# USAGE
# Not currently well documented. A start at documentation:
# - If necessary, use ftun.sh and/or rename.pl to get all files this script will operate on to have only terminal-friendly characters in their file names. This is a manual process to do before running this script. Find it in rename.pl in this repository and read the USAGE comments I have added to it.
# Previous solutions are in:
#    _THE_SAD_EPIC_OF_TERMINAL_FRIENDLY_FILE_RENAMING.txt.
# - Comment out steps unnecessary for your current run of the image press (this script). Then run the script.


# CODE
# TO DO
# - move this to _ebArt? It's a "recipe" in the sense given there.
# - Update documentation in comments and have it refer to an outside file?
# - Move the relevant instructions from below, or all of them, into echo statements in the files to which they relate, for cases of using those files independent of this script.
# - Split this into two scripts (one for file name and metadata fixup, another for custom metadata creation), and update documentation referencing the (to be former) file name of this script accordingly?
# Do I want this to use archiveMetaDataWin.sh before prepping/updating metadata?
# Do I want this to also use exportIMGsMetadataSimple.sh?
echo "!============================================================"
	echo "WARNING: Before using this script, ensure all file names in your execution path do not have any console-unfriendly characters in their file names, including no spaces (replace those with underscores). OTHERWISE, this script will not work as hoped. This script will first attempt to run metamorphose (see https://sourceforge.net/projects/file-folder-ren/files/Metamorphose/1.1.2%20stable/ ). Load the Metamorphose1BadFileNameCharacterRemoval_step01.cfg configuration into metamorphose, adjust the search folder as necessary, and execute it. Then reload the file list, and repeat this with ~02.cfg, and any others after that. ALTERNATE option for this: manually use the Flexible Renamer program, operating only on folders, with the regex in badCharsFRregex.txt, replacing with _. ALSO, to include all files in subdirectories, look for a \"walk\" checkbox and tick it. If metamorphose fails to open from this script, you will have a chance to abort this script. NOTE: if metamorphose gives you a permissions or other access error, it may be that a path name is too long. Shorten it up or temporarily move a long folder name to a root dir, then run this script against that temporarily moved folder. ALSO NOTE: you might additionally or alternately try ftun.sh."
	echo "Do you wish to run this script?"
	echo "!============================================================"
# TO DO:
# Update this (non-working anyway for whatever reason--it *did* work before) prompt with that to be found at: http://stackoverflow.com/a/3232082/1397555
	echo "IF YOU HAVE READ the above warning, type the number corresponding to your answer, then press <enter>. If you haven't read the warning, your answer is 2 (No)."
	select yn in "Yes" "No"
	do
		case $yn in
			Yes ) echo Dokee-okee! Working . . .; break;
			No ) echo D\'oh!; exit;
		esac
	done
cmd /c "C:\Program Files (x86)\metamorphose\metamorphose.exe"
	echo "!============================================================"
	echo "Run of metamorphose.exe attempted. Do you wish to continue running this script?"
	echo "!============================================================"
	echo "TYPE THE NUMBER CORRESPONDING TO YOUR ANSWER, then press <enter>. If you are not sure, your answer is 2 (No)."
	select yn in "Yes" "No"
	do
		case $yn in
			Yes ) echo Dokee-okee! Working . . .; break;
			No ) echo D\'oh!; exit;
		esac
	done

# COMMENT OUT OR USE PER NEED:
# dateByFileName.sh
# dateByMetaData.sh
numberFilesByLabel.sh

echo "As instructed by the echo from the end of numberFilesByLabel.sh, examine the files created by that batch, and if you are ready to continue, select 1. If you are not ready, make adjustments and manually run said ~.sh script until you are ready, then select 1, or select 2 to terminate this script, and examine the source to determine what to do next."
	echo "!============================================================"
	echo "DO YOU WISH TO CONTINUE running this script?"
	select yn in "Yes" "No"
	do
		case $yn in
			Yes ) echo Dokee-okee! Working . . .; break;
			No ) echo D\'oh!; exit;
		esac
	done

archiveMetadata.sh
imgMetaDataTo7z.bat
prepMediaMetadata.sh
mediaTagAndDist.sh

echo __DigitalImagePress.sh run COMPLETED.