# DESCRIPTION
# Runs a GraphicsMagick average operation against every possible file pair in the current directory to produce art from the average of pixels in the same position in two images. Can be really interesting with e.g. satellite photography of Earth (wilderness and/or civilization as seen from space), or two different abstract art works, or a satellite image and an abstract art work, or potentially any two different (or the same!) types of sources. NOTE that the commands will break on unsupported format files.

# DEPENDENCIES
# gm (GraphicsMagick)

# USAGE
# Run without any parameters:
#    gm_average_all_img_pairs.sh


# CODE

# Get array of many images named imgs_arr via dependency script:
allIMGsArray=($(printAllIMGfileNames.sh))
array_size=${#allIMGsArray[@]}	# store size of that array
inner_loop_start=1						# set base count for inner loop
															# (will increment to avoid operating on the same file)
for outer in ${allIMGsArray[@]}			# iterate over all items in array
do
	for((j = inner_loop_start; j<array_size; j++))	# iterate again to get pairs, but don't repeat used pairs (because we start with the increased inner_loop_start count base every iteration back through this inner loop
	do
		inner=${allIMGsArray[j]}					# store second file name from array
		inner_no_ext=${inner%.*}	# store that without the file extension
		outer_no_ext=${outer%.*}	# store first file name without file extension
		# use those to make an out file name after both:
		outfileNoExt="image_pairs_averages/""$outer_no_ext"__"$inner_no_ext"__avg		# no ext so I can delete any output file, replace it with a ~_no.txt file starting with the same name, and never render it again (because this script will check for outfileNoExt* files and not render if they exist
		outfile="$outfileNoExt".tif
		if [ ! -d image_pairs_averages ]; then mkdir image_pairs_averages; fi
		# if that out file does not exist, run idiff against the source pairs and output the result to the file:
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