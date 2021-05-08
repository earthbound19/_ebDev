# DESCRIPTION
# Creates an mp4 video (AVC) from a series of numbered input images. Automatically detects the number of digits in the input frames. Expects *only* digits in the input filenames. Creates the animation at _out.mp4. NOTE: you may want to use x264anim.sh instead.

# WARNING
# This script overwrites _out.mp4 if it already exists.

# USAGE
# From the directory with the image animation source images, run this script with these parameters:
# - $1 input "frame rate" (how to interpret the speed of input images in fps)
# - $2 desired output framerate
# - $3 desired constant quality (crf)
# - $4 the file extension of the input images.
# - $5 OPTIONAL. Nearest neighbor method rescale target resolution expressed as N[NN..]xN[NN..], for example 200x112; OR to scale to one target dimension and calculate the other automatically (to maintain aspect), give e.g. 1280:-1 (to produce an image that is 1280 pix wide by whatever the other dimension should be). Nearest-neighbor keeps hard edges. If you must include this parameter but don't want to resize (because you're using $6), pass the word NULL as $5.
# - $6 OPTIONAL. How many seconds to loop the last frame, to create a long still of the last frame appended to the end of the video. Creates the still loop as _append.mp4, then muxes _out.mp4 and _append.mp4 to a temp mp4, deletes both the originals and renames the temp to _out.mp4.
# Example run:
#    ffmpegAnim.sh 29.97 29.97 13 png
# NOTES
# - Search for the pixelFormat parameter and modify it or don't.
# - Search for the additionalParams options and uncomment or modify them (or don't) as you wish.
# - You can hack this script to produce an animated .gif image simply by changing the extension at the end of the applicable command line (line 32).


# CODE
# TO DO
# - Optional: padding re https://superuser.com/a/690211
# - Make it name the output file after the ../.. parent folder name?

if [ "$5" ]
then
	if [ "$5" != "NULL" ]		# If we want to use $6 but not $5 (as $6 is positional), we use NULL for $5.
	then
		rescaleParams="-vf scale=$5:-1:flags=neighbor"
			# echo rescaleParams val is\:
			# echo $rescaleParams
	else
		echo parameter 5 was the string \"NULL\"\. Will not use.
	fi
fi

array=( $(find . -maxdepth 1 -type f -name "*.$4" -printf '%f\n') )
# last element of array is last found file type $4 :
lastFoundFileType=${array[-1]}
lastFoundTypeFileNameNoExt=${lastFoundFileType%.*}
digitsPadCount=${#lastFoundTypeFileNameNoExt}

# ex commands to fetch and parse src pix dimensions is in getDoesIMGinstagram.sh.
# also could do bc math e.g: echo "scale=5; 3298 / 1296" | bc
# constructing an additionalParams arg via piping and read?! :
# echo "-filter:v \"crop=1920:1080\"" > tmp_blaheryeag_nbD9X44rCJev.txt && additionalParams=$(<tmp_blaheryeag_nbD9X44rCJev.txt) && rm tmp_blaheryeag_nbD9X44rCJev.txt

# OPTIONAL additionalParams; uncomment / tweak any; NOTE that some necessarily escape double-quote marks with \:	a previously used color: #362e2c
# additionalParams='-vf "scale=-1:1080:force_original_aspect_ratio=1,pad=1920:1080:(ow-iw)/2:color=#f2e0c9"'
# additionalParams=-filter:v "crop=1920:1080"

# yuv420p is apparently required by instagram and probably facebook and others:
pixelFormat="-pix_fmt yuv420p"

# Because something funky and evil in DOS and/or Unix emulation chokes on some forms of $additionalParams inline, but not if printed to and executed from a script;
# FOR LOSSLESS BUT COMPRESSED AVI, end the command instead with: -codec:v utvideo _out.avi :
echo "ffmpeg -y -f image2 -framerate $1 -i %0"$digitsPadCount"d.$4 $additionalParams $rescaleParams -r $2 $pixelFormat _out.mp4" > tmp_enc_script_P4b3ApXC.sh
./tmp_enc_script_P4b3ApXC.sh
rm ./tmp_enc_script_P4b3ApXC.sh

# If $6 is passed to the script, create a looped still video ($6 seconds long) from the last frame and append it to the video:
if [ "$6" ]
then
	ffmpeg -y -loop 1 -i $lastFoundFileType -vf fps=$2 -t $6 -crf $3 $pixelFormat _append.mp4
	printf "" > tmp_ft2N854f.txt
	echo _out.mp4 >> tmp_ft2N854f.txt
	echo _append.mp4 >> tmp_ft2N854f.txt
	sed -i "s/^\(.*\)/file '\1'/g" tmp_ft2N854f.txt
	ffmpeg -y -f concat -i tmp_ft2N854f.txt -c copy _tmp_TXF6PmWe.mp4
	rm ./tmp_ft2N854f.txt
	rm ./_out.mp4 ./_append.mp4
	mv ./_tmp_TXF6PmWe.mp4 ./_out.mp4
fi
