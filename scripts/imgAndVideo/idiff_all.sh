# DESCRIPTION
# runs idiff (from openimageio toolset) against every possible file pair in the current directory to produce interesting diff art. NOTE that the commands will break on unsupported format files.

# DEPENDENCIES
# A 'nixy environment, the openimageio tool set, and images to diff.

# USAGE
# thisScript.sh


# CODE

# Create an array of all file names in the current directory:
array=(`gfind . -maxdepth 1 -type f -printf '%f\n'`)
array_size=$((${#array[@]}))	# store size of that array
inner_loop_start=1						# set base count for inner loop
															# (will increment to avoid operating on the same file)
for outer in ${array[@]}			# iterate over all items in array
do
	for((j = inner_loop_start; j<array_size; j++))	# iterate again to get pairs, but don't repeat used pairs (because we start with the increased inner_loop_start count base every iteration back through this inner loop
	do
		inner=${array[j]}					# store second file name from array
		inner_no_ext=${inner%.*}	# store that without the file extension
		outer_no_ext=${outer%.*}	# store first file name without file extension
		# use those to make an out file name after both:
		outfile="image_diffs/""$outer_no_ext"__"$inner_no_ext"__diff.tif
		if [ ! -d image_diffs ]; then mkdir image_diffs; fi
		# if that out file does not exist, invoke idiff against the source pairs and output the result to the file:
		if [ ! -e $outfile ]
		then
			idiff -o $outfile $outer $inner
		else
			echo ~- Target file already exists \($outfile\). Skipped render.
		fi
	done
	inner_loop_start=$(($inner_loop_start + 1))
done
