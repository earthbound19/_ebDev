# DESCRIPTION
# Losslessly removes sound from all videos of type $1 (parameter 1), renaming the previous version of the file to <filename>_backup.ext, and putting the video with sound stripped in place of the original file name.

# USAGE
# Run with one parameter, which is the extension of videos you wish to strip of sound, e.g.:
#    stripSoundAllVideos.sh


# CODE
fileExt=$1

if ! [ "$1" ]; then printf "\nNo parameter 1 (video file type). Exit."; exit; fi

allVideosArray=(`find . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n'`)

for filename in ${allVideosArray[@]}
do
	ffmpeg -y -i "$filename" -map 0:v -vcodec copy "filename"_temp.mp4
	mv "$filename" "$filename""_backup"."$fileExt"
	mv "filename"_temp.mp4 "$filename"
done

printf "\nDONE. Check all the converted videos for errors. If there were any conversion errors, you can restore from the originals which were renamed \<filename\>_backup.$fileExt. To save space you may want to delete originals after verifying the sound-stripped video stream copy files are okay."