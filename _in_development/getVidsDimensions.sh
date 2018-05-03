# TO DO: make this list all video extensions that I use.
find *.swf *.mp4 *.gif *.mov *.avi > vids.txt
mapfile -t vids < vids.txt
rm vids.txt
for element in "${vids[@]}"
do
	ffprobe $element > ffprobe_result.txt
done