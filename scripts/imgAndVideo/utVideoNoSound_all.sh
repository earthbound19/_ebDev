# Invoke this with one paramater, being the extension of videos you wish to convert to lossless utvideo avis without sound.

cygwinFind ./*.$1 > all$1
mapfile -t allvids < all$1
rm all$1

for filename in ${allvids[@]}
do
	ffmpeg -y -i "$filename" -map 0:v -vcodec utvideo "$filename"_utvideo.avi
done