# DESCRIPTION
# Takes a .hexplt source file $1 and a number of colors to choose from it $2, and runs color_growth.py with the --CUSTOM_COORDS_AND_COLORS option with those colors (converted to RGB vals via hexplt2rgbplt.sh), optionally with other CLI options. See USAGE.

# DEPENDENCIES
# color_growth.py, Python 3, hexplt2rgbplt.sh

# USAGE
# Script expects one parameter minimum, and two or three optionally:
# - $1 a .hexplt format flat file (which is a list of RGB colors expressed as hex, with leading pound/hash signs). See collection in /palettes dir of _ebArt repo.
# - $2 OPTIONAL. How many colors to randomly select from that file. IF NOT PROVIDED, or provided as the string 'ALL' (without the single quote marks), will use all colors in the palette. May be fewer or greater than the number of colors in a palette, e.g. if a palette has 20 colors, you may specify 8 or 64, etc. If more than the number of colors in a palette, colors will be randomly selected from the palette up to this number. ALSO, may be provided as a range partitioned with a dash, e.g. 50-100, and the script will randomly select a number from that range inclusive. The start number of the range must be greater than zero, and the end number of the range should be greater than the start number.
# - $3 OPTIONAL. Width of render (although this is redundant to a color_growth.py parameter, this script needs to know it for random coordinate generation). If not used a hard-coded default will be. If you want to use other parameters but the default for this, pass this as NULL.
# - $4 OPTIONAL. Height of render. Same notes/usage for this as for $3.
# - $5 OPTIONAL. Extra parameters as usable by color_growth.py. These muse be enclosed in double-quote marks. See output of -h switch from that script.
# EXAMPLE COMMAND, with number of colors in palette used:
#    color_growth_hexplt_multiColor.sh palette.hexplt ALL
# ANOTHER EXAMPLE COMMAND, using 5 colors of the palette, and adding custom parameters :
#    color_growth_hexplt_multiColor.sh palette.hexplt 5 '--RANDOM_SEED 817141 --TILEABLE True --SAVE_EVERY_N 140'
# ANOTHER EXAMPLE COMMAND, randomly using from 13 to 100 colors (and if the palette has only 5 colors, the script will randomly select colors from the palette until it has picked however many colors it decides to pick between 13 and 100) :
#    color_growth_hexplt_multiColor.sh palette.hexplt 13-100 '--RANDOM_SEED 817141 --TILEABLE True --SAVE_EVERY_N 140'
# NOTES
# - This script sets the first randomly selected color drawn as --BG_COLOR.
# - To pass for example the following parameter, do not enclose the parenthesis with double or single-quotes, as you must ordinarily on Windows and maybe other platforms:
#        --GROWTH_CLIP (1,4)
# - If you don't specify a GROWTH_CLIP, this will generate a random one in the range of what color_growth.py will accept.


# CODE
# TO DO
# error checking on form of parameter for number of colors to use, and if it is a range, that maxrange > minrange.

# START VARIABLES SET
if [ "$1" ]
then
	sourceHEXPLT=$1
	echo source hex palette file is $sourceHEXPLT
else
	printf "No parameter \$1 passed to script. See USAGE. Exiting."
	exit
fi

if [ "$2" ] && [ "$2" != "ALL" ]
then
	numColorsToUse=$2
	printf "\n~Parameter \$2 passed to script with value $numColorsToUse. Will use that many colors. If that is not a number but a range, will randomly draw a number from that range, and use that number."
fi
# If there was no parameter 2 passed OR it was passed as ALL, set
# numColorsToUse to the number of colors in the palette file:
if ! [ "$2" ] || [ "$2" == "ALL" ]
then
	numColorsToUse=$(wc -l < $sourceHEXPLT)
	printf "\n~ No parameter \$2 passed, or it was passed as keyword ALL.\nDetermined that palette has $numColorsToUse colors. Will use that many."
fi
# Check via error level, after run of grep search, if a dash is in the value of $numColorsToUse. If so, reset numColorsToUse to a random value in the range (as expected by parameter format):
echo ""
printf "\n~ examining parameter for number of colors to use; is it a range? . . .\n"
echo "$numColorsToUse" | grep '-'
if [ $(echo $?) == "0" ]
then
	printf "\n~ Yes, it's a range; setting number of colors to use to a random number from that range, inclusive . . .\n"
	lowNumber=$(echo $numColorsToUse | sed 's/\([0-9]\{1,\}\)-.*/\1/g')
	highNumber=$(echo $numColorsToUse | sed 's/.*-\([0-9]\{1,\}\)$/\1/g')
	numColorsToUse=$(seq $lowNumber $highNumber | shuf -n 1)
	printf "\n~ Have set numColorsToUse to $numColorsToUse."
fi

if [ "$3" ] && [ "$3" != "NULL" ]
then
	targetRenderWidth=$3
	printf "\n\n~ Parameter \$3 passed with value $targetRenderWidth. Will use that for width."
fi
if ! [ "$3" ] || [ "$3" == "NULL" ]
then
	targetRenderWidth=1920
	printf "\n\n~ No parameter \$3 (width) passed to script, or it was passed as NULL.\nWill use default width $targetRenderWidth."
fi

if [ "$4" ] && [ "$4" != "NULL" ]
then
	targetRenderHeight=$4
	printf "\n\n~ Parameter \$4 passed with value $targetRenderHeight. Will use that for height."
fi
if ! [ "$4" ] || [ "$4" == "NULL" ]
then
	targetRenderHeight=1080
	printf "\n\n~ No parameter \$4 (height) passed to script, or it was passed as NULL.\nWill use default height $targetRenderHeight."
fi

