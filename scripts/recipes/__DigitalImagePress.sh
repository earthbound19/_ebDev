# DESCRIPTION
# Runs a series of scripts to prepare and embed metadata in final exported (pre-publication) art etc. files.

# USAGE
# Not currently well documented. A start at documentation:
# - The scripts this uses are in scripts/imgAndVideo/EXIFdataBatch
# - If necessary, use ftun.sh and/or rename.pl to get all files this script will operate on to have only terminal-friendly characters in their file names. This is a manual process to do before running this script. Find it in rename.pl in this repository and read the USAGE comments I have added to it.
# - Comment out steps unnecessary for your current run of the image press (this script). Then run the script.


# CODE
# TO DO
# - Re-examine all this documentation and rewrite if necessary.
# - Update documentation in comments and have it refer to an outside file?
# - Move the relevant instructions from below, or all of them, into echo statements in the files to which they relate, for cases of using those files independent of this script.
# - Split this into two scripts (one for file name and metadata fixup, another for custom metadata creation), and update documentation referencing the (to be former) file name of this script accordingly?
# Do I want this to use archiveMetaDataWin.sh before prepping/updating metadata?
# Do I want this to also use exportIMGsMetadataSimple.sh?

# SCRIPT WARNING ==========================================
echo "!============================================================"
echo "WARNING: Before using this script, ensure all file names in your execution path do not have any console-unfriendly characters in their file names, including no spaces (replace those with underscores). OTHERWISE, this script will not work as hoped. You may accomplish this via ftun.sh and/or rename.pl in the _ebDev repo."
echo "Do you wish to run this script?"
echo "!============================================================"
read -p "DO YOU WISH TO CONTINUE running this script? : y/n" CONDITION;
if [ "$CONDITION" == "y" ]; then
	echo Ok! Working . . .
else
	echo D\'oh!; exit;	
fi
# END SCRIPT WARNING =======================================

# COMMENT OUT OR UNCOMMENT ANY OF THESE NEXT LINES PER NEED:
# renameByMetadata.sh
# dateByFileName.sh
# numberFilesByLabel.sh

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

# archiveMetadataWin.sh
# imgMetaDataTo7z.bat
prepMediaMetadata.sh
mediaTagAndDist.sh

echo __DigitalImagePress.sh run COMPLETED.