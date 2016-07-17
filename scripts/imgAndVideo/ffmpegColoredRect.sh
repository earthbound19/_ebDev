# re: http://stackoverflow.com/a/22719247/1397555
# also thar: "just to add that you can get a solid from from hex code like: color=c=0xff0000"
# NOTE: the :d=<a number> part of the parameter is the duration of the output video. This is not necessary for a still image output file. Note also that the -frames:v <number> parameter should be omitted for video output.
	# ffmpeg -f lavfi -i color=c=red:s=320x240 -frames:v 1 red.png
	# ffmpeg -f lavfi -i color=c=blue:s=320x240 -frames:v 1 blue.png
# ALSO NOTE: You can get a solid from from hex code like: color=c=0xff0000
hexColor=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6`
echo ffmpeg -f lavfi -i color=$hexColor:s=320x240:d=7 src1.avi
hexColor=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6`
echo ffmpeg -f lavfi -i color=$hexColor:s=320x240:d=7 src2.avi