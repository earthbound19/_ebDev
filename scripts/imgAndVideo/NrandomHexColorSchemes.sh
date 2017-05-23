# GENERATES RANDOM HEX COLOR SCHEMES.
# Parameters:
# $1 REQUIRED. The number of colors to have in the generated color scheme. OR to have the script randomly pick a number between 2 and N (first variable assignment hard-coded into script), make this paramater simply the letter r (for random).
# Outputs to randomly named file in e.g.
# ColorSchemesHex/random/Zqev73VvHyv_HexColors.hexplt
# $2 Optional: how many such color schemes to generate. If not provided, two will be made.

# NOTE: at this writing, this script must be executed from the /scripts/imgAndVideo folder.
# TO DO? : Make an unsynced local folder with the absolute path to _devtools root, and reference that? Could be for many scripts, not just this.

colorsPerScheme=12		# This may be overruled by a numeric parameter $1.
rndFileNameLen=34

if [ ! -z ${2+x} ];	then howManySchemesToCreate=$2;	else howManySchemesToCreate=1; fi

# Pregenerate all random hex colors in memory:
			# First calculate the maximum possible number of hex colors to pick if every roll of a virtual die rolled the highest range number per parameter 1 as value 'r'; OR per paramater 1 as numeric value--and use that to set the size of allRndHexChars (in the assignment that follows this block), so there's no chance of running out of pregenerated hex characters:
			if [ ! $1 == 'r' ]
			then
				colorsPerScheme=$1
				# else nothing; just go with the value of $colorsPerScheme as assigned above for the following allRndHexChars assignment.
			fi

allRndHexChars=$(( $howManySchemesToCreate * $colorsPerScheme * 6 ))
rndHexStrings=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c $allRndHexChars`
		# echo rndHexStrings val is $rndHexStrings . . .
# Pregenerate all random characters to be used in random file name strings for saved, generated hex color schemes:
howManyRNDchars=$(( $howManySchemesToCreate * $rndFileNameLen ))
allRndFileNameChars=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $howManyRNDchars`
rndCharsMultiCount=-$rndFileNameLen		# So that the following loop will grab the 0th (1st) item in the string on the first iteration, instead of skipping the first 6 chars--because I'd code increments at the start of a loop then the end.
rndHexMultiCount=-6		# See comment on rndCharsMultiCount initialization.

for howMany in $( seq $howManySchemesToCreate )
do
	rndCharsMultiCount=$(($rndCharsMultiCount + $rndFileNameLen))
	rndFileNameChars=${allRndFileNameChars:$rndCharsMultiCount:$rndFileNameLen}		# Yoink!
			# respect directive to randomly choose how many colors to make per scheme if so directed:
			if [ $1 == 'r' ]
			then
				colorsPerScheme=`shuf -i 2-11 -n 1`
						echo Randomly chose to have $colorsPerScheme colors in the generated hex color scheme.
				else
				colorsPerScheme=$1
						echo Will generate $colorsPerScheme random hex colors for the generated color scheme.
			fi
	paddedNumColors=$(printf %016d $colorsPerScheme)
	outfile=./"$paddedNumColors"_"$rndFileNameChars"_HexColors.hexplt
	# printf "" > $outfile
	echo Generating $colorsPerScheme random hex colors for $outfile . . .
	
	for element in $( seq $colorsPerScheme )
		do
			rndHexMultiCount=$(($rndHexMultiCount + 6))
			rndHexColorString=${rndHexStrings:$rndHexMultiCount:6}
			echo hex color generated is \#$rndHexColorString . . .
			echo \#$rndHexColorString >> $outfile
		done
done

# DEVELOPMENT LOG
# Before now: duplicate work of rndHexColorsGen.sh (or that is of this). 1st working version.
# 2016-10-22 merged more efficient functionality of duplicate work rndHexColorsGen.sh with better file naming functionality of this.
# 2017-05-23 altered to just output generated hex color scheme list file to current path (and fuss about folders before even invoking or after invoking script). Redifined output file format as .hexplt and updated script to output to that.