# DESCRIPTION
# Copies the video stream (lossless transcoding) of rated electric sheep .avi files (from the electric sheep content folder) into .mp4 videos in a specified directory. Examines the list_member.xml file to do so.

# DEPENDENCIES
# Electric Sheep screensaver, a 'Nixy environment (coded for MSYS2 on Windows)

# USAGE
# Set the variables at the start of the script per the locations of various files in your Electric Sheep screensaver install, and run the script without any parameter:
#    ripAndTagRatedSheep.sh


# CODE
# Global PATH VARIABLES:
sheep_content_XML_path='/c/ProgramData/ElectricSheep/content/xml/list_member.xml'
sheep_avis_local_path='/c/ProgramData/ElectricSheep/content/mpeg/'
# NOTE: THE CODE ASSUMES that this path doesn't end with a forward slash '/':
sheep_transcodedDestPath='/c/ratedSheep'
# END global PATH VARIABLES

# check paths and if any does not exist, error out.
# I wanted to hide any error print with &>/dev/null but it's not liking that in the command substitution $() :
if [[ ! $(ls "$sheep_content_XML_path") ]]; then printf "\nERROR: path \$sheep_content_XML_path does not exist: $sheep_content_XML_path -- exit."; exit 1; fi
if [[ ! $(ls $sheep_avis_local_path) ]]; then printf "\nERROR: path \$sheep_avis_local_path does not exist: $sheep_avis_local_path -- exit."; exit 1; fi
if [[ ! $(ls $sheep_transcodedDestPath) ]]; then printf "\nERROR: path \$sheep_transcodedDestPath does not exist: $sheep_transcodedDestPath -- exit."; exit 1; fi

OIFS="$IFS"
IFS=$'\n'
# the below puts many former commands and temp file parses into one line; it extracts the rating and urls from the xml file into an array, one rating and URL per entry:
sheepses=( $(sed -n 's/.*rating=\"\([0-9]\{1,\}\)\".*url=\"\(.*\)\".*/\1 \2/p' $sheep_content_XML_path | sort -g -r | sed '/^0 .*/d') )

for element in "${sheepses[@]}"
do
	# get rating:
	rating=`echo $element | sed 's/^\([0-9]\{1,\}\) .*/\1/g'`
		# echo rating is\: $rating
	# get URL:
	URL=`echo $element | sed 's/^[0-9]\{1,\} \(.*\)/\1/g'`
		# echo URL is\: $URL
	localFile=`echo $URL | sed 's/.*\/\(.*\)/\1/g'`
	localFile="$sheep_avis_local_path/$localFile"
		# echo local file name is\: $localFile
	localFileNoEXT=${localFile%.*}
		# echo local file name without extension is\: $localFileNoEXT
	localFileNoPathOrEXT="${localFileNoEXT##*/}"
		# echo local file name without path OR extension is\: $localFileNoPath	
	# if the source file does not exist, attempt to retrieve it from archive.org:
	if [[ ! -f $localFile ]]
	then
		# download, writing to missing local path, redirecting stdout print to null:
		wget --no-check-certificate -O $localFile $URL &>/dev/null
		# check if there was a download error via errorlevel; if there is, skip this loop iteration as conversion will not be possible:
		if [ "$?" != "0" ]; then echo "WARNING: local file $localFile does not exist and could not download from $URL. Skipping conversion."; continue; fi
	fi
	# Losslessly transcode and embed rating in metadata only if target file does not already exist:
	# if the destination file does not exist, do stuff:
	if [ ! -e "$sheep_transcodedDestPath\\$localFileNoEXT.mp4" ]
	then
		# DOSlocalFilePath=`cygpath -w $sheep_avis_local_path`
		ffmpeg -y -i $DOSlocalFilePath""$localFileNoEXT"".avi -vcodec copy $sheep_transcodedDestPath""/""$localFileNoPathOrEXT"".mp4
#		echo Target transcoded file does not exist\; will create . . .
		$FFMPEGcommand
		exiftool -overwrite_original -MWG:Rating="$rating" "$sheep_transcodedDestPath""/""$localFileNoPathOrEXT"".mp4"
#		echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
	fi
done

IFS="$OIFS"
echo Attempted to losslessly transcode and update metadata for ${#sheepses[@]} animated fractal flames.