# TO DO:
# - parameterize.
# - adapt 0.08 via math, re this comment at the post:
https://stackoverflow.com/a/56302143/1397555
# "The -t is added for the image so that we have a stream with 2 frames.
# (25 fps x 0.08 = 2). The setpts sets the timestamp for the 2nd frame
# to the inverse of the scroll rate, which represents a fraction of the
# height. The fps filter fiils in the timestamp gaps with cloned frames."

ffmpeg -f lavfi -i color=s=1920x1080 -loop 1 -t 0.08 -i "input.png" -filter_complex "[1:v]scale=1920:-2,setpts=if(eq(N\,0)\,0\,1+1/0.02/TB),fps=25[fg]; [0:v][fg]overlay=y=-'t*h*0.02':eof_action=endall[v]" -map "[v]" output.mp4


# 3672 seconds
# gm convert *.png -append ___supahighout.png