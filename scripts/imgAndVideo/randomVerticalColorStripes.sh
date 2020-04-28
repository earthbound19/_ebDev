# DESCRIPTION
# Creates a .ppm (plain text file bitmap format) image of a random number
# of color columns, each column repeating one color a random number of times,
# to effectively make a vertical stripe of a random width. Colors used can be
# random or configurable via input file parameter (of a list of hex color
# values). Converts the resultant .ppm to a .png image with hard edges preserved
# (to preserve hard-edged stripes), of dimensions NxN. (EXCEPT NOT at this
# writing, if ever.) Generates Z such images. All random ranges, dimensions,
# and colors to use configurable; see USAGE for script parameters and example.

# USAGE
# Pass this script the following parameters; the last being optional.
# $1 The minimum number vertical color stripes to make (note that this is *before*) the image upscale).
# $2 The minimum number vertical color stripes to make (note that this is *before*) the image upscale).
# $3 How many pixels wide to scale the final image
# $4 How many pixels tall to scale the final image
# $5 How many such random images you want to create
# $6 Randomly vary max. number of columns by subtraction between 0 and the
#  number given in this variable. SET THIS TO 0 if no variation desired.
# $7 Optional. The name of a file list of hex color values to randomly pick
#  from, findeable in any of the directories or sub-directories of a path given
#  in ~/palettesRootDir.txt (the script uses another script, findHEXPLT.sh,
# to search subfolders in the path listed in that file). If not provided,
#  every stripe is a pseudo-randomly generated color (the color created from
#  entropy at run time). FOR HELP creating that file, see
#  createPalettesRootDirTXT.sh in the _ebArt repository.
# EXAMPLE:
# randomVerticalColorStripes.sh 3 80 1920 1080 5 30 sparkleHeartHexColors.txt

# TO DO
# Invoke imgs2imgsNN.sh for ppm to png conversion, passing resize params.
# Set new subfolder name "RND" or summat if no .hexplt file name passed to script.


# CODE
# In case of interrupted run, clean up first:
if [ -e temp.txt ]; then rm temp.txt; fi
if [ -e *.temp ]; then rm *.temp; fi

# GLOBAL VARIABLES
hexColorSchemesRootSubPath="/scripts/imgAndVideo/ColorSchemesHex"
hexColorListsRootPath="$devToolsPath""$hexColorSchemesRootSubPath"
minColorColumnRepeat=$1
maxColorColumnRepeat=$2
scalePixX=$3
scalePixY=$4
howManyImages=$5
maxColorColumnsVariation=$6
maxPossibleColumns=$(( $maxColorColumnRepeat + $maxColorColumnsVariation))
padDigitsTo=${#maxPossibleColumns}
# set hexColorSrcFullPath environment variable via the following script:
source findHEXPLT.sh $7
		# echo hexColorSrcFullPath value is\:
		# echo $hexColorSrcFullPath

# The logic of this variable check is: if not no value for this var, do something (in other words, if there is this var with a value, do something) ;
# UNFORTUNATELY, it seems this type of check only works with environment parameter variables [by this do I mean e.g. $1, $2, $3 etc.?], not assigned [script or named?] variables that have no value, WHICH MEANS that the following must be hard-coded for the parameter:
if [ "$7" ]
	then
	echo IMPORTING COLOR LIST from file name\:
	echo $hexColorSrcFullPath
	mapfile -t hexColorsArray < $hexColorSrcFullPath
	sizeOf_hexColorsArray=${#hexColorsArray[@]}
	sizeOf_hexColorsArray=$(( $sizeOf_hexColorsArray - 1))		# Else we get an out of range error for the zero-based index of arrays.
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
			# Check and make changes for optional random negative variation of max random number pick range:
			if [ "$6" ]
				then
					randomVariation=`shuf -i 0-"$6" -n 1`
					maxRange=$(( $maxColorColumnRepeat - $randomVariation ))
				else
					maxRange=$maxColorColumnRepeat
			fi
	howManyStripes=`shuf -i $minColorColumnRepeat-$maxRange -n 1`
	count=0
	for i in $( seq $howManyStripes )
	do
					echo Generating a stripe for image number $a . . .
						repeatColumnColorCount=`shuf -i $minColorColumnRepeat-$maxColorColumnRepeat -n 1`
				if [ "$7" ]
					then
						# empty temp.txt before writing new color columns to it:
						printf "" > temp.txt
							# Pick a random color from a hex color list if such a list is specified (converting to RGB along the way); otherwise pick completely random RGB values.
							pick=`shuf -i 0-"$sizeOf_hexColorsArray" -n 1`
							hex="${hexColorsArray[$pick]}"
							# Strip the (text format required) # symbol off that. Via yet another genius breath yon: http://unix.stackexchange.com/a/104887
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

# OPTIONAL -- TO DO: invoke what is given in TO DO above instead:
# echo Creating enlarged png version with hard edges maintained . . .
# nconvert -rtype quick -resize $scalePixX $scalePixY -out png -o $ppmFileName.png $ppmFileName.ppm
	# OPTION THAT OVERRIDES X dimension to be half of what the parameter gives:
	# scalePixY=$(( $scalePixX / 2 ))
	# nconvert -rtype quick -resize $scalePixX $scalePixY -out png -o $ppmFileName.png $ppmFileName.ppm
done