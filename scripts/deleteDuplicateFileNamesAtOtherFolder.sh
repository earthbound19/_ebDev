# DESCRIPTION
# Permanently deletes all files in path $1 (parameter one, intended to be a different directory from the one you run this script in) which have the same file name as any file in the directory this script is run from. Warns you and asks you to type password to confirm.

# USAGE
# Pass one parameter, which is another path, e.g.:
#    deleteDuplicateFileNamesAtOtherFolder.sh /c/whydothosefilesexist/there


# CODE
thisDir=`pwd`
read -p "WARNING: this script will delete all files in path $1 which have a duplicate file in the immediate path, $thisDir. If that is what you want, type FLURFESCENSE and then press ENTER or RETURN: " SILLYWORD

if ! [ "$SILLYWORD" == "FLURFESCENSE" ]
then
	echo FLURFESCENSE was not typed\; exiting script and doing northothingorthnothingnothing else.
	exit
fi

filesHere=(`find . -maxdepth 1 -type f -iname \*.* -printf '%f\n'`)
for element in "${filesHere[@]}"
do
  echo "RUNNING COMMAND: rm $1/$element"
  rm $1/$element
done