if [ ! -a "./$1""_frames" ]
then
	mkdir "./$1""_frames"
fi

ffmpeg.exe -i $1 -f image2 "./$1""_frames/fr_%10d.png"