<<<<<<< HEAD
# USAGE: run this script with one parameter, being the extension of a type of file you want to list by descending order of size in all subdirectories of the path from which you invoke this script.
=======
# DESCRIPTION
# Lists all files of a given type (passed to script as parameter) by descending order of file sizes. At this writing, does not list paths--you must use the find command or the Everything search engine utitility etc. to locate listed files.

# USAGE
# Run this script with one parameter, being the extension of a type of file you want to list by descending order of size in all subdirectories of the path from which you invoke this script.
>>>>>>> 947fd5f52876f88f02a00e30e0d98c160d9e5b10

# Possible variant command to adapt that shows paths:
# find $PWD/*.exe

ls -Rs -S | grep "\.$1\$" > $1_files_by_size.txt
sort -r -n $1_files_by_size.txt > temp.txt
rm $1_files_by_size.txt
mv temp.txt $1_files_by_size.txt
