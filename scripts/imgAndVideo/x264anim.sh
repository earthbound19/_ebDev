# DESCRIPTION
# Encodes a lossless .avi, then a lossy h264 stream from that, then
# puts the h264 stream in an .mp4 container, and discards the temp
# .h264 and .avi files. Adapted from ffmpegAnim.sh.

# WARNING: AUTOMATICALLY overwrites _out.mp4 if it already exists.

# USAGE
# From the directory with the image animation source images, invoke this script with these parameters:
# $1 input "frame rate" (how to interpret the speed of input images in fps)
# $2 desired output framerate
# $3 desired constant quality (crf)
# $4 the file extension of the input images.
# Optional: $5 nearest neighbor method rescale target resolution expressed as N[NN..]xN[NN..], for example 200x112; OR to scale to one target dimension and calculate the other automatically (to maintain aspect), give e.g. 1280:-1 (to produce an image that is 1280 pix wide by whatever the other dimension should be). Nearest-neighbor keeps hard edges.
# Optional: $6 how many seconds to loop the last frame, to create a long still of the last frame appended to the end of the video. Creates the still loop as _append.mp4, then muxes _out.mp4 and _append.mp4 to a temp mp4, deletes both the originals and renames the temp to _out.mp4. UGLY KLUDGE: if you want to use this but not $5, pass the word NULL as $5.
# EXAMPLE
#  x264anim.sh 29.97 29.97 13 png
# ALSO, search for the additionalParams options and uncomment or modify them (or don't) as you wish.

# NOTE: You can hack this script to produce an animated .gif image simply by changing the extension at the end of the applicable command line (line 32).

# TO DO
# - anything I do in ffmpegAnim that isn't in this.


# CODE
if [ "$5" ]
then
	if [ $5 != "NULL" ]		# If we want to use $6 but not $5 (as $6 is positional), we use NULL for $5.
	then
		rescaleParams="-vf scale=$5:-1:flags=neighbor"
			# echo rescaleParams val is\:
			# echo $rescaleParams
	else
		echo parameter 5 was the string \"NULL\"\. Will not use.
	fi
fi


array=(`find . -maxdepth 1 -type f -iname \*.$4 -printf '%f\n' | tr -d '\15\32'`)
# last element of array is last found file type $4 :
lastFoundFileType=${array[-1]}
lastFoundTypeFileNameNoExt=${lastFoundFileType%.*}
digitsPadCount=${#lastFoundTypeFileNameNoExt}

# additionalParams='-vf scale=-1:1080:force_original_aspect_ratio=1,pad=1920:1080:(ow-iw)/2:(oh-ih)/2'
# ASSUMING 1920x1420 input image, crop to center; NOTE that it necessarily escapes double-quote marks with \:
# additionalParams=-filter:v "crop=1920:1080"
echo "-filter:v \"crop=1920:1080\"" > tmp_blaheryeag_nbD9X44rCJev.txt && additionalParams=$(<tmp_blaheryeag_nbD9X44rCJev.txt) && rm tmp_blaheryeag_nbD9X44rCJev.txt

echo executing ffmpeg command ffmpeg -y -f image2 -framerate $1 -i %0"$digitsPadCount"d.$4 $additionalParams $rescaleParams -r $2 -codec:v utvideo _out.avi . . .
# Because something funky and evil in DOS and/or unix emulation chokes on some forms of $additionalParams inline, but not if printed to and executed from a script:
echo "ffmpeg -y -f image2 -framerate $1 -i %0"$digitsPadCount"d.$4 $additionalParams $rescaleParams -r $2 -codec:v utvideo _out.avi" > tmp_enc_script_P4b3ApXC.sh
./tmp_enc_script_P4b3ApXC.sh
rm ./tmp_enc_script_P4b3ApXC.sh

# If $6 is passed to the script, create a looped still video ($6 seconds long) from the last frame and append it to the video:

if [ "$6" ]
then
	ffmpeg -y -loop 1 -i $lastFoundTypeFile -vf fps=$2 -t $6 -crf $3 -codec:v utvideo _append.avi
	printf "" > tmp_ft2N854f.txt
	echo _out.avi >> tmp_ft2N854f.txt
	echo _append.avi >> tmp_ft2N854f.txt
	sed -i "s/^\(.*\)/file '\1'/g" tmp_ft2N854f.txt
	ffmpeg -y -f concat -i tmp_ft2N854f.txt -c copy _tmp_TXF6PmWe.mp4
	rm ./tmp_ft2N854f.txt
	rm ./_out.avi ./_append.avi
	mv ./_tmp_TXF6PmWe.mp4 ./_out.avi
fi

x264 _out.avi --opencl --crf 11 --input-res 1920x1080 -o _out.h264
ffmpeg -y -i _out.h264 -vcodec copy _out.mp4
rm _out.h264 _out.avi