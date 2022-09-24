# DESCRIPTION
# Via other scripts, for file $1 in the current directory, attempts to insert the text of that file into the Description metadata field of every file with the same base file name. See USAGE.

# WARNING
# This script overwrites files (modifies the originals to contain the intended metadata) without warning. This note is your only warning.

# DEPENDENCIES
# listMatchedFileNames.sh, exiftool

# USAGE
# Run with these parameters:
# - $1 file name containing metadata to be copied into the Media Working Group Description field(s) for every file with the same base file name in the current directory.
# For example, if you have these files:
    # grid_paper_with_many_cells_and_a_palette_of_20th_c_e47297b2.txt
    # grid_paper_with_many_cells_and_a_palette_of_20th_c_e47297b2.jpg
# -- where grid_paper_with_many_cells_and_a_palette_of_20th_c_e47297b2.txt contains descriptive information for the grid_paper_with_many_cells_and_a_palette_of_20th_c_e47297b2.jpg, then run:
#    txt2imgMetadata.sh grid_paper_with_many_cells_and_a_palette_of_20th_c_e47297b2.txt
# The script will copy the content of that .txt file into the Media Working Group Description tag(s) (or metadata) of the .jpg file.

# CODE
if [ "$1" ]; then metaDataSourceFileName=$1; else printf "\nNo parameter $1 (metadata source file name) passed to script. Exit."; exit 1; fi

descriptionMetaData=$(cat $metaDataSourceFileName)

matchedFileNames=( $(listMatchedFileNames.sh $metaDataSourceFileName) )
for filename in ${matchedFileNames[@]}
do
	# Handle metadata writing for png vs. other extensions. (Assuming only jpg vs png, which handles cases I want to handle at this writing if not forever.)
	fileExt=${filename##*.}
	if [ "$fileExt" == "png" ] || [ "$fileExt" == "PNG" ]
	then
		exiftool -overwrite_original -Description="$descriptionMetaData" $filename
	else
		exiftool -overwrite_original -MWG:Description="$descriptionMetaData" $filename
	fi
done