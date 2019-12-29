# Invoke this with one paramater, being the extension of videos you wish to strip of sound.

fileExt=$1
allFilesTXTfile="all_""$fileExt"

gfind ./*.$1 > $allFilesTXTfile

while read filename
do
	fileBasename=`basename $filename ".""$fileExt"`
	ffmpeg -y -i "$filename" -map 0:v -vcodec copy "filename"_temp.mp4
	mv "$filename" "$filename""_backup"."$fileExt"
	mv "filename"_temp.mp4 "$filename"
done < $allFilesTXTfile

rm $allFilesTXTfile

echo DONE. Check all the converted videos for errors. If there were any conversion errors, you can restore from the originals which were renamed \<filename\>_backup.$fileExt. To save space you may want to delete originals after verifying the sound-stripped video stream copy files are okay.