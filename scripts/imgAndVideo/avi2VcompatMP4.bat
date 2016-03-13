REM What? What is Vcompat? Compatible with what? iPhones? iThings? What?? 01/09/2016 04:44:57 PM -RAH
REM lossless encode, adapted from: http://www.konstantindmitriev.ru/blog/2014/03/02/how-to-encode-vegas-compatible-h-264-file-using-ffmpeg/
REM Re encoding quality: -q 0 is lossless, -q 23 is default, and -q 51 is worst.
REM Re: https://trac.ffmpeg.org/wiki/Encode/H.264

ffmpeg -y -i %1 -c:v libx264 -c:a aac -strict experimental -tune fastdecode -pix_fmt yuv420p -b:a 192k -ar 48000 %1lossles.mp4