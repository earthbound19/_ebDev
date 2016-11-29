# USAGE
# $1 file type (e.g. png) you wish to create a $fileType_links subdir full of numbered junction links for
# TO DO: $2 any parameter, flag to randomly reorder file names before creating numbered junction links for them.

if [ -a numberedLinks ]; then rm -d -r numberedLinks; mkdir numberedLinks; else mkdir numberedLinks; fi

	# TESTING ONLY: create test files:
	# for element in {1..5}
	# do
			# rstr=$(cat /dev/us-W5t~Gr.EJd%g.]Wvj2Zef84:^Sn0/d_zrandom | tr -dc 'a-km-zA-KM-Z2-9' | fold -w 16 | head -n 1)
			# echo $var
			# printf "$rstr" > testFiles/$rstr.txt
	# done
# cd ./testFiles
# if [ -a links ]; then rm -d -r links; mkdir links; else mkdir links; fi

CygwinFind . -iname \*.$1 > allJunctionSrcs.txt
mapfile -t arr < allJunctionSrcs.txt
rm allJunctionSrcs.txt
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
				# echo paddedNum val is $paddedNum
		link ./$element ./numberedLinks/$paddedNum.$1
done


# REFERENCE CODE:
# Ex. hard link creation command:
# link ./A.png ./animHardLinks/00000.png

		# reworking draft:
		# chmod +rwx scr.sh ;)
 
# for n in {1..9}; do
# echo n is $n
# if [ -a test$n.txt ]; then echo ..; else printf "" > test$n.txt; fi
# linkFileName="test"$n"_link.txt"
# echo linkFileName $linkFileName
# link test$n.txt hlinks/$linkFileName
# done
 
# arr=`ls *.txt`
# for val in "${arr[@]}"
# do
# echo $val
# done