# DESCRIPTION
# Generates random hex color schemes of file format `.hexplt` (randomly named), which are plain text files with one hex color per line.

# USAGE
# Run with these parameters:
# - $1 How many such color schemes to generate. If not provided, one will be made.
# - $2 The number of colors to have in the generated color scheme. If omitted, the script will randomly pick a number between 2 and 7.
# Example that will generate 10 random palette files with 6 colors each:
#    NrandomHexColorSchemes.sh 10 6
# Example that will generate 12 random palette files, and the script will randomly decide how many colors in each:
#    NrandomHexColorSchemes.sh 12


# CODE
rndFileNameLen=8
colorsInThisScheme=7

if [ -z "$1" ]; then howManySchemesToCreate=1; else howManySchemesToCreate=$1; fi
# If no parameter $2 passed, set a string that later is used to instruct to randomly pick a number between 1 and 7:
if [ -z "$2" ]; then pickNcolorsPerScheme="r"; else pickNcolorsPerScheme=$2; colorsInThisScheme=$pickNcolorsPerScheme; fi

# Pregenerate random hex chars to be used in palettes:
allRndHexChars=$(( $howManySchemesToCreate * $colorsInThisScheme * 6 ))	# some waste here, because if pickNcolorsPerScheme == r, a number of colors in a range will be selected for each generated scheme, and the number of hex characters generated against allRndHexChars won't all be used.
# TO DO: add the following line to every script that uses tr such as the following, because Mac terminal throws an error without it, re: https://Unix.stackexchange.com/a/141434/110338
export LC_CTYPE=C
rndHexStrings=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c $allRndHexChars`
# Counter variables incremented by N in loops to partition where to grab random characters from a string:
rndHexMultiCount=0
rndCharsMultiCount=0

# Pregenerate all random characters to be used in random file name strings for saved, generated hex color schemes:
howManyRNDchars=$(( $howManySchemesToCreate * $rndFileNameLen ))
allRndFileNameChars=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $howManyRNDchars`

for howMany in $( seq $howManySchemesToCreate )
do
	rndFileNameChars=${allRndFileNameChars:$rndCharsMultiCount:$rndFileNameLen}
			# respect directive to randomly choose how many colors to make per scheme if so directed:
			if [ $pickNcolorsPerScheme == 'r' ]
			then
				colorsInThisScheme="$(( ($RANDOM % 5) +2 ))"		# between 2 and 7; if the modulo returns 0 then adding two makes it the minimum, 2. If it returns 5, +2 makes it the maximum, 7.
						echo Randomly chose to have $colorsInThisScheme colors in the generated hex color scheme.
				else
						echo Will generate $colorsInThisScheme random hex colors for the generated color scheme.
			fi

	paddedNumColors=$(printf %03d $colorsInThisScheme)
	outfile=./"$paddedNumColors"_"$rndFileNameChars"_HexColors.hexplt
	echo Generating $colorsInThisScheme random hex colors for $outfile . . .

	for element in $( seq $colorsInThisScheme )
		do
			rndHexColorString=${rndHexStrings:$rndHexMultiCount:6}
			echo hex color generated is \#$rndHexColorString . . .
			echo \#$rndHexColorString >> $outfile
			rndHexMultiCount=$(($rndHexMultiCount + 6))
		done
	rndCharsMultiCount=$(($rndCharsMultiCount + $rndFileNameLen))
done

# DEVELOPMENT LOG
# 2018-04-24 how have I used this if the parameters weren't correctly detected? Fixed that and tightened/improved logic, reversed parameter $1 and $2 positions.
# 2017-05-23 altered to just output generated hex color scheme list file to current path (and not fuss about folders before even invoking or after invoking script). Redifined output file format as .hexplt and updated script to output to that.
# 2016-10-22 merged more efficient functionality of duplicate work rndHexColorsGen.sh with better file naming functionality of this.