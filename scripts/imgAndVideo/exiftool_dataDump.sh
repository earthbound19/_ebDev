# DESCRIPTION
# Writes metadata information for image or video etc. $1 to <media_file_name>_tagInfo.txt, via exiftool.

# DEPENDENCIES
# exiftool

# USAGE
# Run with on parameter, which is the file name of the file to dump information for, e.g.:
#    exiftool_dataDump.sh inputFile.jpg


# CODE
exiftool $1 > "$1"_tagInfo.txt

# DEVELOPER NOTES
# Previously this was exiftool_dataDump.bat, functionally identical but called via Windows cmd.