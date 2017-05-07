# Invoke this with one paramater, being the extension of videos you wish to encode to Sony Vegas compatible video.
# Vcompat = compatible with Sony (V)egas video editing software. 2016-04-26 9:46 PM -RAH

# lossless encode, adapted from: http://www.konstantindmitriev.ru/blog/2014/03/02/how-to-encode-vegas-compatible-h-264-file-using-ffmpeg/
# Re encoding quality: -q 0 is lossless, -q 23 is default, and -q 51 is worst.
# Re: https://trac.ffmpeg.org/wiki/Encode/H.264

find ./*.$1 > all$1
mapfile -t allvids < all$1
rm all$1

for filename in ${allvids[@]}
do
	ffmpeg -y -i "$filename" -c:v libx264 -crf 6 -c:a aac -strict experimental -tune fastdecode -pix_fmt yuv420p -b:a 192k -ar 48000 "$filename".mp4
				# ffmpeg -y -i "$filename" -map 0:v -vcodec copy "filename"_temp.mp4
done

# NO AUDIO:
# ffmpeg -y -i __corrupted_1pct_2016_10_22__03_23_54__639469500__out.mp4_utvideo.avi -map 0:v -c:v libx264 -crf 12 -pix_fmt yuv420p __corrupted_1pct_2016_10_22__03_23_54__639469500__out.mp4_utvideo.mp4