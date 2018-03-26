REM ffmpeg parameters to change a video size on encode:
REM -vf scale=iw/2:-1
REM WHERE 2: will make it half-size, 3 third-size, 4 fourth-size etc.
ffmpeg -y -i %1 -vf scale=iw/2:-1 -crf 17 %~n1_half.mp4

