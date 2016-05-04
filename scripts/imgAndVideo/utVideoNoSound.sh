# REM old DOS batch: ffmpeg -y -i "%1%" -pix_fmt yuv420p -codec:v utvideo "%1%_utvideo.avi"

ffmpeg -y -i "$1" -pix_fmt yuv420p -codec:v utvideo "$1_utvideo.avi"