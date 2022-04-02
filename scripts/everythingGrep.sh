# DESCRIPTION
# Fast global search within Windows files. Gets a list of all file names that match search string $1 (via voidtools Everything), then prints any results (with the file name) of grep search $2 from them. Windows only, so far as I know. SEE ALSO: advanced search menu in Everything, and restricting search to a specific folder via Everything right-click shell menu option.

# USAGE
# Run with these parameters:
# - $1 string to find matching file names for
# - $2 search string to grep (search within) all files found from Everything via $1.
# For example:
#    everythingGrep.sh .sh BWsvgRandomColorFill
# NOTE
# for advanced searching, refer to https://www.voidtools.com/support/everything/searching/ (for example, to find files that end with a certain string, search for:
#    endwith:.sh
# -- but you may need to surround your search with single quote marks if it contains unusual characters, like this:
#    everythingGrep.sh 'endwith:.sh' BWsvgRandomColorFill
# -- or also (per DESCRIPTION) see advanced search options menu in Everything.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (Everything file name match string) passed to script. Exit."; exit 1; else EverythingFileNameSearch=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (search within files for string) passed to script. Exit."; exit 1; else searchWithinFileString=$1; fi

# the -a-d switch here (alt. for /a-d, which isn't parsing in MSYS2 even if I escape the \) restricts search to files (excludes folders) :
foundFileNames=($(es -a-d $EverythingFileNameSearch | tr -d '\15\32'))		# the tr statement deletes

for fileName in ${foundFileNames[@]}
do
	cygFileName=$(cygpath $fileName)
	# --binary-files=binary seems to speed up (skip?) searches in files that contain bytes other than I don't know what text data codepage:
	result=$(grep -n -s -i --context=3 --binary-files=binary $2 $cygFileName)
	if [ "$result" != "" ]
	then
		echo ""
		echo "FILE: $cygFileName"
		echo "FIND:"
		echo $result
		echo "--"
	fi
done

echo ""
echo "everythingGrep.sh search done."