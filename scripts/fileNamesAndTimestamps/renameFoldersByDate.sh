# DESCRIPTION
# Renames all folders in the current folder (directory) by unix date stamp to custom format, based on the newest file found inside each folder. Not recursive: subfolders of folders are not found or operated on. Prompts to confirm operation.

# USAGE
# Run without any parameter, and follow the prompt:
#    renameFoldersByDate.sh
# To override the prompt and force renames, pass one parameter, which is the word HARCHOOF:
#    renameFoldersByDate.sh HARCHOOF


# CODE
do_the_things='FALSE'
if [ "$1" ] && [ "$1" == 'HARCHOOF' ]; then do_the_things='TRUE'; fi

if [ $do_the_things != 'TRUE' ]
then
	echo ""
	echo "WARNING: this script will rename every folder in the current"
	echo "directory by its date, to folder names like:"
	echo ""
	echo "2021_10_02__01_27"
	echo ""
	echo "This script will not rename subdirectories within directories;"
	echo "only directories in this folder will be renamed."
	echo ""
	echo "If this is what you want, type:"
	echo ""
	echo "HARCHOOF"
	echo ""
	echo "--and then press ENTER (or return, as the case may be)."
	echo "If that is NOT what you want to do, press CTRL+z or CTRL+c,"
	echo " or type something else and press ENTER, to terminate this"
	echo "script."

	read -p "TYPE HERE: " USERINPUT

	if [ $USERINPUT != 'HARCHOOF' ]
	then
		echo "User input does not equal $PASS_STRING. Script will exit without doing anything."
		exit 1
	else
		do_the_things='TRUE'
	fi
fi

# Check again to do the things, and if not do the things, then don't do them. I know, this logic is SO DARN POETIC.
if [ $do_the_things == 'TRUE' ]
then
	# Get the names of all current into an array:
	directories=$(find . -maxdepth 1 -type d -printf "%P\n")
	for directory_name in ${directories[@]}
	do
		pushd . >/dev/null
		cd $directory_name
		echo "Working in directory: $directory_name . . ."
		# find last modified file and format date stamp from it:
		dateSTR=$(find . -maxdepth 1 -type f -printf "%T+\n" | sort | tail -n 1 | tr '-' '_')
		# filter that to end at hours, minutes and second:
		dateSTR=$(echo $dateSTR | sed 's/\([0-9_]\{1,\}\)+\([^\.]\{1,\}\).*/\1__\2/g')
		# then to replace colons with underscores:
		dateSTR=$(echo $dateSTR | tr ':' '_')
		popd >/dev/null
		echo "RUNNING COMMAND: mv $directory_name $dateSTR"
		echo " . . ."
		mv $directory_name $dateSTR
		printf "\n\n"
done
fi



