ffmpeg -i %1 -vcodec copy -acodec copy -f mpegts %1_tsContainer.ts
REM Alternate switch to -f mpegts: -bsf h264_mp4toannexb