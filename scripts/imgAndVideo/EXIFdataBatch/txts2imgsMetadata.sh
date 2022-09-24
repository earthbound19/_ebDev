# DESCRIPTION
# For every file of type $1 in the current directory (default txt), calls txt2imgMetadata.sh.

# DEPENDENCIES
# The things that txt2imgMetadata.sh depends on.

# USAGE
# Run with these parameters:
# - $1 extension for file name(s) containing metadata
# For example, if you have these files:
    # grid_paper_with_many_cells_and_a_palette_of_20th_c_e47297b2.jpg
    # grid_paper_with_many_cells_and_a_palette_of_20th_c_e47297b2.txt
    # grid_paper_with_many_cells_and_a_palette_of_many_c_5e80e837.jpg
    # grid_paper_with_many_cells_and_a_palette_of_many_c_5e80e837.txt
# -- where the files of extension .txt contain descriptive information for the .jpg files, and you run this script with .txt (just txt) format for the source metadata parameter $1:
#    txt2imgMetadata.sh txt
# -- then via txt2imgMetadata.sh, it will copy the text in this file:
#    grid_paper_with_many_cells_and_a_palette_of_20th_c_e47297b2.txt
# -- and insert it into the Description metadata field (overwriting) of this file:
#    grid_paper_with_many_cells_and_a_palette_of_20th_c_e47297b2.jpg
# -- and do the same thing for grid_paper_with_many_cells_and_a_palette_of_many_c_5e80e837.txt, and all other txt + jpg file pairs in the directory. Moreover if you also have .tif files with the same base names as the .txt files, it will attempt to insert metadata from the text files into those also.

# CODE
if [ "$1" ]; then metaDataSrcExtension=$1; else printf "\nNo parameter \$1 (metadata source extension) passed to script. Defaulting to txt."; metaDataSrcExtension='txt'; fi

filesList=($(find . -maxdepth 1 -type f -iname \*.$metaDataSrcExtension -printf "%P\n"))

for fileName in ${filesList[@]}
do
	echo working on files associated with $fileName . . .
	txt2imgMetadata.sh $fileName
done