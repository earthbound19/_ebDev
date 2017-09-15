# USAGE: $1 is the source file. $2 is a target dimension to resize to if any; e.g. nnnnXnnnn or e.g. 320:-1 or -1:800; the latter two calculate and keep an aspect ratio automatically targeting a given X or Y pix dimension. e.g. 320:-1 will target 320x pixels and whatever corresponding Y pixels would keep the aspect, or -1:800 would target 800y pixels and whatever corresponding X pixels will keep the aspect.

# Useful reference here: https://trac.ffmpeg.org/wiki/Scaling%20(resizing)%20with%20ffmpeg e.g. constants of iw and ih (image width and image height) can be used; to resize by 1/3 you could do: -vf scale=iw/3:ih/3

if [ ! -a "./$1""_frames" ]
then
	mkdir "./$1""_frames"
fi

ffmpeg.exe -i $1 -f image2 -vf scale=$2 "./$1""_frames/fr_%10d.png"