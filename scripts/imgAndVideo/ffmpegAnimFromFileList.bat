REM IN DEVELOPMENT.

REM ex. command:
REM ffmpeg -y -r 24 -f image2 -i doctoredFrames\mb-DGYTMSWA-fr_%07d.png -vf "format=yuv420p" -vcodec rawvideo -r 29.97 _DGYTMSWAsourceDoctoredUncompressed.avi

REM to enable simple interpolation to up the framerate to 30, use this tag in the codec/output flags section:
REM -vf fps=30

REM ex. command: ffmpeg -y -r 18 -f image2 -i %05d.png -crf 13 -vf fps=30 out.mp4