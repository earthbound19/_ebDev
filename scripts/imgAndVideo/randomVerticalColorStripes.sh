# DESCRIPTION
# Creates N `.ppm` (plain text file bitmap format) images of a random number of color columns, each column repeating one color a random number of times, to effectively make vertical stripes of random widths. Colors must be from a .hexplt source list that can be located via `findPalette.sh`. All random ranges, dimensions, and colors to use configurable; see USAGE for script parameters and example.

# DEPENDENCIES
# `findPalette.sh` and its dependencies

# USAGE
# Run with the following parameters:
# - $1 REQUIRED. The minimum number vertical color stripes to make (before* image upscale).
# - $2 REQUIRED. The maximum number "
# - $3 REQUIRED. How many such images to make
# - $4 REQUIRED. The name of a file list of hex color values to randomly pick from, findable in any of the directories or sub-directories of a path searched by `findPalette.sh` (see documentation in taht script). If not provided, every stripe is a pseudo-randomly generated color (the color created from entropy at run time). Random color creation isn't recommended; using a good palette is.
# Example that will produce minimum 3 vertical stripes, maximum 80, and 5 such images, from the palette sparkleHeartHexColors.hexplt:
#    randomVerticalColorStripes.sh 3 80 5 sparkleHeartHexColors.hexplt
# NOTES
# - See imgs2imgsNN.sh to resize results to an arbitrary size by nearest neighbor method (preserves hard edges).
# - The number of and purpose of positional parameters has altered through this script's development history. If you developed a script that uses this script, and it isn't working, you may want to re-examine the parameters help above and adapt as needed. (It used to have a parameter to randomly vary min. number of columns, which is redundant. You can vary that . . . by varying the min number to begin with.)
# - A previous version of this script had an option to randomly generate colors in sRGB color space, but that's going to give you generally not aesthetically pleasing results, so I removed the option, to require deliberate (though random pick) color choices from a palette.


# CODE
if ! [ "$1" ]; then printf "\nNo parameter \$1 (minimum number of columns, or vertical stripes). Exit."; exit 1; else minColorColumnRepeat=$1; fi
if ! [ "$2" ]; then printf "\nNo parameter \$2 (maximum number of columns, or vertical stripes). Exit."; exit 2; else maxColorColumnRepeat=$2; fi
if ! [ "$3" ]; then printf "\nNo parameter \$3 (how many images to make). Exit."; exit 3; else howManyImages=$3; fi

# In case of interrupted run, clean up first:
if [ -e temp.txt ]; then rm temp.txt; fi
# Test list of all *.temp files; if the command succeeds (zero value of errolevel $?), we know they exist, so delete them:
ls *.temp &>/dev/null
if [ $? == 0 ]
then
	rm *.temp
fi

