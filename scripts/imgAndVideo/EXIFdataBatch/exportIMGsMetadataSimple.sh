# DESCRIPTION
# For all of many image types in the current directory, creates text files of simplified metadata information, named after the image.

# USAGE
# Hack the script this calls (if you need to, to get a different formats list), then run this without any parameter:
#    exportIMGsMetadataSimple.sh


# CODE
allIMGfileNamesArray=($(printAllIMGfileNames.sh))
for imgFileName in ${allIMGfileNamesArray[@]}
{
	imagePath=`expr match "$imgFileName" '\(.*\/\).*'`
	exiftool "$imgFileName" > "$imgFileName"_simpleEXIFinfo.txt
}