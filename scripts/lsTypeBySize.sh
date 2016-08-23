# USAGE: run this script with one parameter, being the extension of a type of file you want to list by descending order of size in all subdirectories of the path from which you invoke this script.

# Possible variant command to adapt that shows paths:
# find $PWD/*.exe

ls -Rs -S | grep "\.$1\$" > $1_files_by_size.txt
sort -r -n $1_files_by_size.txt > temp.txt
rm $1_files_by_size.txt
mv temp.txt $1_files_by_size.txt
