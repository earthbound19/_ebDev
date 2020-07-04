# DESCRIPTION
# Lists all files that have the tag FINAL in them:
# gfind . -type f -iregex '.*_FINAL_.*' or, alternately '.*FINAL.*'. Paths to files are stripped from the print; you must use a tool like the Everything search engine on Windows to find their folder.

# USAGE
# Call this script from a path where you wish to list all files that include the offset string _FINAL_ in them. If you wish instead to find all files that have the string FINAL (*not* offest with underscores) in them, pass this script any parameter.


# CODE
# List ALL files, because the following command:
		# gfind . -type f -iregex '.*FINAL.*' > ___ALL_FINALS___.txt
		# -- results in listing files that include '.*FINAL.*' in the *path* but not the file name (as well as all that have it in the file name).
gfind . -type f > ___ALL_FINALS___.txt
# strip off paths, leaving only file names:
gsed -i 's/.*\///g' ___ALL_FINALS___.txt
# remove all listings that end with _MD_ADDS.txt:
gsed -i 's/.*_MD_ADDS.txt//g' ___ALL_FINALS___.txt
# remove any listing of ___ALL_FINALS___.txt if it existed before this script was executed:
gsed -i 's/___ALL_FINALS___.txt//g' ___ALL_FINALS___.txt
# remove all listings that do not include the phrase FINAL; thx to http://stackoverflow.com/a/8255627/1397555 :
# Block template: if no such parameter this, otherwise that:
if [ "$1" ]
	then	# if no paramater passed to script, search for .*FINAL.* :
		gsed -i -n 's/\(.*FINAL.*\)/\1/p' ___ALL_FINALS___.txt
	else	# if parameter passed to script, search for _FINAL_ :
		gsed -i -n 's/\(.*_FINAL_.*\)/\1/p' ___ALL_FINALS___.txt
fi

echo "DONE. Results are in ___ALL_FINALS___.txt."