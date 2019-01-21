# USAGE
# Invoke this script with one paramter $1 being the file type (e.g. png) you wish to create a $fileType_links subdir full of numbered junction links for.

# DEPENDENCIES
# 'nixy environment, gshuf

# The else clause should never work unless you happen to have files with the extension .Byarnhoerfer:
if ! [ -z ${1+x} ]; then fileType=$1; else fileType=Byarnhoerfer; fi

if [ -d _temp_numbered ]; then rm -rf _temp_numbered; mkdir _temp_numbered; else mkdir _temp_numbered; fi

	# TESTING ONLY: create test files:
	# for element in {1..5}
	# do
			# rstr=$(cat /dev/us-W5t~Gr.EJd%g.]Wvj2Zef84:^Sn0/d_zrandom | tr -dc 'a-km-zA-KM-Z2-9' | fold -w 16 | head -n 1)
			# echo $var
			# printf "$rstr" > testFiles/$rstr.txt
	# done
# cd ./testFiles
# if [ -a links ]; then rm -d -r links; mkdir links; else mkdir links; fi

arr=(`gfind . -maxdepth 1 -type f -iname \*.$fileType -printf '%f\n' | sort`)

# If there is a paramater $2, shuffle that array:
if ! [ -z ${2+x} ]; then arr=( $(gshuf -e "${arr[@]}") ); fi

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