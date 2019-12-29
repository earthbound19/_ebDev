# DESCRIPTION
# Convert all .swf format videos (in the folder from which this script is run) to animated .gifs and lossless .mp4 video files. Will not overwrite existing files; if you wish to recreate the targets, delete the pre-existing target file, then run this script again.

# USAGE
# With this script and ffmpeg in your $PATH, run this script from the terminal by typing the name of this script and <ENTER>.

# Thanks to the following post for giving me a lead on this: http://www.answers.com/Q/How_do_convert_scr_to_avi -- and this (for the -vf reverse switch) http://stackoverflow.com/questions/2553448/encode-video-in-reverse :

# An alternative approach: https://gist.github.com/hfossli/6003302

gfind *.swf > swfs.txt
mapfile -t swfs < swfs.txt
rm swfs.txt
for element in "${swfs[@]}"
do
# NOTE: for strange flash videos that encode in reverse, use the -vf reverse flag before the output file in ffmpeg.
	if ! [ -e "$element.gif" ]
		then
			ffmpeg -i "./$element" "$element.gif"
	fi
	if ! [ -e "$element.mp4" ]
		then
			ffmpeg -i "./$element" -crf 0 "$element.mp4"
		fi
done