# Adapted from the following, re: http://superuser.com/a/778967/130772
# Original example code:
# ffmpeg -i 1.mp4 -i 2.mp4 -f lavfi -i color=black -filter_complex \
# "[0:v]format=pix_fmts=yuva420p,fade=t=out:st=4:d=1:alpha=1,setpts=PTS-STARTPTS[va0];\
# [1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=1:alpha=1,setpts=PTS-STARTPTS+4/TB[va1];\
# [2:v]scale=960x720,trim=duration=9[over];\
# [over][va0]overlay[over1];\
# [over1][va1]overlay=format=yuv420[outv]" \
# -vcodec libx264 -map [outv] out.mp4

# TO DO: adapt this to automatically detect the duration of clips and crossfade the whole length of them (for my purposes).

ffmpeg -y -f image2 -i 001.png d=3.4 001.avi
ffmpeg -y -f image2 -i 002.png d=3.4 002.avi
exit
ffmpeg -y -i $hexColorOne.avi -i $hexColorTwo.avi -f lavfi -i color=black -filter_complex \
"[0:v]fade=t=out:st=0:d=3.4:alpha=1,setpts=PTS-STARTPTS[va0];\
[1:v]fade=t=in:st=0:d=3.4:alpha=1,setpts=PTS-STARTPTS[va1];\
[2:v]trim=duration=3.4[over];\
[over][va0]overlay[over1];\
[over1][va1]overlay=format=yuv420[outv]" \
-vcodec libx264 -crf 40 -map [outv] "$hexColorOne"_xFade_"$hexColorTwo".mp4

# cygstart ./"$hexColorOne"_xFade_"$hexColorTwo".mp4