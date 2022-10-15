# DESCRIPTION
# Copies every Nth ($2) file of type $1, from the current directory, into a randomly named (or optionally specifically named -- via $3) subdirectory.

# USAGE
# With this script in your PATH, run with these paramters:
# - $1 extension of file types to copy into a subdirectory
# - $2 multiple of file count for copy. For example, if $2 is 120, every 120th file will be copied. (To say that more precisely, every file of type $1 that is found, listed and counted, with a count multiple of 120, will be copied).
# - $3 OPTIONAL. Name of subfolder to copy the files into. If the subfolder already exists, an error is thrown and the script exits. The script also throws an error and exists if the paraters you pass to it result in a generated default subfolder name that already exists.
# To copy all files of type png into a subfolder that have a list count multiple of 120, run:
#    copyEveryNthFileType.sh png 120
# The script's default folder name would result in the files being copied to a folder named `_copies_of_every_80_png`.
# To copy all files of type png into a subfolder with the name _awesome_movie_stills_every_120th_mkay which have that list multiple, run:
#    copyEveryNthFileType.sh png 120 _awesome_movie_stills_every_120th_mkay


# CODE

# ====
# BEGIN SET GLOBALS
# Parse for parameters and set defaults for missing ones\; if they are present\, use them.
if [ ! $1 ]; then printf "\nNo parameter \$1 (file extension to copy into subfolder) passed to script. Exit."; exit 1; else fileExt=$1; fi

if [ ! $2 ]; then printf "\nNo parameter \$1 (multiple of file count to copy into subfolder) passed to script. Exit."; exit 1; else fileExtCountMultiple=$2; fi

if [ ! $3 ]
then
	subfolderName=_copies_of_every_"$fileExtCountMultiple"_"$fileExt"
	echo "No subfolder parameter \$3 passed to script. Folder name set to default $subfolderName."
else
	subfolderName=$3; echo "Subfolder name set to parameter \$3, which is $3."
fi

if [ -d $subfolderName ]
then
	echo "Whoops! A subfolder with that name already exists. Rename or delete that folder and run this script again. The script will exit."
	exit 3
fi
# ====
# END SET GLOBALS

mkdir $subfolderName

allFilesType=( $(find . -maxdepth 1 -iname "*.$fileExt" -printf "%P\n") )

i=1			# iterator
for fileName in ${allFilesType[@]}
do
	if [ $(($i % $fileExtCountMultiple)) == 0 ]
	then
		# echo merp on count $i for file $fileOfType
		cp $fileName ./$subfolderName
	fi
	# increment iterator:
	i=$((i + 1))
done

echo "DONE. Every file of type $fileExt which was listed and counted with a multiple of $fileExtCountMultiple was copied into a subfolder named $subfolderName."