# DESCRIPTION: Copies the video stream (so, lossless transcoding) of rated electric sheep .avi files (from the electric sheep content folder) into .mp4 videos in a specified directory.

# USAGE: Set the appropriate path variables at the start of the script, and run the script.

# TO DO: only copy files that do not already have a transcoded target, and create a script that runs this periodically (a chron job would do on 'nix systems).

# Global PATH VARIABLES:
sheep_content_XML_path='H:\_electricsheep\content\xml'
cyg_sheep_content_XML_path=`cygpath -u $sheep_content_XML_path`
sheep_content_XML_file='list_member.xml'
sheep_avis_local_path=`cygpath -u 'H:\_electricsheep\content\mpeg'`
sheep_transcodedDestPath='H:\_losslessTranscodedTaggedSheep'
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
	localFileNoEXT=`echo $localFile | sed 's/.*\/\(.*\)\.avi/\1/g'`
		# echo local file name without extension is\: $localFileNoEXT
	# Losslessly transcode and embed rating in metadata only if target file does not already exist:
	if [ -a "$sheep_transcodedDestPath\\$localFileNoEXT.mp4" ]
	then
# TO DO: There has to be a way to check existence (not non-existence) of a file, yes?
		FEERP=bEEERP
	else
		echo bunniesooooooooooooooooooooooooooooooorp
		DOSlocalFilePath=`cygpath -w $sheep_avis_local_path`
		FFMPEGcommand="ffmpeg -y -i $DOSlocalFilePath\\$localFileNoEXT.avi -vcodec copy $sheep_transcodedDestPath\\$localFileNoEXT.mp4"
		echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
		$FFMPEGcommand
		exiftool -overwrite_original -MWG:Rating="$rating" "$sheep_transcodedDestPath\\$localFileNoEXT.mp4"
		echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
	fi
done