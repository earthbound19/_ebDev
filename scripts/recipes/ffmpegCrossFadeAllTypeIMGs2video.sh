# DESCRIPTION
# Creates a looped video in which all images of type $1 in the current directory are crossfaded one after another, and then the final image crossfades back to the first. Accomplishd by custom logic in this script and runs of `ffmpegCrossFadeVideos.sh` and `concatVideos.sh`. Result video renamed after this directory.

# WARNING
# Intermediate videos are lossless though compressed (utvideo codec) avis, and they are much larger compared to mp4s. This script does not delete those files, as you may wish to keep any of them for archiving or resource combination purposes. If you don't want those large files, you may want to delete them afterward.

# USAGE
# Run with these parameters:
# - $1 The image type to crossfade.
# - $2 OPTIONAL. The duration of each video still to be crossfaded in decimal seconds. If not provided, a default will be used. Should be greater than $3:
# - $3 OPTIONAL. Crossfade duration between each still image video, in decimal seconds. If not provided, a default will be used.
# Example that will make a crossfade video from all pngs, with default durations:
#    ffmpegCrossFadeAllTypeIMGs2video.sh png
# Example that will make each still image video 4.7 seconds, and crossfade for 2.6 seconds between them:
#    ffmpegCrossFadeAllTypeIMGs2video.sh png 4.7 2.6
# Result file is named after the current directory and source image type, after the pattern `__<directoryName>_<$1>_crossfades.mp4`.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (image type to crossfade) passed to script. Exit."; exit 1; else srcFileType=$1; fi
if [ "$2" ]; then stillDuration=$2; else stillDuration=5.75; fi
if [ "$3" ]; then xFadeDuration=$3; else xFadeDuration=4.25; fi
# - If values for stillDuration and xFadeDuration exist (if $2 and $3 were passed), but they don't make sense, print error and exit with error code.
if [ "$stillDuration" ] && [ "$xFadeDuration" ]
then
	# Because we allow decimal parameters, check them with bc (as bash uses integers for native comparison) :
	isXfadeGTstill=$(echo "$xFadeDuration > $stillDuration" | bc)
	if [ "$isXfadeGTstill" == "1" ]; then echo "PROBLEM: crossfade would be longer than still. That makie no sense. Try something else, Voldemort. Exit."; exit 1; fi
fi

# Make array (list) of image files of type $srcFileType:
filesList=($(find . -maxdepth 1 -type f -iname \*.$srcFileType -printf '%f\n'))
# - Add first element of array to last (loopback pair of last image to first):
filesList+=("${filesList[0]}")

# BEFORE MODIFICATION:
# FIRST:
# color_growth_logo_opt_RAHfavoriteColorsHex__2_combo_012_A.png
# LAST:
# color_growth_logo_opt_RAHfavoriteColorsHex__2_combo_338_B.png