# set hexColorSrcFullPath variable from printout of script call:
if [ "$4" ]
then
	hexColorSrcFullPath=$(findPalette.sh $4)
	paletteFileBaseName="${hexColorSrcFullPath##*/}"
	paletteFileBaseName=${paletteFileBaseName%.*}
	if [ "$hexColorSrcFullPath" != "" ]
	then
		echo IMPORTING COLOR LIST from file name\:
		echo $hexColorSrcFullPath
		# grep command filters out any comments etc. from file and retrieves only the sRGB hex values to an array:
		hexColorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $hexColorSrcFullPath) )		# tr command removes
		sizeOf_hexColorsArray=${#hexColorsArray[@]}
		sizeOf_hexColorsArray=$(( $sizeOf_hexColorsArray - 1))		# Else we get an out of range error for the zero-based index of arrays.
	else
		printf "\nNo parameter \$4 (name of source palette file name). See documentation in the comments of findPalette.sh for help. Exit."; exit 1
	fi
fi
	# DEV SCRAPS; POSSIBLY TO DO:
	# ? Pregenerate a long string which is so many random hex colors smushed together (without any delimiters), to pull hex colors from in chuncks of six characters for greater efficiency; re: http://stackoverflow.com/a/1405641
	# BUT ADAPT THIS TO USE COLORS FROM THE PROVIDED HEX PALETTE.
	# WUT FIX VAR NAMES
	# numRandomCharsToGet=$(echo $(( arrSize * getNrandChars )))
		# echo numRandomCharsToGet val is $numRandomCharsToGet
	# randomCharsString=$(cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $numRandomCharsToGet)
		# echo randomCharsString val is $randomCharsString
	# SAME/SIMILAR (?) IN DEVELOPMENT NOTES:
	# Initialize counter at negative the number of getNrandChars, so that the first iteration in the following loop will set it to 0, which is where we need it to start:
	# multCounter=-$getNrandChars
		# echo multCounter val is $multCounter
	# for filename in ${array[@]}
	# do
			# multCounter=$(($multCounter + $getNrandChars))
			# newFileBaseName=${randomCharsString:$multCounter:$getNrandChars}

for imgNum in $( seq $howManyImages )
do
	howManyStripes=$(shuf -i $minColorColumnRepeat-$maxColorColumnRepeat -n 1)
	count=0
	masterPPMvaluesSTR=
	for i in $( seq $howManyStripes )
	do
		echo Generating stripe $i of $howManyStripes for image $imgNum of $howManyImages . . .
		repeatColumnColorCount=$(shuf -i $minColorColumnRepeat-$maxColorColumnRepeat -n 1)
		# (re)initialize empty tmp constructiong string to append new color columns to:
		tmpSTR=
			# Pick a random color from a hex color list if such a list is specified (converting to RGB along the way); otherwise pick completely random RGB values.
			pick=$(shuf -i 0-"$sizeOf_hexColorsArray" -n 1)
			hex="${hexColorsArray[$pick]}"
			# Strip the (text format required) # symbol off that. Via yet another genius breath yon: http://Unix.stackexchange.com/a/104887
			hex=${hex//#/}
			# Pick a number of times to repeat that chosen hex color, then write it that number of times to the temp file that will make up the eventual .ppm file: 
			for k in $( seq $repeatColumnColorCount )
			do
				# count each increment of columns:
				count=$((count + 1))
				# I see PPM examples in specs have all kinds of different whitespace; I choose one space between sRGB triplet values and two after the triplet to separate them; also direct bash string formatting re https://unix.stackexchange.com/a/252263
				r=$((0x${hex:0:2})); g=$((0x${hex:2:2})); b=$((0x${hex:4:2}))
				tmpSTR="$tmpSTR""$r $g $b "
			done
		# the "$'\n'" adds a newline; re: https://stackoverflow.com/a/9139891
		masterPPMvaluesSTR="$masterPPMvaluesSTR""$tmpSTR""\n"
		# we "should" (according to one source) technically break that into lines shorter than 72 characters, but another source says that's only a recommendation, and converters handle it just fine, so I'm leaving it.
	done
	printf "$masterPPMvaluesSTR" > ppmBody.txt

printf "P3
#P3 means ASCII, next is columns and rows, last is max pixel value. Body is RGB triplets of pixel values.
$count 1
255
" > ppmheader.txt

	echo Concatenating generated rows into one new .ppm file . . .
	timestamp=$(date +"%Y_%m_%d__%H_%M_%S__%N")
		# Format image number by padding digits to the number of digits in $howManyImages:
		padDigitsTo=${#howManyImages}
		imgNumPadded=$(printf "%0""$padDigitsTo""d\n" $imgNum)
		# Format number of colors (stripes) in image to four digits. Yeah it would be wild to ever pad to that, but for file sorting reasons I want it.
		padDigitsTo=4
		stripesPaddedNum=$(printf "%0""$padDigitsTo""d\n" $howManyStripes)
	ppmFileName="$imgNumPadded"_"$stripesPaddedNum"x1_stripes_"$paletteFileBaseName"_"$timestamp"
	cat ppmheader.txt ppmBody.txt > $ppmFileName.ppm
	echo wrote new ppm file $ppmFileName.ppm
	rm ppmheader.txt ppmBody.txt
done