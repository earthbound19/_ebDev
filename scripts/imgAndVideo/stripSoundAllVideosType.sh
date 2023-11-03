# DESCRIPTION
# Losslessly strips sound from all videos of type $1 (parameter 1). (Lossless because it copies the video stream; it does not alter or recompress the stream). Preserves a copy of the original file by renaming it to <original_file>_backup.<original_extension>. The video that has the original video stream but no sound is named after the original file.

# USAGE
# Run with these parameters:
# - $1 the extension of videos you wish to remove sound from
# For example, to remove sound from all video files with the extension mp4, run:
#    stripSoundAllVideosType.sh mp4


# CODE
if [ "$1" ]; then sourceFileExt=$1; else printf "\nNo parameter \$1 (the extension of videos you wish to strip sound from) passed to script. Exit."; exit 1; fi

if ! [ "$1" ]; then printf "\nNo parameter 1 (video file type). Exit."; exit; fi

allVideosArray=( $(find . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n') )

for filename in ${allVideosArray[@]}
do
	ffmpeg -y -i "$filename" -map 0:v -vcodec copy "filename"_temp.mp4
	mv "$filename" "$filename""_backup"."$sourceFileExt"
	mv "filename"_temp.mp4 "$filename"
done

printf "\nDONE. Check all the converted videos for errors. If there were any conversion errors, you can restore from the originals which were renamed \<original_file\>_backup.$sourceFileExt. To save space you may want to delete originals after verifying the sound-stripped video stream copy files are okay."