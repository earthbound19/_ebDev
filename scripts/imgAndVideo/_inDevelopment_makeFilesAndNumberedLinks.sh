    # Code template: random file name creation (in a subfolder) with numbered hardlinks to them (in a sub-subfolder).
    clear
    if [ -a testFiles ]; then rm -d -r testFiles; mkdir testFiles; else mkdir testFiles; fi
    for element in {1..5}
    do
            rstr=$(cat /dev/urandom | tr -dc 'a-km-zA-KM-Z2-9' | fold -w 16 | head -n 1)
            #echo $var
            printf "$rstr" > testFiles/$rstr.txt
    done
     
    cd ./testFiles
    if [ -a links ]; then rm -d -r links; mkdir links; else mkdir links; fi
    arr=`ls *.*`
    #arr=($arr)
    idx=0
    for element in ${arr[@]}
    do
            # Pads numbers to number of digits in %0n:
            # var=`printf "%05d\n" $element`
            # OR e.g.
            # for i in $(seq -f "%05g" 10 15)
            idx=$(( $idx + 1 ))
            paddedNum=`printf "%05d\n" $idx`
            link ./$element ./links/$paddedNum.hardlink
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