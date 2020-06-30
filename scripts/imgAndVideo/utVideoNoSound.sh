# DESCRIPTION
# Takes an input video, strips the sound, and converts the video stream to an AVI using the lossless utvideo codec.

# USAGE
#  ./utVideoNoSound.sh inputVideo.avi
# OR
#  ./utVideoNoSound.sh inputVideo.mp4
# etc.


# CODE
# Prior DOS batch command: ffmpeg -y -i "%1%" -pix_fmt yuv420p -codec:v utvideo "%1%_utvideo.avi"

		# DEPRECATED variant? -pix_fmt parameter caused errors with source videos which had no such attribute, I think:
		# ffmpeg -y -i "$1" -pix_fmt yuv420p -map 0:v -codec:v utvideo "$1""_utvideo.avi"
ffmpeg -y -i "$1" -map 0:v -codec:v utvideo "$1""_utvideo.avi"