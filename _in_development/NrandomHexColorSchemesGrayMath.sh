# IN PROGRESS.
# Reworking another script for tweaked purposes. This script will make colors by starting with gray and making secondary, tertiary etc. colors by substracting form or adding to gray (going toward 0 or 255), after theories Itten exposed that pleasing color combinations sum to (or substract from?) gray.

# USAGE
# Invoke this script with 1 or optionally 2 parameters:
# $1 REQUIRED. The number of colors to have in the generated color scheme. OR to have the script randomly pick a number between 2 and N (first variable assignment hard-coded into script), make this paramater simply the letter r (for random).
# $2 OPTIONAL. How many such color schemes to generate. If not provided, one will be made.


# CODE
colorsPerScheme=7		# This may be overruled by a numeric parameter $1.
rndFileNameLen=14

if [ ! -z ${2+x} ];	then howManySchemesToCreate=$2;	else howManySchemesToCreate=1; fi

if [ ! $1 == 'r' ]
then
	colorsPerScheme=$1
	# else nothing; just go with the value of $colorsPerScheme as assigned above for the following allRndHexChars assignment.
fi

allRndHexChars=$(( $howManySchemesToCreate * $colorsPerScheme * 6 ))

allRndFileNameChars=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $howManyRNDchars`
rndCharsMultiCount=-$rndFileNameLen		# So that the following loop will grab the 0th (1st) item in the string on the first iteration, instead of skipping the first 6 chars--because I'd code increments at the start of a loop then the end.

for howMany in $( seq $howManySchemesToCreate )
do
			# respect directive to randomly choose how many colors to make per scheme if so directed:
			if [ $1 == 'r' ]
			then
				colorsPerScheme=`shuf -i 2-11 -n 1`
						echo Randomly chose to have $colorsPerScheme colors in the generated hex color scheme.
				else
				colorsPerScheme=$1
						echo Will generate $colorsPerScheme random hex colors for the generated color scheme.
			fi
	paddedNumColors=$(printf %05d $colorsPerScheme)
	outfile=./"$paddedNumColors"_"$rndFileNameChars"_HexColors.hexplt
	
	echo Generating $colorsPerScheme random hex colors for $outfile . . .
	
	for element in $( seq $colorsPerScheme )
		do
			# Ex. bc command that does hex substraction:
			# echo 'obase=16;ibase=16;FF-10' | bc
			# to get a random number between 0 and 127; using 256 because the operation is zero-index based, so it substracts 1. For example doing the following with 3 always returns a number between 0 and 2:
			rndNum=`echo $(($RANDOM % 127))`
			echo rndNum is $rndNum
			# But gray in RGB is 127 + 127 + 127 which is 381 or hex 17D; we will substract from 381 decimal OR 17D hex (and if decimal convert to hex).
			exit
		done
done

# DEVELOPMENT LOG
# Before now: duplicate work of rndHexColorsGen.sh (or that is of this). 1st working version.
# 2016-10-22 merged more efficient functionality of duplicate work rndHexColorsGen.sh with better file naming functionality of this.
# 2017-05-23 altered to just output generated hex color scheme list file to current path (and fuss about folders before even invoking or after invoking script). Redifined output file format as .hexplt and updated script to output to that.