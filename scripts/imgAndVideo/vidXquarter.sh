# DESCRIPTION
# Re-encodes input video $1 at quarter resolution.

# USAGE
# Run with one parameter, which is the file name of the input video to make a quarter-resolution copy of:
#    vidXquarter.sh inputVideo.mp4
# Result file will be named <input_file_name>_quarter_resolution.mp4


# CODE
# ffmpeg parameters to change a video size on encode:
# -vf scale=iw/4:-1
# WHERE 2: will make it half-size, 3 third-size, 4 fourth-size etc.

ffmpeg -y -i $1 -vf scale=iw/4:-1 -crf 17 "$1"_quarter_resolution.mp4

