REM ffmpeg parameters to change a video size on encode:
REM -vf scale=iw/2:-1
rem WHERE 2: will make it half-size, 3 third-size, 4 fourth-size etc. Also, -crf 12 is higher quality than the worst possible, -crf 50 (I think it is), and -crf 0 would be lossless or best quality.
ffmpeg -y -i %1 -vf scale=iw/2:-1 -crf 12 %~n1_half.mp4