# - For looping, get index of last element, as we will want to break loop when we reach that (else we would try to build a last pair that is the last element and then nothing) :
#  - get index of last element:
filesListLength=${#filesList[@]}
lastIDXtoIterateOn=$((filesListLength - 2))

pair_count=0
for IDX in $(seq 0 $lastIDXtoIterateOn)
do
	pair_count=$((pair_count + 1))
	pair_count_filename_str=$(printf "%06d\n" $pair_count)
	IDX_plus_one=$((IDX + 1))
		# echo ""
		# echo file name for A in pair is ${filesList[$IDX]}
		# echo file name for B in pair is ${filesList[$IDX_plus_one]}
	# construct still video render target file names:
	fileA_baseName=${filesList[$IDX]%.*}
	fileB_baseName=${filesList[$IDX_plus_one]%.*}
	videoStilltempFileA="$fileA_baseName"_still_tmp_KN63j9znQ.avi
	videoStilltempFileB="$fileB_baseName"_still_tmp_KN63j9znQ.avi
	# ARGHUEFIHUFMGURGH...
	videoStilltempFileA_baseName=${videoStilltempFileA%.*}
	videoStilltempFileB_baseName=${videoStilltempFileB%.*}
	crossFadeVideoTargetFileName="$videoStilltempFileA_baseName"_xFade_"$videoStilltempFileB_baseName".mp4
	# - render video still for A in pair, only if the render target file does not already exist
	#  - construct target file that would result from ffmpegCrossFadeVideos.sh script call, and skip render attempt if it already exists:
	thisScriptsRenderTargetFileName="xFade_pair_""$pair_count_filename_str""_""$fileA_baseName"_xFade_"$fileB_baseName".mp4
	# only render still if it doesn't already exist (as video stills can be reused for subsequent crossfades) :
	if [ ! -e $videoStilltempFileA ]
	then
		ffmpeg -y -loop 1 -i ${filesList[$IDX]} -t $stillDuration -codec:v utvideo $videoStilltempFileA
	fi
# ~ for B in pair:
	if [ ! -e $videoStilltempFileB ]
	then
		ffmpeg -y -loop 1 -i ${filesList[$IDX_plus_one]} -t $stillDuration -codec:v utvideo $videoStilltempFileB
	fi
			# OPTED NOT TO DO: This will work, but it is extraordinarily much slower than making two still image videos and using the crossfade filter; also, I would need to construct shims between it if I want the stills to not be in crossfade at any point (it is all crossfade) ; re: https://stackoverflow.com/questions/21493797/how-to-fade-two-images-with-ffmpeg/21503774#21503774
			# ffmpeg -y -loop 1 -i ${filesList[$IDX]} -loop 1 -i ${filesList[$IDX_plus_one]} -filter_complex "[1:v][0:v]blend=all_expr='A*(if(gte(T,3),1,T/3))+B*(1-(if(gte(T,3),1,T/3)))'" -t $crossfadeDuration out.mp4
	# Make crossfade video from the still video, via ffmpegCrossFadeVideos.sh, only if it doesn't already exist:
	if [ ! -e $crossFadeVideoTargetFileName ] | [ ! -e $thisScriptsRenderTargetFileName ]
	then
		# Do calculation to have crossfade start at a time such that crossfade will be time-centered (equal time for non-crossfade portion of still image at start and end of video) :
		xFadeBeginAtTime=$(echo "scale=2; ($stillDuration - $xFadeDuration) / 2" | bc)
		echo ""
		ffmpegCrossFadeVideos.sh $videoStilltempFileA $videoStilltempFileB $xFadeDuration $xFadeBeginAtTime
		# construct file name to match ffmpegCrossFadeVideos.sh script result; reprise of ARGHUEFIHUFMGURGH . . .
		crossFadeVideoTargetFileName="$videoStilltempFileA_baseName"_xFade_"$videoStilltempFileB_baseName".mp4
		# rename that to what we want for concatenation:
		mv $crossFadeVideoTargetFileName $thisScriptsRenderTargetFileName
	fi
done

# ONLY IF final render target file name does not exist, move temp still video files out of the way while we concatenate the crossfade vids:
# get parent directory name (without path) to name this file after:
currentDirNoPath=$(basename $(pwd))
finalRenderTargetFileName=__"$currentDirNoPath"_"$srcFileType"_crossfades.mp4
if [ ! -e $finalRenderTargetFileName ]
then
	# concat the videos we want to:
	concatVideos.sh mp4
	# -- and rename it to that plus __ at the start:
	mv _mp4sConcatenated.mp4 $finalRenderTargetFileName
	printf "\n~\nDONE rendering crossfade videos via crossFadeIMGs.sh. Final file is $finalRenderTargetFileName. You may want to delete all video files with _still_tmp_KN63j9znQ.mp4 in their file name (a lot of still image videos). You may also want to delete intermediate files that start with xFade_pair_<nnnnnn> in their file name.\n\n"
else
	echo "Target file $finalRenderTargetFileName already exists. Did you already run this render? If not, delete that file and run this script with the same parameters again."
fi
