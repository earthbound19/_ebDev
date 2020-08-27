# DESCRIPTION
# Pandoc wrapper. Converts source document $1 to target document $2 via pandoc. Also copies respective timestamps from source file to target (via cygin/'nix/mac touch command, and binarez_touch on Windows), so that each newly created (converted) document has the same time stamp.

# USAGE
# Run with these parameters:
# - $1 Source document to convert
# - $2 Target document to convert to
# Example that would convert an input file README.md to README.odt:
#    pandoc2doc.sh source.md README.odt
# KNOWN ISSUES
# Pandoc doesn't know how to write all formats that can be contrived by simply passing the file extension as a parameter to -t, as this script does.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of source document to convert) passed to script. Exit."; exit 1; else srcFileName=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (target document file name to convert to) passed to script. Exit."; exit 1; else targetFileName=$2; fi

destFormat=${targetFileName##*.}
pandoc -t $destFormat -o $targetFileName $srcFileName

	# OPTIONAL: to clear out start of line gobbledygook resulting from src_doc -> txt conversion, uncomment this next line:
	# sed -i 's/^[\{\}0-9 ;]\{1,\}//g' $dest_file
# update the new docs' creation and modification file time stamps (windows) or just modification time stamp ('nix):
touch --reference="$srcFileName" $targetFileName
# OPTION: on windows if you have binarez_touch, comment out the first line here, and uncomment the second. For 'nix platforms, do visa-versa:
binarez_touch -cmx "-r""$srcFileName" $targetFileName