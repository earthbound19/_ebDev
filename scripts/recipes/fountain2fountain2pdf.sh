# DESCRIPTION
# Calls two scripts to join ventilated prose in a fountain format file, then render it to PDF named after the original file.

# DEPENDENCIES
# Two other scripts must be in your PATH, and also the dependencies of those scripts. Those scripts are:
# fountain2fountain.sh
# fountain2pdf.sh

# USAGE
# Run with with one parameter, which is the fountain source file to render.
# For example:
#    fountain2fountain2pdf.sh ascent_to_guru_peak__sps9.fountain
# NOTES
# This script temporarily swaps the file names of the source fountain file and the unventilated converted fountain file. If you interrupt the run of this script, be aware of the potential wrong file names problem that can result of this script being interrupted before it finishes swapping the file names back. Should that happen, know that the original fountain file is named renamed to "$fountainSourceFileName"_tmp_rename_8qeMAvAyp.fountain, and the unventilated one is renamed to the original fountain file (again, both temporarily, but it may stay that way if you interrupt the script run).


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of fountain format source file to convert) passed to script. Exit."; exit 1; else fountainSourceFileName=$1; fi


# sets a variable $targetFountainFileName via the script called with `source`, which variable we will use; also creates an unventilated version of the source file which we will use:
source fountain2fountain.sh $fountainSourceFileName
# rename source fountain file to a temp file:
tmpOriginalFountainFileRename="$fountainSourceFileName"_tmp_rename_8qeMAvAyp.fountain
mv $fountainSourceFileName $tmpOriginalFountainFileRename
# rename unventilated file to original file:
mv $targetFountainFileName $fountainSourceFileName
# render a pdf from the renamed unventilated file:
fountain2pdf.sh $fountainSourceFileName
# delete the unventilated-renamed file, then reverse (restore the temporary rename):
rm $fountainSourceFileName
mv $tmpOriginalFountainFileRename $fountainSourceFileName
# optional; open the pdf:
start ${fountainSourceFileName%.*}.pdf
