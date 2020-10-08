# DESCRIPTION
# Calls two scripts to join ventilated prose in a fountain format file, then render it to PDF named after the original file.

# DEPENDENCIES
# Two other scripts must be in your PATH, and also the dependencies of those scripts. Those scripts are:
# fountain2fountain.sh
# fountain2pdf.sh

# WARNING
# While this script backs the original fountain file, modifies a copy of it, and then restores from backup, if this script is interrupted or anything else goes wrong, your original fountain file may become damaged or lost. Therefore, back up any file you run this against before you run this.

# USAGE
# Run with these parameters:
# - $1 the fountain source file name to render from.
# - $2 and/or $3 OPTIONAL. See parameters for fountain2pdf.sh. This script will pass these parameters to that.
# Examples:
#    fountain2fountain2pdf.sh ascent_to_guru_peak__sps9.fountain
#    fountain2fountain2pdf.sh ascent_to_guru_peak__sps9.fountain FLOREFLEFL FLOREFLEF
# NOTES
# This script temporarily swaps the file names of the source fountain file and the unventilated converted fountain file. If you interrupt the run of this script, be aware of the potential wrong file names problem that can result of this script being interrupted before it finishes swapping the file names back. Should that happen, know that the original fountain file is named renamed to "$fountainSourceFileName"_tmp_rename_8qeMAvAyp.fountain, and the unventilated one is renamed to the original fountain file (again, both temporarily, but it may stay that way if you interrupt the script run).


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of fountain format source file to convert) passed to script. Exit."; exit 1; else fountainSourceFileName=$1; fi
# check for and throw an error if $fountainSourceFileName does not exist:
if [ ! -f $fountainSourceFileName ]; then echo "PROBLEM: source file $fountainSourceFileName not found. Exit."; exit 1; fi
# sets a variable $targetFountainFileName via the script called with `source`, which variable we will use; also creates an unventilated version of the source file which we will use:
source fountain2fountain.sh $fountainSourceFileName

# rename source fountain file to a temp file:
tmpOriginalFountainFileRename="$fountainSourceFileName"_tmp_rename_8qeMAvAyp.fountain
mv $fountainSourceFileName $tmpOriginalFountainFileRename
# rename unventilated file to original file:
mv $targetFountainFileName $fountainSourceFileName
# render a pdf from the renamed unventilated file:
fountain2pdf.sh $fountainSourceFileName $2 $3
# delete the unventilated-renamed file, then reverse (restore the temporary rename):
rm $fountainSourceFileName
mv $tmpOriginalFountainFileRename $fountainSourceFileName
# optional; open the pdf, and notify if file doesn't exist:
# if [ -e ${fountainSourceFileName%.*}.pdf ]; then start ${fountainSourceFileName%.*}.pdf; else printf "\n~\n!------------------------------------------!\nPROBLEM! target pdf ${fountainSourceFileName%.*}.pdf seems to not have been created (does not exist).\n!------------------------------------------!\n"; fi
