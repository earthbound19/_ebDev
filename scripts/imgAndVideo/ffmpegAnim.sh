# DESCRIPTION
# Creates an mp4 video (AVC) from a series of numbered input images. Automatically detects the number of digits in the input frames. Expects *only* digits in the input filenames. Will automatically use the lowest found number for start frame number. Creates the animation at _out.mp4. NOTE: you may want to use x264anim.sh instead. See also stillIMGsAndSoundToVid.sh for video animation dubbing (matching the frame rate of source images to a the duration of a source sound).

# WARNING
# This script overwrites _out.mp4 if it already exists.

# USAGE
# From the directory with the image animation source images, run this script with these parameters:
# - $1 input "frame rate" (how to interpret the speed of input images in fps). Suggested range for abstract / noise art: anywhere from ~0.9 (a bit more than a still per second) to 7 (7 stills per second). To use an input frames per second that is a randomly chosen number in a hard-coded range (see `seq` command in script), pass the keyword 'RND' for $1.
# - $2 desired output framerate
# - $3 desired constant quality (crf)
# - $4 the file extension of the input images.
# - $5 OPTIONAL. Nearest neighbor method rescale target resolution expressed as N[NN..]xN[NN..], for example 200x112; OR to scale to one target dimension and calculate the other automatically (to maintain aspect), give e.g. 1280:-1 (to produce an image that is 1280 pix wide by whatever the other dimension should be). Nearest-neighbor keeps hard edges. If you must include this parameter but don't want to resize (because you're using $6), pass the word NULL as $5.
# - $6 OPTIONAL. How many seconds to loop the last frame, to create a long still of the last frame appended to the end of the video. Creates the still loop as _append.mp4, then muxes _out.mp4 and _append.mp4 to a temp mp4, deletes both the originals and renames the temp to _out.mp4.
# Example run:
#    ffmpegAnim.sh 29.97 29.97 13 png
# NOTES
# - Search for the pixelFormat variable, and modify it, or don't.
# - Also search for an outExt parameter, and modify it, or don't.
# - Search for the additionalParams options and uncomment or modify them (or don't) as you wish.
# - You can hack this script to produce an animated .gif image simply by changing the extension at the end of the applicable command line (line 32).


# CODE
# TO DO
# - Make the output file name after the ../.. parent folder name? Or just the parent folder name? IF YOU DO THAT, modify scripts that call this script (ffmpegAnimsDirs.sh and maybe others?) to no longer do output file renaming.
# - parameterize as in newGetoptScript.sh? Because it's already at too many parameters, and I want to add to it.. 
#  - and update all scripts that call this, and any scripts that call them, with the new parameters
# - add option to define output extension (e.g. gif, mkv ..)
# - update doc if I do those things.

# GLOBAL that I would like to turn into a parameter; the output file extension (for example mp4, gif, mkv)
outExt=mp4

# ==== BEGIN PARAMETER CHECKING and globals setting therefrom.
if [ ! "$1" ]
then
	printf "\nNo parameter \$1 (input frame rate) passed to script. Exit."
	exit 1
else
	if [ "$1" == "RND" ]
	then
		inFPS=$(seq 0.9 0.1 9 | shuf | head -n1)
		# echo source FPS set to randomly chosen number $inFPS.
	else
		inFPS=$1
		# echo source FPS is $inFPS.
	fi
fi

if [ ! "$2" ]; then printf "\nNo parameter \$2 (output frame rate) passed to script. Exit."; exit 2; else outFPS=$2; fi

if [ ! "$3" ]; then printf "\nNo parameter \$3 (constant rate factor, or quality, where 0 is best and 50 is worst) passed to script. Exit."; exit 3; else crf=$3; fi

if [ ! "$4" ]; then printf "\nNo parameter \$4 (file extension of input images) passed to script. Exit."; exit 4; else inFileType=$4; fi

if [ "$5" ] && [ "$5" != "NULL" ]		# If we want to use $6 but not $5 (as $6 is positional), we use NULL for $5.
then
	rescaleParams="-vf scale=$5:flags=neighbor"
	# echo rescaleParams val is\:
	# echo $rescaleParams
else
	echo parameter 5 was absent or the string \"NULL\"\. Will not use.
