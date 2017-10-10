# DESCRIPTION
# Takes two input images and creates a video crossfading between them, viffmpeg

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
# Option to adapt this to automatically detect the duration of two pre-existing input clips and crossfade the whole length of the shorter over the longer?


# CODE
if [ -z ${1+x} ]; then echo No paramater one \(start input image\)\. Will exit.; exit; else imgOne=$1; echo SET imgOne to $1; fi
if [ -z ${2+x} ]; then echo No paramater two \(end input image\)\. Will exit.; exit; else imgTwo=$2; echo SET imgOne to $2; fi
if [ -z ${3+x} ]; then echo No paramater three \(generated crossfade duration\). Will exit.; exit; else crossFadeLength=$3; echo SET crossFadeLength to $3; fi

		# TANGENTIALLY RELATED: to generate randomly colored input video animations:
		# hexColorOne=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6`
		# ffmpeg -y -f lavfi -i color=$hexColorOne:s=1280x720:d=3.4 $hexColorOne.avi
		# hexColorTwo=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6`
		# ffmpeg -y -f lavfi -i color=$hexColorTwo:s=1280x720:d=3.4 $hexColorTwo.avi

# OPTION: static images input, looped to a duration (to create crossfade sources) :
ffmpeg -y -loop 1 -i $imgOne -t $crossFadeLength -codec:v utvideo tmpCrossfadeSRC_01_g82bs9Q2h.avi
ffmpeg -y -loop 1 -i $imgTwo -t $crossFadeLength -codec:v utvideo tmpCrossfadeSRC_02_g82bs9Q2h.avi

fadeSRConeFileName="${imgOne%.*}"
fadeSRCtwoFileName="${imgTwo%.*}"

# Adapted from: http://superuser.com/a/778967/130772
ffmpeg -y -i tmpCrossfadeSRC_01_g82bs9Q2h.avi -i tmpCrossfadeSRC_02_g82bs9Q2h.avi -f lavfi -i color=black -filter_complex \
"[0:v]fade=t=out:st=0:d=$crossFadeLength:alpha=1,setpts=PTS-STARTPTS[va0];\
[1:v]fade=t=in:st=0:d=$crossFadeLength:alpha=1,setpts=PTS-STARTPTS[va1];\
[va0][va1]overlay[over]" \
-vcodec utvideo -map [over] "$fadeSRConeFileName"_xFade"$3"s_"$fadeSRCtwoFileName".avi

rm ./tmpCrossfadeSRC_01_g82bs9Q2h.avi ./tmpCrossfadeSRC_02_g82bs9Q2h.avi

# Cygwin option: auto-launch the completed cross-faded video:
# cygstart ./"$1"_xFade"$3"s_"$2".avi