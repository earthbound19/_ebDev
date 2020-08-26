# DESCRIPTION
# Via ExifTool, wipes ALL image or video metadata (of all known types) from file $1 (parameter 1), via overwrite of original file. A known password prompt prevents from casual or accidental run of this permanent metadata-destroying operation.

# USAGE
# Pass this script one parameter, which is a file name to wipe the metadata from in-place, for example:
#    wipeMetadata.sh inputFile.mp4
# WARNING
# Do this only on data for which you have a backup! If something goes wrong with this, it can be a permanent kablooey for the affected files.
# DANGEROUS CHEAT
# To wipe all metadata from all supported file types, pass $1 as . (meaning '.' or just a dot).
# DANGEROUS CHEAT TWO
# If you pass a second parameter which is the word 'YALBLOR', it will wipe metadata (from one or all files (one filename as $1 or '.' for all files) without asking.


# CODE
if ! [ "$1" ]; then	printf "\nNo parameter 1 (image of other media file name to operate on). Exit."; exit 1; fi;

# if there is a parameter $2 and it does not equal the string "YALBLOR", prompt user. Otherwise do nothing other than fall through and execute the main functionality:
if ! [ "$2" == "YALBLOR" ]
then
	echo ""
	echo "WARNING: This script is destructive! Only operate on a file or files for"
	echo "which you have a backup! It will wipe all metadata from file $1."
	echo "("
	echo "NOTE: To run this script against a file and bypass this prompt,"
	echo "pass the word YALBLOR as the second parameter to this script, like this: )"
	echo " wipeMetaData.sh inputFileName.jpg YALBLOR"
	echo ")"
	echo "~ To wipe all metadata from file $1, type YALBLOR and press"
	echo "ENTER or RETURN."
	echo "If this is _not_ what you want to do, type anything else, or press"
	echo "CTRL+C or CTRL+Z."
	read -p "TYPE HERE: " SILLYWORD
	, or 
	if ! [ "$SILLYWORD" == "YALBLOR" ]
	then
		echo ""
		echo Typing mismatch\; exit.
		exit 1
	else
		echo continuing . .
	fi
fi

# DEVELOPER NOTES
# Additional reference (to whatever else I originally looked up to develop this) ; e.g. nuke everything (really? Something else maybe indicated that -all= doesn't encompass all the other thing:all= nuke swithces I added here--and is that correct?) : http://photography-on-the.net/forum/showthread.php?p=13543203
# -- I think that is NOT correct, and the way to wipe all metadata of every kind is just -all= , re: https://martin.hoppenheit.info/blog/2015/useful-exiftool-commands/
	# DEPRECATED; I've read that the second next line does all this anyway:
	# exiftool -all= -CommonIFD0= -adobe:all= -xmp:all= -Photoshop:all= -iptc:all= -m -overwrite_original -k $1
printf "\n~ WIPING METADATA from file $1 . . ."
exiftool -all= -m -overwrite_original $1