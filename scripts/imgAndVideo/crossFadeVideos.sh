# DESCRIPTION
# Crossfades videos with custom fade parameters. See USAGE.

# USAGE
# Invoke with these parameters:
# - $1 file name of the first video
# - $2 file name of the second video
# - $3 the duration of the crossfade to make between them them
# - $4 time in the video that the crossfade will begin (in seconds, allowing for decimals) for both videos (in and out).
# NOTE; Both videos are assumed to be the same length in my dev tests. I haven't found out what happens if they aren't:


# CODE
# TO DO:
# Make $3 and $4 optional and default them to 3 and 1, respectively.
inputVideoOne=$1
inputVideoTwo=$2
crossFadeLength=$3			# Set this to half the length of both videos
crossFadeStart=$4

# MAKE AUDIO crossfade.
ffmpeg -y -i $inputVideoOne -r 11500 -i $inputVideoTwo -filter_complex \
"[0:a]afade=t=out:st=$crossFadeStart:d=$crossFadeLength[a0];\
[1:a]afade=t=in:st=$crossFadeStart:d=$crossFadeLength[a1];\
[a0][a1]amix[over]" \
-map [over] _aud.aac

# MAKE VIDEO crossfade.
# Adapted from: http://superuser.com/a/778967/130772
ffmpeg -y -i $inputVideoOne -i $inputVideoTwo -filter_complex \
"[0:v]fade=t=out:st=0:d=$crossFadeLength:alpha=1,setpts=PTS-STARTPTS[va0];\
[1:v]fade=t=in:st=0:d=$crossFadeLength:alpha=1,setpts=PTS-STARTPTS[va1];\
[va0][va1]overlay[over]" \
-map [over] _vid.mp4

# Mux the two; sound is shorter at this writing :(  :
ffmpeg -y -i _aud.aac -i _vid.mp4 -crf 17 "$inputVideoOne"_xFade_"$inputVideoTwo".mp4
rm _aud.aac _vid.mp4

# Cygwin option: auto-launch the completed cross-faded video:
# cygstart ./_crossfadeOut.mp4