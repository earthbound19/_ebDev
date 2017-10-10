# DESCRIPTION
# Render a sequence of image crossfades from a list (e.g. by next most similar image), using ffmpegCrossfadeImagesToAnim.sh repeatedly. Several other scripts (commented out here near the start) must first be run against a series of images.

# PRECURSOR RUNS needed: they take a while (depending, or even a llooong time), so you'll want to keep the file IMGlistByMostSimilar.txt created by the second:
# renumberFiles.sh png
# imgsGetSimilar.sh png

# TO DO
# Paramaterize whether to run against %2 (even-denominated pairs) or ! %2 (odd-denominated pairs); the latter being between the former to dovetail the former crossfades into the latter. OR build in logic that does a second odd-number run. UNTIL THEN, see the comments "EVEN RUN" and "ODD RUN."
# Parameterize source image extension.
# Parameterize crossfade duration.

crossFadeDuration=5.8

# CODE
# I strongly suspect this script could be done more swiftly and elegantly with Python. But here it is; I coded it, it works, and I am not re-doing it.
# Runs needed to render this sequence:
# mkNumberedCopiesFromFileList.sh
# cd numberedCopies

# Use ffmpegCrossfadeImagesToAnim.sh repeatedly on pairs of images by number until there are no more:
gfind *.png > numberedCopies.txt

# create an array from that list; I won't do this with mapfile because it's not found on platforms I use (though could it be?) :
count=1
pairArrayCount=0
while read element
do
	if (( $count % 2 ))		# ODD RUN (you wouldn't think) : uncomment this and comment out the next line for the first run.
	# if ! (( $count % 2 ))	# EVEN RUN (you wouldn't think) : uncomment this and comment out the previous line for the second run.
	then
		# Re a genius breath yon: https://stackoverflow.com/a/6022431/1397555
		# And because I can't . . . interpolate? the $count variable in-line in a sed command:
		sedCommand="$count""q;d"
		# Slowish, but faster than other options if I am to believe said genius breath yon; stores current (even) list item in a variable; ALSO the tr -d command eliminates a maddening problem of gsed returning windows-style line endings, which much up echo and varaible concatenation commands so that elements after one varaible with a bad line ending disappear; RE: https://stackoverflow.com/a/16768848/1397555
		secondOfPair=`gsed "$sedCommand" numberedCopies.txt | tr -d '\15\32'`
				# echo secondOfPair is $secondOfPair
		countMinusOne=$(($count - 1))
		sedCommand="$countMinusOne""q;d"
		firstOfPair=`gsed "$sedCommand" numberedCopies.txt | tr -d '\15\32'`
				# echo firstOfPair is $firstOfPair
				# echo "$firstOfPair,$secondOfPair"
		pairArray[$pairArrayCount]="$firstOfPair,$secondOfPair"
				echo new pairArray element $pairArrayCount is\:
				echo ${pairArray[$pairArrayCount]} . . .
		pairArrayCount=$((pairArrayCount + 1))
	fi
	count=$((count + 1))
done < numberedCopies.txt

for element in ${pairArray[@]}
do
	imgOne=`echo $element | gsed 's/\(.*\),.*/\1/g' | tr -d '\15\32'`
	imgTwo=`echo $element | gsed 's/.*,\(.*\)/\1/g' | tr -d '\15\32'`
	echo invoking ffmpegCrossfadeImagesToAnim.sh with image pair $element . . .
	ffmpegCrossfadeImagesToAnim.sh $imgOne $imgTwo $crossFadeDuration
done