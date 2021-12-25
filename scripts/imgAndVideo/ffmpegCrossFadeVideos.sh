# DESCRIPTION
# ffmpeg wrapper that crossfades two videos with custom fade parameters. Result file name is `<input_video_one_base_file_name>_xFade_<input_video_two_base_file_name>.mp4`.

# USAGE
# Run with these parameters:
# - $1 File name of the first video
# - $2 File name of the second video
# - $3 OPTIONAL. The duration of the crossfade to make between them (in seconds, which may include decimals). If not provided, a default is used.
# - $4 OPTIONAL. Time in the video that the crossfade will begin (in seconds, which may include decimals). If not provided, a default is used.
# Example that will crossfade input1.mp4 to input2.mp4, with a crossfade of 2.3 seconds, which begins at 7.6 seconds into the video:
#    ffmpegCrossFadeVideos.sh input1.mp4 input2.mp4 2.3 7.6


# CODE
# PARAMETERS CHECK and globals set:
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source video one file name) passed to script. Exit."; exit 1; else inputVideoOne=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (source video two file name) passed to script. Exit."; exit 1; else inputVideoTwo=$2; fi
if [ "$3" ]; then crossFadeLength=$3; else crossFadeLength=4.25; fi
if [ "$4" ]; then crossFadeStart=$4; else crossFadeStart=0.75; fi

pixelFormat="-pix_fmt yuv420p"

# Construct render target file name variable:
inputVideoOneFileNameNoExt=${inputVideoOne%.*}
inputVideoTwoFileNameNoExt=${inputVideoTwo%.*}
renderTargetFileName="$inputVideoOneFileNameNoExt"_xFade_"$inputVideoTwoFileNameNoExt".mp4

# IF VIDEO HAS AUDIO, make audio crossfade. The following command will print nothing if there is no audio:
audioLog=$(ffprobe -i $inputVideoOne -show_streams -select_streams a -loglevel error)
if [ "$audioLog" != "" ]
then
	ffmpeg -y -i $inputVideoOne -r 11500 -i $inputVideoTwo -crf 13 -filter_complex \
	"[0:a]afade=t=out:st=$crossFadeStart:d=$crossFadeLength[a0];\
	[1:a]afade=t=in:st=$crossFadeStart:d=$crossFadeLength[a1];\
	[a0][a1]amix[over]" \
	-map [over] _crossFadeVideos_sh_tmp_PgfJnBGc9.aac
else
	echo "No audio; will not construct audio crossfade."
fi

# MAKE VIDEO crossfade.
# Adapted from: http://superuser.com/a/778967/130772
ffmpeg -y -i $inputVideoOne -i $inputVideoTwo -crf 13 -filter_complex \
"[0:v]fade=t=out:st=0:d=$crossFadeLength:alpha=1,setpts=PTS-STARTPTS[va0];\
[1:v]fade=t=in:st=0:d=$crossFadeLength:alpha=1,setpts=PTS-STARTPTS[va1];\
[va0][va1]overlay[over]" \
$pixelFormat \
-map [over] _crossFadeVideos_sh_tmp_PgfJnBGc9.mp4

# IF SOURCE VIDEO has audio, mux video and audio crossfade (and render to final render target file name); otherwise don't (and just rename the crossfade video to the final render target file name), because we made no audio crossfade. Alas, sound is shorter [I noted at one point; does that mean sound goes out of sync?] at this writing:
if [ "$audioLog" != "" ]
then
	echo ffmpeg -y -i _crossFadeVideos_sh_tmp_PgfJnBGc9.aac -i _crossFadeVideos_sh_tmp_PgfJnBGc9.mp4 -crf 17 $renderTargetFileName
	rm _crossFadeVideos_sh_tmp_PgfJnBGc9.aac _crossFadeVideos_sh_tmp_PgfJnBGc9.mp4
else
	mv _crossFadeVideos_sh_tmp_PgfJnBGc9.mp4 $renderTargetFileName
fi