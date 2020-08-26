# DESCRIPTION
# Creates N ($1) randomly shaped "blob" images.

# USAGE
# From a directory you wish to fill with so many random blob images, run with one parameter, which is the number of blobs to make, e.g.:
#    getRandomBlobs.sh 100
# NOTES
# - A known issue is that random images will be blank -- maybe if Cygwin's /urandom entropy is empty, if that's possible? AND: This relies on one of Fred's ImageMagick scripts, which are not freely redistributable; you'll have to download it from the source yourself at: http://www.fmwconcepts.com/ImageMagick/randomblob/index.php -- and for the newest ImageMagick, you may need to search/replace all instances of convert with magick in that script. AND make sure ImageMagick is in your PATH. AND: you will need the bc calculator language installed in Cygwin.
# - These blobs could be animated by cycling the spline tension from 0 (-T 0) to 1 (-T 1), then back to zero! e.g. It can also do tension greater than 1; I assume 2 would be 200% tension, etc. Maximum recommended tension from experiments: 1.17. ~Min.: -4.2 or even -5?
# - Even higher or even lower spline tension ranges produce altogether different random/abstract results.
# - Using the -d straight parameter will give you a general (default?) idea of the kind of shape drawn by various recommended spline draw-type tensions, and -d straight is *a lot* faster.


# CODE
# TO DO: Make note somewhere that the preceding line may be a preferred method of generating random numbers in an extremely large range. NOTE: I don't know how randomblob.sh handles the -S parameter, but it seems there's no upper bound to the number you can throw at it. I've tried ~4* 18 quintillion, the approximate max range of a 16 byte unsigned int, and it still worked and produced original output.
	# DEPRECATED; doesn't work in Cygwin bash. ? :
	# for i in {1..$1}
for i in $(seq $1)
do
	# Get an 8-byte random number; re http://www.cyberciti.biz/faq/bash-shell-script-generating-random-numbers/ ; output should be in the range 0- ~18.4 quintillion re: https://en.wikipedia.org/wiki/Integer_%28computer_science%29#Words
	seed=`od -vAn -N8 -tu8 < /dev/urandom`
	seed=`echo $seed | sed 's/ //g' | tr -d '\15\32'`		# Trims unwanted space from front of number.
	numRandomPoints=$[ 3 + $[ RANDOM % 11 ]]	# Random number between 3 and 11.
	lineWidth=$[ 3 + $[ RANDOM % 7 ]]	# Random number between 3 and 11.
	interpolationPoints=1
	outfile="randomBlob S$seed n$numRandomPoints p$interpolationPoints l$lineWidth.png"
	outfile=`echo "$outfile" | sed 's/ /_/g' | tr -d '\15\32'`	# Replaces spaced with underscores, where the variables won't assign to a string properly in the first place with underscores.
	command="randomblob.sh -S $seed -n $numRandomPoints -p $interpolationPoints -l $lineWidth -d straight $outfile"
	echo command is $command
	$command
done
