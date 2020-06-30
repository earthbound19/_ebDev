# DESCRIPTION
# runs a graphicsmagick average operation against every possible file pair in the current directory to produce interesting average art. Can be really instersting with e.g. satellite photography of Earth (wilderness and/or civilization as seen from space). NOTE that the commands will break on unsupported format files.

# DEPENDENCIES
# gm (graphicsmagick).

# USAGE
# Invoke without any parameters:
#  ./gm_average_all_img_pairs.sh


# CODE

# Get array of many images named imgs_arr via dependency script:
source get_all_imgs_array.sh
array_size=$((${#imgs_arr[@]}))	# store size of that array
inner_loop_start=1						# set base count for inner loop
															# (will increment to avoid operating on the same file)
for outer in ${imgs_arr[@]}			# iterate over all items in array
do
	for((j = inner_loop_start; j<array_size; j++))	# iterate again to get pairs, but don't repeat used pairs (because we start with the increased inner_loop_start count base every iteration back through this inner loop
	do
		inner=${imgs_arr[j]}					# store second file name from array
		inner_no_ext=${inner%.*}	# store that without the file extension
		outer_no_ext=${outer%.*}	# store first file name without file extension
		# use those to make an out file name after both:
		outfileNoExt="image_pairs_averages/""$outer_no_ext"__"$inner_no_ext"__avg		# no ext so I can delete any output file, replace it with a ~_no.txt file starting with the same name, and never render it again (because this script will check for outfileNoExt* files and not render if they exist
		outfile="$outfileNoExt".tif
		if [ ! -d image_pairs_averages ]; then mkdir image_pairs_averages; fi
		# if that out file does not exist, invoke idiff against the source pairs and output the result to the file:
		if [ ! -e "$outfileNoExt"* ]
		then
			echo working on pair $outer \/ $inner . . .
			gm convert $outer $inner -average $outfile
		else
			echo ~- Target file or similarly named already exists \($outfile\). Skipped render.
		fi
	done
	inner_loop_start=$(($inner_loop_start + 1))
done

# If we did all the same things again, but with the lists reversed first, unlike in the idif_all_img_pairs.sh script with subtraction, average will here produce the same result, whatever the file order of a pair--so don't do anything with reversed order.