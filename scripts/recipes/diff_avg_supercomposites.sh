# DESCRIPTION
# Repeatedly supercomposites random pairs from array A and B. SEE ALSO `diff_avg_supercomposites_nested_loop.sh`, which takes a random pair from array A and super-composites it against every image in array B.

# USAGE
# Run with one parameter, which is how many supercomposites you want to generate by random selection from two image arrays, e.g. to make 150 of them, run:
#    diff_avg_supercomposites.sh 150


# CODE
# TO DO: use the script that creates an array of image files.
if [ -z "$1" ]; then how_many=312; echo "No parameter \$1 (how many images to make). Defaulting to $how_many."; else how_many=$1; echo "Set how_many to parameter \$1, $how_many"; fi

idiff_all_img_pairs.sh
gm_average_all_img_pairs.sh

# create shuffled array of image file names from subdir image_pairs_diffs:
cd image_pairs_diffs
array_A=($(printAllIMGfileNames.sh | shuf))

# create shuffled array of image file names from subdir image_pairs_averages:
cd ../image_pairs_averages
array_B=($(printAllIMGfileNames.sh | shuf))
cd ..

if [ ! -d process_hybrids ]; then mkdir process_hybrids; fi

arr_A_Size=${#array_A[@]}
arr_B_Size=${#array_B[@]}

echo will loop $how_many times.
looped=0
for byar in $(seq 1 $how_many)
do
	# select random images (file names) from both arrays:
	A=${array_A[$RANDOM % ${#array_A[@]} ]}
	B=${array_B[$RANDOM % ${#array_B[@]} ]}
	echo $A
	echo $B
	B_no_ext=${A%.*}
	A_no_ext=${B%.*}
	
	# Take a diff (subtraction) result and average it with an averaged results:
	outfileNoExt="process_hybrids/""$A_no_ext"__"$B_no_ext"__avg
	outfile="$outfileNoExt".tif
	if [ ! -e "$outfileNoExt"* ]
	then
		echo Doing average of pair $A and $B . . .
		gm convert image_pairs_diffs/$A image_pairs_averages/$B -average $outfile
	else
		echo ~- Target file or similarly named already exists \($outfile\). Skipped render.		
	fi
	
	# Take an averaged result and subtract (diff) a diffed result from it:
	outfileNoExt="process_hybrids/""$B_no_ext"__"$A_no_ext"__diff
	outfile="$outfileNoExt".tif
	if [ ! -e "$outfileNoExt"* ]
	then
		echo Subtracting $B from $A \/  . . .
		idiff -fail 1 -warn 1 -abs -o $outfile image_pairs_averages/$B image_pairs_diffs/$A
	else
		echo ~- Target file or similarly named already exists \($outfile\). Skipped render.		
	fi
	
	looped=$(( $looped + 1 ))
	echo completed loop $looped of "$how_many".
done