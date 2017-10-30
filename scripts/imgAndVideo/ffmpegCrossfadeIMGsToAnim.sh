# DESCRIPTION
# Takes two input images and creates a video crossfading between them, via ffmpeg

# DEPENDENCY
# ffmpeg

# USAGE
# invoke this script with three parameters:
# $1 input image one
# $2 input image two
# $3 duration of crossfade between them
# e.g. the following creates a video of a 5-second crossfade from one image to another:
# ./thisScript.sh inputImageOne.png inputImageTwo.png 5

# TO DO:
# add fps param
# Option to adapt this to automatically detect the duration of two pre-existing input clips and crossfade the whole length of the shorter over the longer?


# CODE
if [ -z ${1+x} ]; then echo No paramater one \(start input image\)\. Will exit.; exit; else imgOne=$1; echo SET imgOne to $1; fi
if [ -z ${2+x} ]; then echo No paramater two \(end input image\)\. Will exit.; exit; else imgTwo=$2; echo SET imgOne to $2; fi
if [ -z ${3+x} ]; then echo No paramater three \(generated crossfade duration\). Will exit.; exit; else crossFadeLength=$3; echo SET crossFadeLength to $3; fi

fadeSRConeFileName="${imgOne%.*}"
fadeSRCtwoFileName="${imgTwo%.*}"

# OPTION: static images input, looped to a duration (to create crossfade sources) :
ffmpeg -y -loop 1 -i $imgOne -t $crossFadeLength -codec:v utvideo "$fadeSRConeFileName".avi
ffmpeg -y -loop 1 -i $imgTwo -t $crossFadeLength -codec:v utvideo "$fadeSRCtwoFileName".avi

# ONLY EXECUTE the following if the target file does not already exist; if it does exist warn the user and skip:
if [ -e "$fadeSRConeFileName"_xFade"$3"s_"$fadeSRCtwoFileName".avi ]
then
	echo target file "$fadeSRConeFileName"_xFade"$3"s_"$fadeSRCtwoFileName".avi already exists\; will not render. To recreate it\, delete the file and run this script again.
else
	echo target file does not exist\; will render.
	# Adapted from: http://superuser.com/a/778967/130772
	ffmpeg -y -i "$fadeSRConeFileName".avi -i "$fadeSRCtwoFileName".avi -f lavfi -i color=black -filter_complex \
	"[0:v]fade=t=out:st=0:d=$crossFadeLength:alpha=1,setpts=PTS-STARTPTS[va0];\
	[1:v]fade=t=in:st=0:d=$crossFadeLength:alpha=1,setpts=PTS-STARTPTS[va1];\
	[va0][va1]overlay[over]" \
	-vcodec utvideo -map [over] "$fadeSRConeFileName"_xFade"$3"s_"$fadeSRCtwoFileName".avi

	# OPTIONAL: comment out either or both of the next two delete commands, depending on what you may want to keep:
	rm ./"$fadeSRConeFileName".avi
	rm ./"$fadeSRCtwoFileName".avi

	# Cygwin option: auto-launch the completed cross-faded video:
	# cygstart ./"$1"_xFade"$3"s_"$2".avi
fi