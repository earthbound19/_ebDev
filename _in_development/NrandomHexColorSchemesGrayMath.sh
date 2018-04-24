# IN PROGRESS.
# Reworking another script for tweaked purposes. This script will make colors by starting with gray and making secondary, tertiary etc. colors by substracting form or adding to gray (going toward 0 or 255), after theories Itten exposed that pleasing color combinations sum to (or substract from?) gray.

# DESCRIPTION
# Generates random hex color schemes of file format .hexplt (randomly named), which are plain text files with one hex color per line.

# USAGE
# Invoke this script with 1 or optionally 2 parameters:
# The number of colors to have in the generated color scheme. If omitted, the script will randomly pick a color between 2 and 7.
# $2 OPTIONAL. How many such color schemes to generate. If not provided, one will be made.


# CODE
rndFileNameLen=10

# If no paramater $1 passed, set a string that later is used to instruct to randomly pick a number between 1 and 7:
if [ -z ${1+x} ]; then rndNumColorsPerScheme="r"; else colorsPerScheme=$1; fi
echo colorsPerScheme value is $colorsPerScheme

if [ -z ${2+x} ];	then howManySchemesToCreate=1; else howManySchemesToCreate=$2; fi
echo howManySchemesToCreate val is $howManySchemesToCreate

# Pregenerate all random characters to be used in random file name strings for saved, generated hex color schemes:
howManyRNDchars=$(( $howManySchemesToCreate * $rndFileNameLen ))
allRndFileNameChars=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $howManyRNDchars`
rndCharsMultiCount=-$rndFileNameLen		# So that the following loop will grab the 0th (1st) item in the string on the first iteration, instead of skipping the first rndFileNameLen (n) chars--because I'd code increments at the start of a loop then the end.

for howMany in $( seq $howManySchemesToCreate )
do
	rndCharsMultiCount=$(($rndCharsMultiCount + $rndFileNameLen))
	rndFileNameChars=${allRndFileNameChars:$rndCharsMultiCount:$rndFileNameLen}
			# respect directive to randomly choose how many colors to make per scheme if so directed:
			if [ $rndNumColorsPerScheme == 'r' ]
			then
				colorsPerScheme="$(( ($RANDOM % 7) +1 ))"
						# echo Randomly chose to have $colorsPerScheme colors in the generated hex color scheme.
				else
				colorsPerScheme=1
						# echo Will generate $colorsPerScheme random hex colors for the generated color scheme.
			fi
	paddedNumColors=$(printf %05d $colorsPerScheme)
	outfile=./"$paddedNumColors"_"$rndFileNameChars"_HexColors.hexplt
	printf "" > $outfile
	echo Generating $colorsPerScheme random hex colors for $outfile . . .
	
	for element in $( seq $colorsPerScheme )
		do
			rndHexMultiCount=$(($rndHexMultiCount + 6))
			rndHexColorString=${rndHexStrings:$rndHexMultiCount:6}
			echo hex color generated is \#$rndHexColorString . . .
			echo \#$rndHexColorString >> $outfile
		done
done