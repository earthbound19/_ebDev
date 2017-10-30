# USAGE
# Pass this script three parameters, being:
# $1 the first video
# $2 the second video
# $3 the duration of the crossfade between them
# $4 what time (in seconds, allowing for decimals) the crossfade will start for both videos (in and out).
# TO DO:
# Make $3 and $4 optional and default them to 3 and 1, respectively.

crossFadeDuration=5.8

# CODE
# I strongly suspect this script could be done more swiftly and elegantly with Python. But here it is; I coded it, it works, and I am not re-doing it. (Unless I am.)
# Runs needed to render this sequence:
# mkNumberedCopiesFromFileList.sh
# cd numberedCopies

# Use ffmpegCrossfadeImagesToAnim.sh repeatedly on pairs of images by number until there are no more:
gfind *.mp4 > numberedCopies.txt

# TO DO: rewrite the loop to do everything in the first and second run in one run, if possible (also in ffmepgCrossfadeIMGsToAnimList.sh, which I am adapting this from):

# create an array from that list; I won't do this with mapfile because it's not found on platforms I use (though could it be?) :
count=1
pairArrayCount=0
while read element
do
	if (( $count % 2 ))	# ODD RUN: for the first run, uncomment this and comment out the next line.
	# if ! (( $count % 2 ))	# EVEN RUN: for the second run, uncomment this and comment out the previous line.
	then
		# Re a genius breath yon: https://stackoverflow.com/a/6022431/1397555
		# Gets Nth line from a file via sed (fragment of sed command), set in a variable because I haven't got bash to parse variables and a sed command the way I want in-line:
		sedCommand="$count""q;d"
		# Slowish, but faster than other options if I am to believe said genius breath yon; stores current (even) list item number in a variable; ALSO the tr -d command eliminates a maddening problem of gsed returning windows-style line endings, which much up echo and varaible concatenation commands so that elements after one varaible with a bad line ending disappear; RE: https://stackoverflow.com/a/16768848/1397555
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
rm ./numberedCopies.txt

for element in ${pairArray[@]}
do
	imgOne=`echo $element | gsed 's/\(.*\),.*/\1/g' | tr -d '\15\32'`
	imgTwo=`echo $element | gsed 's/.*,\(.*\)/\1/g' | tr -d '\15\32'`
	echo invoking ffmpegCrossfadeImagesToAnim.sh with image pair $element . . .
	ffmpegCrossfadeImagesToAnim.sh $imgOne $imgTwo $crossFadeDuration
done