fi

if [ "$6" ]; then finalLoopSeconds=$6; fi
# ==== END PARAMETER CHECKING and globals setting therefrom.

# get array of input files; tacked sort on to the end of this because find displays newer files first which can break numbering if files in the middle of a sequence have an older time stamp than the start; also apparently `find` has no built-in options for sorting so this would be the correct way to sort, re: https://serverfault.com/questions/181787/find-command-default-sorting-order
array=( $(find . -maxdepth 1 -type f -name "*.$inFileType" -printf '%f\n' | sort -n) )
# if files are numbered, first file in array is also the first frame number:
first_frame_from_filename=${array[0]%.*}
lastFoundFileType=${array[-1]}
digitsPadCount=${#first_frame_from_filename}

# example commands to fetch and parse src pix dimensions is in getDoesIMGinstagram.sh.
# also could do bc math e.g: echo "scale=5; 3298 / 1296" | bc
# constructing an additionalParams arg via piping and read?! :
# echo "-filter:v \"crop=1920:1080\"" > tmp_blaheryeag_nbD9X44rCJev.txt && additionalParams=$(<tmp_blaheryeag_nbD9X44rCJev.txt) && rm tmp_blaheryeag_nbD9X44rCJev.txt

# OPTIONAL additionalParams; uncomment / tweak any; NOTE that some necessarily escape double-quote marks with \:	a previously used color: #362e2c
# additionalParams="-vf scale=990:-1:force_original_aspect_ratio=1,pad=1080:1080:\(ow-iw\)/2:\(oh-ih\)/2:color=#130a14"
# additionalParams="-filter:v crop=1920:1080"
# rotate video 90 degrees, re https://stackoverflow.com/a/9570992 ;
# additionalParams='-vf "transpose=1"'				Transpose parameter options: 0 = 90CounterCLockwise and Vertical Flip (default); 1 = 90Clockwise; 2 = 90CounterClockwise; 3 = 90Clockwise and Vertical Flip
# available presets, from fastest with large file size to slowest with small file size: ultrafast, superfast,, veryfast, faster, fast, medium (this is the default), slow, slower, veryslow
additionalParams="-preset veryslow"

# yuv420p is apparently required by instagram and probably facebook and others:
pixelFormat="-pix_fmt yuv420p"

# Because something funky and evil in DOS and/or Unix emulation chokes on some forms of $additionalParams inline, but not if printed to and executed from a script;
# FOR LOSSLESS BUT COMPRESSED AVI, end the command instead with: -codec:v utvideo _out.avi :
echo "ffmpeg -y -f image2 -framerate $inFPS -start_number $first_frame_from_filename -i %0"$digitsPadCount"d.$inFileType $additionalParams $rescaleParams -r $outFPS $pixelFormat -crf $crf _out.$outExt" > tmp_enc_script_P4b3ApXC.sh
./tmp_enc_script_P4b3ApXC.sh
rm ./tmp_enc_script_P4b3ApXC.sh

# If $6 is passed to the script (which is assigned to finalLoopSeconds in the PARAMETER CHECKING section), create a looped still video ($finalLoopSeconds seconds long) from the last frame and append it to the video.
# If $6 is not passed to the script, a variable named finalLoopSeconds is never declared, so this same type of check for variable existence works here: true if the variable name exists, false if it doesn't":
if [ "$finalLoopSeconds" ]
then
	ffmpeg -y -loop 1 -i $lastFoundFileType -vf fps=$outFPS $additionalParams $rescaleParams -t $finalLoopSeconds -crf $crf $pixelFormat _append.$outExt
	printf "" > tmp_ft2N854f.txt
	echo _out.$outExt >> tmp_ft2N854f.txt
	echo _append.$outExt >> tmp_ft2N854f.txt
	sed -i "s/^\(.*\)/file '\1'/g" tmp_ft2N854f.txt
	ffmpeg -y -f concat -i tmp_ft2N854f.txt -c copy _tmp_TXF6PmWe.$outExt
	rm ./tmp_ft2N854f.txt
	rm ./_out.$outExt ./_append.$outExt
	mv ./_tmp_TXF6PmWe.$outExt ./_out.$outExt
fi
