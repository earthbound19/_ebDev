# DESCRIPTION
# Takes two input images and creates a video crossfading between them, via ffmpeg, with fade duration and padding options via parameters to this script.

# DEPENDENCIES
# ffmpeg, a nixy' environment

# USAGE
# run this script with three parameters:
# - $1 File name of input image one
# - $2 File name of input image two
# - $3 Duration of crossfade between them
# - $4 OPTIONAL. Padding, in seconds (time for images to be shown without crossfade), at start and end of video. If not specified, defaults to 4.36.
# Example that creates a video of a 7-second crossfade from one image to another, with 4.36 seconds padding before and after:
#    ffmpegCrossfadeIMGsToVideo.sh inputImageOne.png inputImageTwo.png 7 4.36
# NOTES
# If this script is called this way from another script via the source command, like this (assuming this script is in your PATH) :
#    source ffmpegCrossfadeIMGsToVideo.sh <parameters>
# -- then the variable which this script sets, named $targetRenderFile will persist in the shell after this script terminates, for a calling script to make use of. The script `ffmpegCrossfadeIMGsToVideoFromFileList.sh` does this.

# CODE
	# TO DO:
	# - Do not use `exit`. Instead, elegantly skip main logic if no parameters passed, because `exit` will terminate this script *and* a calling script if the calling script runs this via `source ffmpegCrossfadeIMGsToVideo.sh`.
	# - Test with many image pairs, and if necessary fix complex filter timings math (in ffmpeg command). It seems that the crossfade starts and ends later than it should.
	# - Add fps param?
	# - Option to adapt this to automatically detect the duration of two pre-existing input clips and crossfade almost the whole length of the shorter over the longer?
# GLOBAL HARD-CODED OPTIONS--tweak these per your want:
vidExt=avi
# vidExt=mp4
# codecParam=""
# codecParam="-q 13"
codecParam="-vcodec rawvideo"
# codecParam="-codec:v utvideo -r 30"
# codecParam="-codec:v qtrle -r 30"
	# looks horrible at video start for animations! :
# codecParam="-codec:v libvpx-vp9 -lossless 1 -r 30"

# ====
# SET GLOBALS START
if [ -z "$1" ]; then echo No parameter \$1 \(start input image\)\. Will exit.; exit; else imgOne=$1; echo SET imgOne to $1; fi
if [ -z "$2" ]; then echo No parameter \$2 \(end input image\)\. Will exit.; exit; else imgTwo=$2; echo SET imgOne to $2; fi

# Initializing from $4 before initializing $3 (if $4 passed; otherwise set default), because 3 needs 4.
if [ -z "$4" ]
then
	echo No parameter \$4 \(still image padding before and after crossfade\). Will default to 4.36.
	clipPaddingSeconds=4.36
else
	clipPaddingSeconds=$4
	echo SET clipPaddingSeconds to $4
fi

if [ -z "$3" ]
then
	echo No parameter \$3 \(crossfade length\). Will default to 7.; xFadeLen=7
else
	xFadeLen=$3
	echo SET xFadeLen to $3.
	srcClipLengths=$(echo "scale=2; $xFadeLen + $clipPaddingSeconds" | bc)
fi

fadeSRConeFileName="${imgOne%.*}"
fadeSRCtwoFileName="${imgTwo%.*}"
# SET GLOBALS END
# ====

# ONLY DO THE INTENDED WORK if the target file does not already exist; if it does exist warn the user and skip:
targetRenderFile="$fadeSRConeFileName"_xFade_"$fadeSRCtwoFileName"_"$xFadeLen"s_"$clipPaddingSeconds"p_."$vidExt"
if [ -e $targetRenderFile ]
then
	echo target file $targetRenderFile already exists\; will not render. To recreate it\, delete the file and run this script again.
else
	echo target file $targetRenderFile does not exist\; will render.
	# CREATE input static image (looped) video files from the two input images.
	# To avoid repeating work, render still image video (source for later crossfade) only if it does not already exist:
	if [ ! -e "$fadeSRConeFileName"."$vidExt" ]
	then
				echo target render image for still image video fade source "$fadeSRConeFileName"."$vidExt" doesn\'t exist\; RENDERING\; render command is\:
				echo ffmpeg -loop 1 -i $imgOne -t $srcClipLengths $codecParam "$fadeSRConeFileName"."$vidExt"
		ffmpeg -loop 1 -i $imgOne -t $srcClipLengths $codecParam "$fadeSRConeFileName"."$vidExt"
	fi
	# This also avoids repeat work:
	if [ ! -e "$fadeSRCtwoFileName"."$vidExt" ]
	then
				echo target render image for still image video fade source "$fadeSRCtwoFileName"."$vidExt" doesn\'t exist\; RENDERING\; render command is\:
				echo ffmpeg -loop 1 -i $imgTwo -t $srcClipLengths $codecParam "$fadeSRCtwoFileName"."$vidExt"
		ffmpeg -loop 1 -i $imgTwo -t $srcClipLengths $codecParam "$fadeSRCtwoFileName"."$vidExt"
	fi
	# CREATE the video crossfade from those two static image (looped) video files we just made.
	# The following complex filter taken and adapted from https://superuser.com/a/1001040/130772
					# DEPRECATED:
					# previous (much more muddy) reference: http://superuser.com/a/778967/130772
			# NOTES
			# - "First we cut the two streams via the trim filter. The first clip is cut into two parts: a content and a fade out section. The second clip is also cut into two parts: a fade in and a content section. Four sections total."
			# - You will probably always want the following to be true:
			# - The second specified at end= for clip1cut matches the start= for clip1fadeOut.
			# - The second specified at end= for clip2fadeIn matches the start= for clip2cut.
			# - In practice you can probably usually eliminate the end= from both clip1fadeOut and clip2cut.
			# - In the filter subcomplex section, st (e.g. st=0) means start, d (e.g. d=4) means duration.
			# - You will probably always want to set d= to the duration of the first clip MINUS clip1cut's end=<n>. So if the duration of source 1 is 5 seconds, and clip1cut's end=1, that's 5-1=4, so d=4.
	clip1CutAt=$(echo "scale=2; $srcClipLengths - $xFadeLen" | bc)
			echo RENDERING target crossfade file $targetRenderFile . . .
	ffmpeg -i "$fadeSRConeFileName"."$vidExt" -i "$fadeSRCtwoFileName"."$vidExt" -an \
	-filter_complex "\
		[0:v]trim=start=0:end=$clip1CutAt,setpts=PTS-STARTPTS[clip1cut]; \
		[0:v]trim=start=$clip1CutAt,setpts=PTS-STARTPTS[clip1fadeOut]; \
		[1:v]trim=start=0:end=$xFadeLen,setpts=PTS-STARTPTS[clip2fadeIn]; \
		[1:v]trim=start=$xFadeLen,setpts=PTS-STARTPTS[clip2cut]; \
		[clip2fadeIn]format=pix_fmts=yuva420p, \
					fade=t=in:st=0:d=$xFadeLen:alpha=1[fadein]; \
		[clip1fadeOut]format=pix_fmts=yuva420p, \
					fade=t=out:st=0:d=$xFadeLen:alpha=1[fadeout]; \
		[fadein]fifo[fadeinfifo]; \
		[fadeout]fifo[fadeoutfifo]; \
		[fadeoutfifo][fadeinfifo]overlay[crossfade]; \
		[clip1cut][crossfade][clip2cut]concat=n=3[output] \
		" \
	-map "[output]" $codecParam $targetRenderFile

	# Cygwin option: auto-launch the completed cross-faded video:
	# cygstart $targetRenderFile
fi
