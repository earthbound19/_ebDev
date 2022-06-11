# DESCRIPTION
# Creates a ~/metaDataTemplatesPath.txt file, which contains the path to the directory of this script (which should be the same as metadata template files in the same folder with this script). The metaDataTemplatesPath.txt file is used by other scripts in this development toolset.

# DEPENDENCIES
# You'll only get use out of this if it is in the same directory with metadata template files, like these:
#    customImageMetadataTemplate.txt
#    DrawnColorVectorArtMetadataTemplate.txt

# USAGE
# From the directory in which this script resides (which should have other files such as those listed in DEPENDENCIES), run this script without any parameter:
#    setMetaDataTemplatesPathFile.sh

# CODE

scriptPathNoFileName="${0%\/*}"

if [ ! -f ./customImageMetadataTemplate.txt ]
then
	printf "\n~~~~!\nERROR: expected metadata template file ./customImageMetadataTemplate.txt is not in the directory you're executing this script from. Make sure to run this script from the directory it exists in:\n\n$scriptPathNoFileName\n"
	exit 1
else
	currDir=$(pwd)
	printf "$currDir" > ~/metaDataTemplatesPath.txt
	printf "\nPATH TO metadata templates (and also where this script is: $currDir) written to:\n~/metaDataTemplatesPath.txt\n"
fi
