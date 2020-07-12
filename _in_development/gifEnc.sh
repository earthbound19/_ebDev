# DESCRIPTION
# wut

# RE: http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
# USAGE:
#  gifenc.sh input.mkv output.gif

palette="./palette.png"

filters="fps=18,scale=-1:-1:flags=lanczos"

ffmpeg -v warning -i $1 -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i $1 -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y -r 10 $2