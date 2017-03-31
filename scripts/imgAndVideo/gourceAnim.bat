gource --max-file-lag 40 -f -1280x720 --seconds-per-day .12 --auto-skip-seconds 0.1 --file-idle-time 0.12 --key --bloom-multiplier 0.7 --bloom-intensity 0.6 -e 0.06 --hide mouse,filenames -o _gitProjectGourceAnimFrames.ppm -r 30 --font-size 18

TIMEOUT /T 32

ffmpeg -i _gitProjectGourceAnimFrames.ppm -crf 17 itProjectGourceAnim.mp4




REM gource --max-file-lag 8 -f -1280x720 --seconds-per-day .28 --auto-skip-seconds 0.08 --file-idle-time 1.3 --key --bloom-multiplier 0.85 --bloom-intensity 0.7 -e 0.06 --hide mouse,usernames,filenames -o gitProjectFrame_ -r 30 --font-size 18