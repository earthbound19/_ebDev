# DESCRIPTION
# Prints full paths (relative to current directory and subdirectories) of all file types passed as parameters to this script, optionally with sort by newest file modification date first. Files search is recursive.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. If the first parameter is the string 'NEWEST_FIRST' (without the quote marks), listed files will be sorted by newest modification date stamp first, per types for $2 etc.
# - $2 and/or $3, $4, $5 and so on: a list of file types (without the . in their extension), separated by spaces.
# Example that will list all files with the extensions .sh, .py and .c:
#    printFilesTypes.sh sh py c
# Example that will print many file types, with the custom sort order of most recently modified first per type:
#    printFilesTypes.sh NEWEST_FIRST sh py pl c cpp bat ahk reg
# NOTE: if you can remember it (or look it up and use it), this may be more efficient than the loop and repeated call of `find` in this script:
#    find . -maxdepth 1 -type f \( -iname \*.fileTypeOne -o -iname \*.fileType2 \) -printf "%P\n"


# CODE
if ! [ "$1" ]; then printf "\nNo parameter \$1 (file type to print) passed to script. (Note that you can pass more than one. See USAGE comment in script.) Exit."; exit 1; fi

if [ "$1" == "NEWEST_FIRST" ]
then
	NEWEST_FIRST='True'
	fileTypesArray=${@:2}
else
	NEWEST_FIRST='False'
	# Reference using $@ that lists all arguments to script: for var in "$@"; do echo "$var"; done
	fileTypesArray="$@"
fi


if [ $NEWEST_FIRST == 'True' ];
then
	for fileType in ${fileTypesArray[@]}
	do
		find . -iname \*.$fileType -printf "%T@ %p\n" | sort -n -r | sed 's/[0-9 \.]*\/\(.*\)/\1/g'
	done
else
	for fileType in ${fileTypesArray[@]}
	do
		find . -iname \*.$fileType -printf "%P\n"
	done
fi