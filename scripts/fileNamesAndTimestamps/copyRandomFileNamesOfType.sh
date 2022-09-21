# DESCRIPTION
# Copies a random selection of files of type $1 into a randomly named subfolder.

# USAGE
# Run with these parameters:
# - $1 file type to get random copies of files for
# - $2 how many files to copy. Should be less than the number of files of type $1 in the current directory.
# For example, to make 15 random copies of jpg files:
#    copyRandomFileNamesOfType.sh jpg 15


# CODE
if [ "$1" ]; then fileTypeToCopy=$1; else printf "\nNo parameter \$1 (file type to get random copies of files for) passed to script. Exit."; exit 1; fi
if [ "$2" ]; then howMany=$2; else printf "\nNo parameter \$2 (how many files to copy) passed to script. Exit."; exit 2; fi


fileNamesArray=($(find . -maxdepth 1 -type f -iname \*$fileTypeToCopy -printf "%P\n"))

shuffledArray=($(printf '%s\n' "${fileNamesArray[@]}" | shuf))

randomString=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 11)
randomSubFolderName=_"$howMany"_random_"$fileTypeToCopy"_copies__"$randomString"

mkdir $randomSubFolderName

# for zero-based counting, reduce that by one:
aktulCount=$((howMany - 1))
for i in $(seq 0 1 $aktulCount)
do
	cp ./${shuffledArray[$i]} ./$randomSubFolderName/
done

echo DONE. Random copies of files of type $fileTypeToCopy were copied to the randomly named subfolder $randomSubFolderName.