if [ "$5" ]
then
	additionalParams=$5
	printf "\n\n~ Parameter \$5 passed to script. Additional parameters from it:\n$additionalParams\n\n"
fi
# END VARIABLES SET.

hexplt2rgbplt.sh $sourceHEXPLT
paletteFileNoExt=$(echo "${sourceHEXPLT%.*}")
convertedPaletteFile=$paletteFileNoExt.rgbplt
rndString=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6)
dateTimeString=$(date +"%Y_%m_%d__%H_%M_%S")
cgpFileName="$numColorsToUse"_from_"$paletteFileNoExt"__"$dateTimeString"__"$rndString".cgp
# AND NOW FOR SOMETHING COMPLETELY DIFFERENT . . .
# code that enables use of more colors than are in the palette
# (randomly repeating some colors):
# If we don't set the delimiter as newline, it splits up RGB triplet
# values; we want them as one, which we get if we split on newlines:
OIFS="$IFS"
IFS=$'\n'
numColorsInPalette=$(wc -l < $convertedPaletteFile)
drawFromPaletteNtimesToGetnumColorsToUse=$(echo "$numColorsToUse / $numColorsInPalette + 1" | bc)		# +1 because math reasons.
arrayFromConvertedPaletteFile=($(shuf $convertedPaletteFile))
arrayColorPoolToRNDdrawFrom=()
for ((j=1;j<=drawFromPaletteNtimesToGetnumColorsToUse;j++))
do
	tmpArray=( $(shuf -e "${arrayFromConvertedPaletteFile[@]}") )
	# combines elements of two arrays into one:
	arrayColorPoolToRNDdrawFrom=("${tmpArray[@]}" "${arrayColorPoolToRNDdrawFrom[@]}")
done
colorsToUse=()
arrayColorPoolToRNDdrawFrom=( $(shuf -e "${arrayColorPoolToRNDdrawFrom[@]}") )
colorsSelected=0
for element in ${arrayColorPoolToRNDdrawFrom[@]}
do
	if [ $colorsSelected -lt $numColorsToUse ]
	then
		colorsToUse+=($element)
	fi
	colorsSelected=$((colorsSelected+1))
done
rndStringTwo=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6)
# unique RGB temp file list name for this run of script, to avoid
# duplicate clobbering if running more than one instance of script:
tmpRGBlistFileName=tmp_RGBlist_yyy3CHVC5F_"$rndStringTwo".rgbplt
printf "" > ./$tmpRGBlistFileName
for element in ${colorsToUse[@]}
do
	echo $element >> ./$tmpRGBlistFileName
done
# END AND NOW FOR SOMETHING COMPLETELY DIFFERENT

# Get first color in that list and set as BG_COLOR:
BG_COLOR=$(head -n 1 ./$tmpRGBlistFileName)
BG_COLOR=$(echo $BG_COLOR | sed 's/ /,/g')

# get an RND clip range (will be overriden by anything in $additionalParams, as that is passed last in the color_growth.py parameter set):
lowGrowthClipParam=$(shuf -i 1-8 -n 1)
highGrowthClipParamAddend=$(shuf -i 2-8 -n 1)
highGrowthClipParam=$(($lowGrowthClipParam + $highGrowthClipParamAddend))
# reduce the upper value to max if it's beyond max:
if [ $highGrowthClipParam -gt 8 ]; then echo highGrowthClipParam value $highGrowthClipParam greater than max allowed \(8\)\; reducing to 8\.; highGrowthClipParam=8; fi
echo "That'll be --GROWTH_CLIP ($lowGrowthClipParam,$highGrowthClipParam), Capn'."

# Create start of .cgp preset file with starting with our custom settings:
	# woa wut printf must always have format string? then should it always throw an error if it doesn't?
	# re: https://Unix.stackexchange.com/a/22768/110338 :
printf '%s' "--WIDTH $targetRenderWidth --HEIGHT $targetRenderHeight --BG_COLOR [$BG_COLOR] --GROWTH_CLIP ($lowGrowthClipParam,$highGrowthClipParam) $additionalParams --CUSTOM_COORDS_AND_COLORS [" > $cgpFileName

while read -r element
do
	# get rnd coord vals for building command:
	rndXcoord=$(shuf -i 1-$targetRenderWidth -n 1)
	rndYcoord=$(shuf -i 1-$targetRenderHeight -n 1)
	RGBlist=$(echo $element | sed 's/ /,/g')
	printf "[($rndXcoord,$rndYcoord),[$RGBlist]]," >> $cgpFileName
done < ./$tmpRGBlistFileName
rm ./$tmpRGBlistFileName

# remove trailing comma from that command being built:
sed -i 's/\(.*\),$/\1/' $cgpFileName
# append closing ] to command in file, to finish creating it:
printf ']' >> $cgpFileName

# Because a double-space in the paramater in the preset file throws it without any helpful error (unless or until that bug is fixed in color_growth.pt), avoid that by reducing all double-spaces to single:
sed -i 's/  / /g' $cgpFileName

# RUN color_growth.py with that newly constructed preset:
pathTo_color_growth_py=$(getFullPathToFile.sh color_growth.py)
command="python $pathTo_color_growth_py --LOAD_PRESET $cgpFileName"
tmpBashScriptFileName=tmp_color_growth_hexplt_multiColor_script_6WRsTNfeU3CEvS_"$rndString".sh
printf "$command" > $tmpBashScriptFileName
printf "Executing command:\n$command\n via temp script tmp_color_growth_hexplt_multiColor_script_6WRsTNfeU3CEvS.sh . . .\n"
./$tmpBashScriptFileName
printf "Waiting 4 seconds before deleting ~multiColor~ temp script file . . .\n"
sleep 4
rm ./$tmpBashScriptFileName

IFS="$OIFS"