# DESCRIPTION
# Creates an mp4 video (AVC) from a series of numbered input images. Automatically detects the number of digits in the input frames. Expects *only* digits in the input filenames. Creates the animation at _out.mp4. NOTE: you may want to use x264anim.sh instead.

# WARNING: AUTOMATICALLY overwrites _out.mp4 if it already exists.

# USAGE
# From the directory with the image animation source images, invoke this script with these parameters:
# $1 input "frame rate" (how to interpret the speed of input images in fps)
# $2 desired output framerate
# $3 desired constant quality (crf)
# $4 the file extension of the input images.
# Optional: $5 nearest neighbor method rescale target resolution expressed as N[NN..]xN[NN..], for example 200x112; OR to scale to one target dimension and calculate the other automatically (to maintain aspect), give e.g. 1280:-1 (to produce an image that is 1280 pix wide by whatever the other dimension should be). Nearest-neighbor keeps hard edges. If you must include this parameter but don't want to resize (because you're using $6), pass the word NULL as $5.
# Optional: $6 how many seconds to loop the last frame, to create a long still of the last frame appended to the end of the video. Creates the still loop as _append.mp4, then muxes _out.mp4 and _append.mp4 to a temp mp4, deletes both the originals and renames the temp to _out.mp4.
# EXAMPLE
# thisScript.sh 29.97 29.97 13 png
# ALSO, search for the additionalParams options and uncomment or modify them (or don't) as you wish.

# NOTE: You can hack this script to produce an animated .gif image simply by changing the extension at the end of the applicable command line (line 32).

# TO DO
# - Optional: padding re https://superuser.com/a/690211
# - Make it name the output file after the ../.. parent folder name?


# CODE
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

# Assumes that all input files have the same character count in the file base name; I wonder whether I've gone full circle on going away from and back to the exact form of the following command, but *right now* it's testing ok on Cygwin and Mac; re https://stackoverflow.com/a/40876071 ; ALSO it seems as if gnuWin32 `find`has a bug; the command throws an error.
# EXCEPT all those notes may only apply to the next line's DEPRECATED (indented, commented) command? :
	# array=(`gfind . -maxdepth 1 -type f -iname \*.$4 -printf '%f\n' | tr -d '\15\32'`)
array=(`gfind . -maxdepth 1 -type f -name "*.$4" -printf '%f\n'`)
# last element of array is last found file type $4 :
lastFoundFileType=${array[-1]}
lastFoundTypeFileNameNoExt=${lastFoundFileType%.*}
digitsPadCount=${#lastFoundTypeFileNameNoExt}

# IN DEVELOPMENT: automatic centering of image in black matte borders (padding):
# steps:
# - get matte WxH intended
# - get src images to anim WxH
# - div. matte W / 2 for center X pixmark
# - div. src image W / 2 for offset from matte center X pixmark
# - subtr. offset from center X pixmark for X pixmark to place src images at.
# - Follow same process on Y to get Y offset pixmark and place src images there.
# - formulate ur paramater to pass to ffmpeg from that; in form:
# padParams=-vf "pad=width=1920:height=1080:x=0:y=0:color=black"
# ex commands to fetch and parse src pix dimensions is in getDoesIMGinstagram.sh.
# an example command wut does some math as would be needed per this algo: echo "scale=5; 3298 / 1296" | bc
# OR JUST?! :
# additionalParams="-vf scale=-1:1080:force_original_aspect_ratio=1,pad=1920:1080:(ow-iw)/2:(oh-ih)/2"
# ASSUMING 1920x1420 input image, crop to center; NOTE that it necessarily escapes double-quote marks with \:
# additionalParams=-filter:v "crop=1920:1080"
# echo "-filter:v \"crop=1920:1080\"" > tmp_blaheryeag_nbD9X44rCJev.txt && additionalParams=$(<tmp_blaheryeag_nbD9X44rCJev.txt) && rm tmp_blaheryeag_nbD9X44rCJev.txt

# Because something funky and evil in DOS and/or unix emulation chokes on some forms of $additionalParams inline, but not if printed to and executed from a script;
# FOR LOSSLESS BUT COMPRESSED AVI, end the command instead with: -codec:v utvideo _out.avi :
echo "ffmpeg -y -f image2 -framerate $1 -i %0"$digitsPadCount"d.$4 $additionalParams $rescaleParams -r $2 _out.mp4" > tmp_enc_script_P4b3ApXC.sh
./tmp_enc_script_P4b3ApXC.sh
rm ./tmp_enc_script_P4b3ApXC.sh

# If $6 is passed to the script, create a looped still video ($6 seconds long) from the last frame and append it to the video:
if [ "$6" ]
then
	ffmpeg -y -loop 1 -i $lastFoundFileType -vf fps=$2 -t $6 -crf $3 _append.mp4
	printf "" > tmp_ft2N854f.txt
	echo _out.mp4 >> tmp_ft2N854f.txt
	echo _append.mp4 >> tmp_ft2N854f.txt
	gsed -i "s/^\(.*\)/file '\1'/g" tmp_ft2N854f.txt
	ffmpeg -y -f concat -i tmp_ft2N854f.txt -c copy _tmp_TXF6PmWe.mp4
	rm ./tmp_ft2N854f.txt
	rm ./_out.mp4 ./_append.mp4
	mv ./_tmp_TXF6PmWe.mp4 ./_out.mp4
fi
