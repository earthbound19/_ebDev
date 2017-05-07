# DESCRIPTION
# Creates a .ppm (plain text file bitmap format) image of a random number of color columns, each column repeating one color a random number of times, to effectively make a vertical stripe of a random width. Colors used can be random or configurable via input file parameter (of a list of hex color values). Converts the resultant .ppm to a .png image with hard edges preserved (to preserve hard-edged stripes), of dimensions NxN. Generates Z such images. All random ranges, dimensions, and colors to use configurable; see USAGE for script parameters and example.

# USAGE
# Pass this script the following parameters; the last being optional.
# $1 The minimum number of columnar pixels to repeat a color (note that this is *before*) the image upscale).
# $2 The maximum number of columnar pixels to repeat a color (note that this is *before*) the image upscale).
# $3 How many pixels wide to scale the final image
# $4 How many pixels tall to scale the final image
# $5 How many such random images you want to create
# $6 Randomly vary max. number of columns by subtraction between 0 and the number given in this variable. SET THIS TO 0 if no variation desired.
# $7 Optional. A file list of hex color values to randomly pick from. If not provided, every stripe is a pseudo-randomly selected color.

# NOTES
# TO DO
# See comments to that effect throughout code.

# In case of interrupted run, clean up first:
if [ -e temp.txt ]; then rm temp.txt; fi
if [ -e *.temp ]; then rm *.temp; fi
rm *.temp temp.txt

# GLOBAL VARIABLES

# SEE README.md in https://github.com/earthbound19/_devtools.git :
if [ -e $HOME/_devToolsPath.txt ]; then devToolsPath=`< $HOME/_devToolsPath.txt`; fi
devToolsPath=`cygpath -u "\$devToolsPath"`
		# echo devToolsPath val is\:
		# echo $devToolsPath
# the path in _devTools where all hex color scheme text files are stored:
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

# PURE INFURIATING NONSENSE, again appeased by a genius breath yon: http://stackoverflow.com/a/23207966
colorSelectionList=`find $hexColorListsRootPath -name $7 -type f`

# The logic of this variable check is: if not no value for this var, do something (in other words, if there is this var with a value, do something) ;
# UNFORTUNATELY, it seems this type of check only works with environment parameter variables, not assigned variables that have no value, WHICH MEANS that the following must be hard-coded for the parameter:
if [ ! -z ${7+x} ]
	then
	echo IMPORTING FROM COLOR LIST from file name\:
	echo $colorSelectionList
	mapfile -t hexColorsArray < $colorSelectionList
	sizeOf_hexColorsArray=${#hexColorsArray[@]}
	sizeOf_hexColorsArray=$(( $sizeOf_hexColorsArray - 1))		# Else we get an out of range error for the zero-based index of arrays.
fi

# Create a subdir based on the hex color scheme file name, and move into it for this run (move out of it at the end of this run):
pushd
newDirName=`echo $7 | sed 's/\.txt//g'`
# if [ ! -e $newDirName ]; then mkdir $newDirName; else exit; fi
if [ ! -e $newDirName ]; then mkdir $newDirName; fi
cd $newDirName

	# IN DEVELOPMENT:
	# ? Pregenerate a long string which is so many random hex colors smushed together (without any delimiters), to pull hex colors from in chuncks of six characters for greater efficiency; re: http://stackoverflow.com/a/1405641
	# WUT FIX VAR NAMES
	# numRandomCharsToGet=`echo $(( arrSize * getNrandChars ))`
		# echo numRandomCharsToGet val is $numRandomCharsToGet
	# randomCharsString=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $numRandomCharsToGet`
		# echo randomCharsString val is $randomCharsString

for a in $( seq $howManyImages )
do

			# Check and make changes for optional random negative variation of max random number pick range:
			if [ ! -z ${6+x} ]
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
					echo Generating stripe for image number $a . . .
						repeatColumnColorCount=`shuf -i $minColorColumnRepeat-$maxColorColumnRepeat -n 1`
				if [ ! -z ${7+x} ]
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

# OPTIONAL:
echo Creating enlarged png version with hard edges maintained . . .
nconvert -rtype quick -resize $scalePixX $scalePixY -out png -o $ppmFileName.png $ppmFileName.ppm
	# OPTION THAT OVERRIDES X dimension to be half of what the parameter gives:
	# scalePixY=$(( $scalePixX / 2 ))
	# nconvert -rtype quick -resize $scalePixX $scalePixY -out png -o $ppmFileName.png $ppmFileName.ppm

done

popd



	# IN DEVELOPMENT:
	# WUT FIX VAR NAMES and adapt
	# Initialize counter at negative the number of getNrandChars, so that the first iteration in the following loop will set it to 0, which is where we need it to start:
	# multCounter=-$getNrandChars
		# echo multCounter val is $multCounter
	# for filename in ${array[@]}
	# do
			# multCounter=$(($multCounter + $getNrandChars))
			# newFileBaseName=${randomCharsString:$multCounter:$getNrandChars}