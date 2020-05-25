# DESCRIPTION
# Permanently deletes all files in path $1 (parameter one)
# which are in the directory this script is run from.
# Warns you and asks you to type password to confirm.

# USAGE
# pass one parameter, being another path, e.g.:
# deleteDuplicateFileNamesAtOtherFolder.sh /c/whydothosefilesexist/there

thisDir=`pwd`
read -p "WARNING: this script will delete all files in path $1 which have a duplicate file in the immediate path, $thisDir. If that is what you want, type YES_DESTROY_THEM and then press ENTER or RETURN: " FLEURF

if [ "$FLEURF" == "YES_DESTROY_THEM" ]
then
	filesHere=(`gfind . -maxdepth 1 -type f -iname \*.* -printf '%f\n'`)

	for element in "${filesHere[@]}"
	do
	  echo "RUNNING COMMAND: rm $1/$element"
	  rm $1/$element
	done
else
	echo YES_DESTROY_THEM was not typed\; exiting script and doing noththing else.
fi