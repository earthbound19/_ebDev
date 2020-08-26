# DESCRIPTION
# Creates a subdirectory of hardlinks to all files of type $1 in the current directory, the hardlinks being numbered file names (digestible e.g. by image processing scripts to create animations).

# USAGE
# Run this script with these parameters:
# - $1 the file type (e.g. png) you wish to create a $fileType_links subdir full of numbered junction links for
# - $2 OPTIONAL. anything (for example the string 'BLAERFNOR'), which will cause the list of files of type $1 to be randomly shuffled before hardlinks of them are made. Useful to e.g. randomize the order of images in an animation if you so desire.
# Example that will make hardlinks to all png images:
#    mkNumberedLinks.sh png
# Example that will do that and randomly shuffle the image list before hardlink creation:
#    mkNumberedLinks.sh png BLAERFNOR


# CODE
# The else clause should never work unless you happen to have files with the extension .Byarnhoerfer:
if [ "$1" ]; then fileType=$1; else fileType=Byarnhoerfer; fi

if [ -d _temp_numbered ]; then rm -rf _temp_numbered; mkdir _temp_numbered; else mkdir _temp_numbered; fi

arr=(`find . -maxdepth 1 -type f -iname \*.$fileType -printf '%f\n' | sort`)

# If there is a parameter $2, shuffle that array:
if [ "$2" ]; then arr=( $(shuf -e "${arr[@]}") ); fi

arraySize=${#arr[@]}
numDigitsOf_arraySize=${#arraySize}

idx=0
for element in ${arr[@]}
do
	# Pads numbers to number of digits in %0n:
	# var=`printf "%05d\n" $element`
	# OR e.g.
	# for i in $(seq -f "%05g" 10 15)
	idx=$(( $idx + 1 ))
	paddedNum=`printf "%0""$numDigitsOf_arraySize""d\n" $idx`
	link ./$element ./_temp_numbered/$paddedNum.$fileType
done