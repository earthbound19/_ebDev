# Invoke this with one paramater, being the extension of videos you wish to strip of sound. WARNING: this wipes the sound off ALL videos of that format, permanently.

cygwinFind ./*.$1 > all$1
mapfile -t allvids < all$1
rm all$1

for filename in ${allvids[@]}
do
	ffmpeg -y -i "$filename" -map 0:v -vcodec copy "filename"_temp.mp4
	rm "$filename"
	mv "filename"_temp.mp4 "$filename"
done