# IN PROGRESS.

# DESCRIPTION: converts all files of a given type in a directory to "glitch" (really data-bent?) art via repeated calls to data2PPMglitchArt.sh.

# USAGE: invoke this script with these parameters:
# $1 file type to operate on (e.g. .dat, bug give the parameter as just dat)
# Example:
# ./thisScript.sh txt

# TO DO
# Check if target file exists and do not overwrite if it does.

img_format_1=$1

array=(`gfind . -maxdepth 1 -type f -iname \*.$img_format_1 -printf '%f\n'`)
for element in ${array[@]}
do
	data_bend_2PPMglitchArt00padded.sh $element
	# OR, and not preferred at this writing:
	# data2PPMglitchArt.sh $element
done