# DESCRIPTION
# Runs idiff (from openimageio toolset) against every possible file pair in the current directory to produce interesting diff art. Can be really interesting with e.g. satellite photography of Earth (wilderness and/or civilization as seen from space). NOTE that the commands will break on unsupported format files.

# DEPENDENCIES
# A 'Nixy environment, the openimageio tool set, images to diff, and `printAllIMGfileNames.sh`.

# USAGE
# Run without any parameter:
#    idiff_all_img_pairs.sh
# NOTE
# IF SOURCE IMAGES are of various resolutions (not all the same), you may wish to first create copies of them all at matching resolutions via gm_downsize_img_copies_to_smallest.sh, and then run this script against the resulting /__smaller_img subfolder. Then run this script.


# CODE
# TO DO:
# - Resize larger image to fit in smaller before idiff operation (instead of recommendation of use gm_downsize_img_copies_to_smallest.sh beforehand, which loses a lot of resolution for many images if there is only one small image, where with this approach we could instead get higher resolution results.
# - DON'T TRY saving to jpgs via this tool, because this tool isn't built to. Jpegs from this are 8-bit and of inferior quality versus the 24-bit tifs. It might be nice to pipe the image output to another openimageio tool to save a high-quality 24-bit image.
# Get array of many images named imgs_arr via dependency script:
allIMGsArray=($(printAllIMGfileNames.sh))
# Shuffle that so that any re-run of this script will always go through images in a different order (useful for previewing samples among many choices):
allIMGsArray=($(shuf -e "${allIMGsArray[@]}"))

array_size=$((${#allIMGsArray[@]}))	# store size of that array
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
		outfileNoExt="image_pairs_diffs/""$outer_no_ext"__"$inner_no_ext"__diff		# no ext so I can delete any output file, replace it with a ~_no.txt file starting with the same name, and never render it again (because this script will check for outfileNoExt* files and not render if they exist
		outfile="$outfileNoExt".tif
		if [ ! -d image_pairs_diffs ]; then mkdir image_pairs_diffs; fi
		# if that out file does not exist, run idiff against the source pairs and output the result to the file:
		if [ ! -e "$outfileNoExt"* ]
		then
			idiff -fail 1 -warn 1 -abs -o $outfile $outer $inner
		else
			echo ~- Target file or similarly named already exists \($outfile\). Skipped render.
		fi
	done
	inner_loop_start=$(($inner_loop_start + 1))
done

# All the same things again, but with the lists reversed first, because if you operate on the same pair of file names in different parameter order, you get different results;
# Reverse the array (into a copy of it) ; re https://Unix.stackexchange.com/a/412870 :
min=0
max=$(( ${#allIMGsArray[@]} ))
while [[ min -lt max ]]
do
    # Swap current first and last elements
    x="${allIMGsArray[$min]}"
    reversedArray[$min]="${allIMGsArray[$max]}"
    reversedArray[$max]="$x"
    # Move closer
    (( min++, max-- ))
done
# use the reverse array:
inner_loop_start=1
for outer in ${reversedArray[@]}
do
	for((j = inner_loop_start; j<array_size; j++))
	do
		inner=${reversedArray[j]}
		inner_no_ext=${inner%.*}
		outer_no_ext=${outer%.*}
		outfileNoExt="image_pairs_diffs/""$outer_no_ext"__"$inner_no_ext"__diff
		outfile="$outfileNoExt".tif
		if [ ! -e "$outfileNoExt"* ]
		then
			idiff -fail 1 -warn 1 -abs -o $outfile $outer $inner
		else
			echo ~- Target file or similarly named already exists \($outfile\). Skipped render.
		fi
	done
	inner_loop_start=$(($inner_loop_start + 1))
done
