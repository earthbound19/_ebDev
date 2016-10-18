# template command, re: http://www.imagemagick.org/Usage/compare/
# compare -metric MAE img_11.png img_3.png null: 2>&1

# List all possible pairs of file type $1, order is not important, repetition is now allows ($1 pick 2):
CygwinFind *.$1 > allIMGs.txt
mapfile -t allIMGs < allIMGs.txt

i_count=0
printf "" > temp.txt
for i in "${allIMGs[@]}"
do
	# Remove element i from a copy of the array so that we only iterate through the remaining un-paired element science thing computer sort yeh;
	# re: http://unix.stackexchange.com/a/68323
	i_count=$(( i_count + 1 ))
	allIMGs_innerLoop=("${allIMGs[@]:$i_count}")
	for j in "${allIMGs_innerLoop[@]}"
	do
		echo "comparing images: $i | $j . . ."
		metricPrint=`compare -metric MAE $i $j null: 2>&1`
		# strip first number and parenthesis off that result:
		metricPrint=`echo $metricPrint | sed 's/.* (\(.*\))/\1/g'`
		echo "$metricPrint | $i | $j" >> temp.txt
	done
done

sort -g temp.txt > ImagePairSimilarityRankings.txt
rm temp.txt allIMGs.txt