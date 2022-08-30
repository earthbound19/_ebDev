# DESCRIPTION
# Extracts embedded raw image and xmp sidecar from DNG file $1, then deletes the DNG only if there was no error extracting the raw image. Does not overwrite raw image files that would be overwritten if they already exist, and notifies that they already exist. Also, warns if extracted raw file is different from any found raw file of the same file name. Also, it sets the timestamps of the extracted raw files (from their metadata) to match their creation/modify dates.

# WARNINGS
# - If this script deletes a DNG file, the delete is permanent and irreversible! 
# - This script makes a perhaps invalid assumption that only one embedded raw file per DNG file. The DNG command line options mention the possibility of extracting file(s) (possibly more than one file).

# DEPENDENCIES
# adobeDNGconverter, exiftool, toOldestWindowsDateTime.sh, and binarez_touch (Windows only!), all in your PATH.

# USAGE
# Run with these parameters:
# - $1 source dng format file name to extract these from.
# For example:
#    extractXMPandEmbeddedRAWfromDNGandDestroyDNG.sh DSC_0150.dng
# NOTES
# How this avoids clobbering raw files that already exist:
# - extracts raw files to a randomly named temporary subfolder
# - checks for duplicate file name of file extracted to temp subfolder vs. original parent folder. If it doesn't exist in the parent folder, it moves file from tmp subfolder to current folder.

# CODE
# TO DO: make $extractedRawFileName a proper array in case of multiple embedded files, and iterate over the array. And code for the possibility of multiple file names in that case. OR: just leave off with the warning above about that possibility, as I never would have made a multiple-raw-file DNG!
# SET GLOBALS:
if [ ! "$1" ]; then printf "\nNo parameter \$1 (type short explanation of parameter) passed to script. Exit."; exit 1; else sourceFile=$1; fi
extractedSideCarDifferent=0

export LC_CTYPE=C
rndSTR=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 11)
tmpSubdir=_tmpSubdir_$rndSTR

currDir=$(pwd)

if [ ! -d $tmpSubdir ]; then mkdir $tmpSubdir; fi
cd $tmpSubdir
cp ../$sourceFile .
# extract original raw file from dng:
adobeDNGconverter -x $sourceFile
rawExtractErrorLevel="$?"

# put the file name in variable, which will be the file name of the extracted raw file:
extractedRawFileName=$(find . -printf "%P" | tr -d '\15\32')
# conditionally reconstruct an xmp sidecar from a dng such as will still be recognized and used by camera raw; first make variable with blank value which may be overwritten:
targetXMPfileName=""
if [[ "$extractedRawFileName" != "" ]]
then
	targetXMPfileName=${extractedRawFileName%.*}.xmp
	# annoying call to echo | tr, to delete windows newline that mucks up possible printf statement later:
	targetXMPfileName=$(echo $targetXMPfileName | tr -d '\15\32')
	exiftool -tagsfromfile ../$sourceFile -all:all $targetXMPfileName
fi

# if extracted raw file name does not exist in the directory above this temp directory (AND there was any file extracted at all), copy this extracted raw file there after setting its timestamps per my windows preferences (copying it because we want to keep a copy her temporarily for reference) :
if [[ ! -f "../$extractedRawFileName" ]] && [[ "$extractedRawFileName" != "" ]]
then
	toOldestWindowsDateTime.sh $extractedRawFileName
	cp $extractedRawFileName ..
else
	printf "\nExtracted raw file name target $extractedRawFileName already exists; will not overwrite. (If there was a double space printed there, no raw file was extracted and may not exist in the source file.) To extract the raw file from the dng and put it in this folder, either delete that target file that already exists ($extractedRawFileName), or move it to a different folder. (But if there's no raw file embedded, you won't be able to extract anything.) Extraction skipped.\n"
	# check if the discovered identical file names have identical content, and warn if not so:
	# srsly why does sha256sum not have "print only the checkum" option? -- so parsing it with sed:
	if [[ "$extractedRawFileName" != "" ]]
	then
		checksum1=$(sha256sum ../$extractedRawFileName | sed 's/\([0-9a-f]\{1,\}\).*/\1/g')
		checksum2=$(sha256sum $extractedRawFileName | sed 's/\([0-9a-f]\{1,\}\).*/\1/g')
		if [ "$checksum1" != "$checksum2" ]
		then
			printf "\nALSO, WARNING: checksum of extracted raw file $extractedRawFileName vs. the one already in directory '$currDir' were different. It's possible that either the one outside the dng or inside were altered, or both."
		fi
	fi
fi

# if extracted xmp sidecar file name does not exist in the directory above this temp directory (AND any sidecar was extracted (target sidecar name was not blank), move this extracted sidecar file there after setting its timestamps per my windows preferences:
if [[ ! -f "../$targetXMPfileName" ]] && [[ "$targetXMPfileName" != "" ]]
then
	binarez_touch -m -x -r $extractedRawFileName $targetXMPfileName
	cp $targetXMPfileName ..
else
	printf "\nExtracted xmp file name target $targetXMPfileName already exists; will not overwrite. To extract the xmp file from the dng and put it in this folder, either delete that target file that already exists ($targetXMPfileName), or move it to a different folder. Extraction skipped.\n"
	# check if the discovered identical file names have identical content, and warn if not so:
	if [[ "$targetXMPfileName" != "" ]]
	then
		checksum1=$(sha256sum ../$targetXMPfileName | sed 's/\([0-9a-f]\{1,\}\).*/\1/g')
		checksum2=$(sha256sum $targetXMPfileName | sed 's/\([0-9a-f]\{1,\}\).*/\1/g')
		if [ "$checksum1" != "$checksum2" ]
		then
			extractedSideCarDifferent=1
			printf "\nALSO, WARNING: checksum of extracted xmp file $targetXMPfileName vs. the one already in directory '$currDir' were different. It's possible that either the one outside the dng or inside were altered, or both. OR It may be that exiftool didn't extract it in the same way that Adobe tools do."
		fi
	fi
fi

cd ..

# remove tmp subdir and its contents:
rm -rf $tmpSubdir

if [ $rawExtractErrorLevel == 0 ] && [ $extractedSideCarDifferent == 0 ]
then
	rm $sourceFile
else
	printf "\n\nNOTE: there was either a problem extracting a raw file from the DNG or the DNG has no embedded raw file. Therefore the DNG source file $sourceFile was left alone (not deleted), so you can examine it."
fi
