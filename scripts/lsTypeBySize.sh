# DESCRIPTION
# Lists (to a txt file) all files of type $1, by descending order of file size. At this writing, does not list paths--you must use the find command or the Everything search engine utility etc. to locate listed files.

# USAGE
# Run this script with one parameter, which is the extension of a type of file you want to list by descending order of size in all subdirectories of the path from which you run this script, for example:
#    lsTypeBySize.sh png
# Results are written to a text file named after the file type, e.g. png_files_by_size.txt.


# CODE
# Possible variant command to adapt that shows paths:
# find $PWD/*.exe
ls -Rs -S | grep "\.$1\$" > $1_files_by_size.txt
sort -r -n $1_files_by_size.txt > temp.txt
rm $1_files_by_size.txt
mv temp.txt $1_files_by_size.txt

printf "\nDONE. Files are listed in $1_files_by_size.txt."