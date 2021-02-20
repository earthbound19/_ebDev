# DESCRIPTION
# Converts all files of type $1 in a directory tree to type $2, via pandoc (via pandoc2doc.sh). See documentation in comments of that script.

# USAGE
# Run with these parameters:
# - $1 source format of files to convert
# - $2 target format of files to convert
# Example that will convert all files of type .md (markdown) to .html (static web page) :
#    pandoc2doc.sh md docx


# CODE
if [ ! "$1" ]; then echo "No source format \$1 passed to script. Exit."; exit 1; else src_format=$1; fi
if [ ! "$2" ]; then echo "No destination format \$2 passed to script. Exit."; exit 1; else dest_format=$2; fi

# recurse through all directories under this path, and in each directory, convert all $1 (source) format files to $2 (destination format), then copy the timestamp of each source file to its file name match corresponding .txt file.
directories=( $(find . -type d -iname \*) )
for directory in ${directories[@]}
do
	pushd .
	cd $directory
	src_docs=( $(find . -maxdepth 1 -type f -iname \*.$src_format -printf '%f\n') )
	for src_doc in ${src_docs[@]}
	do
		file_name_no_ext=${src_doc%.*}
		dest_file="$file_name_no_ext".$dest_format
		# deprecated in favor of calling pandoc2doc (functionality of this moved into that script) : "pandoc -t $dest_format -o $dest_file $src_doc"
		pandoc2doc.sh $src_doc $dest_file
	done
	popd
done