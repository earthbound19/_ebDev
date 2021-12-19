# DESCRIPTION
# Copies the video stream (so, lossless transcoding) of rated electric sheep .avi files (from the electric sheep content folder) into .mp4 videos in a specified directory. Examines the list_member.xml file to do so.

# DEPENDENCIES
# Electric Sheep screensaver, a 'Nixy environment (coded for MSYS2 on Windows)

# USAGE
# Set the variables at the start of the script per the locations of various files in your Electric Sheep screensaver install, and run the script without any parameter:
#    ripAndTagRatedSheep.sh


# CODE
# TO DO: only copy files that do not already have a transcoded target, and create a script that runs this periodically (a chron job would do on 'nix systems).

# Global PATH VARIABLES:
sheep_content_XML_path='/c/ProgramData/ElectricSheep/content/xml'
sheep_content_XML_file='list_member.xml'
sheep_avis_local_path='/c/ProgramData/ElectricSheep/content/mpeg'
sheep_transcodedDestPath='/c/ratedSheep'
# END global PATH VARIABLES

sed -n 's/.*rating=\"\([0-9]\{1,\}\)\".*url=\"\(.*\)\".*/\1 \2/p' $sheep_content_XML_path\\$sheep_content_XML_file > ratedSheepAndURLs.txt
sed '/^0 .*/d' ratedSheepAndURLs.txt > temp.txt
sort -g -r temp.txt > temp2.txt
rm temp.txt ratedSheepAndURLs.txt
mv temp2.txt ratedSheepAndURLs.txt
mapfile -t sortedRatedSheep < ratedSheepAndURLs.txt

# TO DO, make this conditional:
# mkdir ../_lossless_transcoded_tag-rated

for element in "${sortedRatedSheep[@]}"
do
	# get rating:
	rating=`echo $element | sed 's/^\([0-9]\{1,\}\) .*/\1/g'`
		echo rating is\: $rating
	# get URL:
	URL=`echo $element | sed 's/^[0-9]\{1,\} \(.*\)/\1/g'`
		# echo URL is\: $URL
	localFile=`echo $URL | sed 's/.*\/\(.*\)/\1/g'`
	localFile="$sheep_avis_local_path/$localFile"
		echo local file name is\: $localFile
	localFileNoEXT=${localFile%.*}
		# echo local file name without extension is\: $localFileNoEXT
	# Losslessly transcode and embed rating in metadata only if target file does not already exist:
	i=0
	# if the following file does not exist, do stuff:
	if [ ! -e "$sheep_transcodedDestPath\\$localFileNoEXT.mp4" ]
	then
		i=$[ $i + 1]
		DOSlocalFilePath=`cygpath -w $sheep_avis_local_path`
		FFMPEGcommand="ffmpeg -y -i $DOSlocalFilePath\\$localFileNoEXT.avi -vcodec copy $sheep_transcodedDestPath\\$localFileNoEXT.mp4"
		echo Target transcoded file does not exist\; will create . . .
		$FFMPEGcommand
		exiftool -overwrite_original -MWG:Rating="$rating" "$sheep_transcodedDestPath\\$localFileNoEXT.mp4"
		echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
	fi
done

echo losslessly transcoded and updated metadata for $i new animated fractal flames.