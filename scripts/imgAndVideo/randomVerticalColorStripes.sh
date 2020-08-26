# DESCRIPTION
# Creates a `.ppm` (plain text file bitmap format) image of a random number of color columns, each column repeating one color a random number of times, to effectively make a vertical stripe of a random width. Colors used can be random or configurable via input file parameter (of a list of hex color values). Generates Z such images. All random ranges, dimensions, and colors to use configurable; see USAGE for script parameters and example.

# USAGE
# Run with the following parameters:
# - $1 The minimum number vertical color stripes to make (before* image upscale).
# - $2 The maximum number "
# - $3 How many such images to make
# - $4 OPTIONAL. The name of a file list of hex color values to randomly pick from, findable in any of the directories or sub-directories of a path given in ~/palettesRootDir.txt (the script uses another script, findPalette.sh, to search subfolders in the path listed in that file). If not provided, every stripe is a pseudo-randomly generated color (the color created from entropy at run time). FOR HELP creating that file, see createPalettesRootDirTXT.sh in the _ebArt repository.
# Example that will produce minimum 3 vertical stripes, maximum 80, and 5 such images, from the palette sparkleHeartHexColors.hexplt:
#    randomVerticalColorStripes.sh 3 80 5 sparkleHeartHexColors.hexplt
# NOTES
# - See imgs2imgsNN.sh to resize results to an arbitrary size by nearest neighbor method (preserves hard edges).
# - The number of and purpose of positional parameters has altered through this script's development history. If you developed a script that uses this script, and it isn't working, you may want to re-examine the parameters help above and adapt as needed. (It used to have a parameter to randomly vary min. number of columns, which is redundant. You can vary that . . . by varying the min number to begin with.)


# CODE
if ! [ "$1" ]; then printf "\nNo parameter \$1. Exit."; exit; fi
if ! [ "$2" ]; then printf "\nNo parameter \$2. Exit."; exit; fi
if ! [ "$3" ]; then printf "\nNo parameter \$3. Exit."; exit; fi

# In case of interrupted run, clean up first:
if [ -e temp.txt ]; then rm temp.txt; fi
if [ -e *.temp ]; then rm *.temp; fi

# GLOBAL VARIABLES
minColorColumnRepeat=$1
maxColorColumnRepeat=$2
padDigitsTo=${#maxColorColumnRepeat}
howManyImages=$3
# set hexColorSrcFullPath variable from printout of script call:
hexColorSrcFullPath=$(findPalette.sh $4)

if [ "$hexColorSrcFullPath" != "" ]
	then
	echo IMPORTING COLOR LIST from file name\:
	echo $hexColorSrcFullPath
	mapfile -t hexColorsArray < $hexColorSrcFullPath
	sizeOf_hexColorsArray=${#hexColorsArray[@]}
	sizeOf_hexColorsArray=$(( $sizeOf_hexColorsArray - 1))		# Else we get an out of range error for the zero-based index of arrays.
else
	printf "\nERROR: \$hexColorSrcFullPath has an empty value. Test calls to findPalette.sh $4 and examine that script for help. Exit."; exit 1
fi
	# IN DEVELOPMENT:
	# ? Pregenerate a long string which is so many random hex colors smushed together (without any delimiters), to pull hex colors from in chuncks of six characters for greater efficiency; re: http://stackoverflow.com/a/1405641
	# WUT FIX VAR NAMES
	# numRandomCharsToGet=`echo $(( arrSize * getNrandChars ))`
		# echo numRandomCharsToGet val is $numRandomCharsToGet
	# randomCharsString=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $numRandomCharsToGet`
		# echo randomCharsString val is $randomCharsString
	# SAME/SIMILAR (?) IN DEVELOPMENT NOTES:
	# Initialize counter at negative the number of getNrandChars, so that the first iteration in the following loop will set it to 0, which is where we need it to start:
	# multCounter=-$getNrandChars
		# echo multCounter val is $multCounter
	# for filename in ${array[@]}
	# do
			# multCounter=$(($multCounter + $getNrandChars))
			# newFileBaseName=${randomCharsString:$multCounter:$getNrandChars}

for a in $( seq $howManyImages )
do
	howManyStripes=`shuf -i $minColorColumnRepeat-$maxColorColumnRepeat -n 1`
	count=0
	for i in $( seq $howManyStripes )
	do
					echo Generating a stripe for image number $a . . .
						repeatColumnColorCount=`shuf -i $minColorColumnRepeat-$maxColorColumnRepeat -n 1`
				if [ "$4" ]
					then
						# empty temp.txt before writing new color columns to it:
						printf "" > temp.txt
							# Pick a random color from a hex color list if such a list is specified (converting to RGB along the way); otherwise pick completely random RGB values.
							pick=`shuf -i 0-"$sizeOf_hexColorsArray" -n 1`
							hex="${hexColorsArray[$pick]}"
							# Strip the (text format required) # symbol off that. Via yet another genius breath yon: http://Unix.stackexchange.com/a/104887
							hex=`echo ${hex//#/}`
							echo hex is $hex
									# Pick a number of times to repeat that chosen hex color, then write it that number of times to the temp file that will make up the eventual .ppm file: 
									for k in $( seq $repeatColumnColorCount )
									do
											# count each increment of columns:
											count=$(( count + 1 ))
							printf "%d\n %d\n %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2} >> temp.txt
									done
					else

						printf "" > temp.txt
							hex=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6`
									for k in $( seq $repeatColumnColorCount )
									do
											# count each increment of columns:
											count=$(( count + 1 ))
# IN DEVELOPMENT; here it would be a string variable and just + ' ' + $newHexThing ?
							printf "%d\n %d\n %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2} >> temp.txt
									done
				fi
		tr '\n' ' ' < temp.txt > $count.temp
		printf "\t" >> $count.temp
	done

	cat *.temp > grid.ppm
	rm *.temp temp.txt

	printf "P3
	#the P3 means colors are in ascii, then $1 columns and $2 rows, then 255 for max color, then RGB triplets
	$count 1
	255
	" > ppmheader.txt

					echo Concatenating generated rows into one new .ppm file . . .
	timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
		# Format $howManyStripes by padding digits to the number of digits in the highest possible number $maxColorColumnRepeat:
		paddedNum=`printf "%0""$padDigitsTo""d\n" $howManyStripes`
		# echo ===========================
		# echo paddedNum val is\: $paddedNum
	ppmFileName=1x"$paddedNum"stripesRND_"$timestamp"
	cat ppmheader.txt grid.ppm > $ppmFileName.ppm
	echo wrote new ppm file $ppmFileName.ppm
	rm ppmheader.txt grid.ppm
done