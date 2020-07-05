# DESCRIPTION
# Reads seeds (for randomNsetChars.pde) from seeds.txt in a folder
# above so many animation frame subfolders, and writes those seeds
# into text files named after the seeds, in the subfolders. To identify
# seeds that generated random animation images.
# This is probably a one-use script; it fixes something that happened
# before I fixed randomNsetChars.pde to do it.

# CODE
folders=(`find . -type d -printf '%f\n' | sort -n | sed 's/.*[AM|PM] \.\/\(.*\)/\1/g'`)
# the :1 in the following slices the array to omit
# the first element, ., which we don't want;
# re: https://stackoverflow.com/a/2701872/1397555
folders=("${folders[@]:1}")

seeds_idx=0
while IFS= read -r line || [ -n "$line" ]; do
	# echo line "$line" seeds_idx "$seeds_idx" echo folder ${folders[$seeds_idx]}
	print_to_file_name=`echo "${folders[$seeds_idx]}"/$line.txt`
	echo "The random seed for the variant that produced the images in this folder is $line." > $print_to_file_name
	seeds_idx=$((seeds_idx + 1))
done < seeds.txt