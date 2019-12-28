# DESCRIPTION
# Converts all files of type $1 in a tree to type $2, via pandoc (a wrapper for pandoc). Copies respective timestamps from file types $1 to $2 (via cygin/'nix/mac touch command), so that each newly created (converted) document has the same time stamp.

# NOTES
# This script can alternately use binarez_touch on Windows to update file creation dates to match the source. See the OPTIONS comment in the source code below.

# USAGE
# pandoc2doc.sh source_docs_extension dest_docs_extension

if [ "$1" ]; then src_format=$1; echo "Source format \$1 $1 passed to script\; using that."; else echo "NO source format \$1 passed to script. Exiting."; exit; fi
if [ "$2" ]; then dest_format=$2; echo "Source format \$2 $2 passed to script\; using that."; else echo "NO destination format \$2 passed to script. Exiting."; exit; fi

# recurse through all directories under this path, and in each directory, convert all $1 (source) format files to $2 (destination format), then copy the timestamp of each source file to its file name match corresponding .txt file.
directories=(`gfind . -type d -iname \*`)
for directory in ${directories[@]}
do
	pushd .
	cd $directory
	src_docs=(`gfind . -maxdepth 1 -type f -iname \*.$src_format -printf '%f\n'`)
	for src_doc in ${src_docs[@]}
	do
		file_name_no_ext=${src_doc%.*}
		dest_file="$file_name_no_ext".$dest_format
		pandoc -t plain -o $dest_file $src_doc
			# OPTIONAL: to clear out start of line gobbledygook resulting from src_doc -> txt conversion, uncomment this next line:
			gsed -i 's/^[\{\}0-9 ;]\{1,\}//g' $dest_file
		# update the new docs' creation and modification file time stamps (windows) or just modification time stamp ('nix):
		# OPTIONS: on windows if you have binarez_touch, comment out the first line here, and uncomment the second. For 'nix platforms, do visa-versa:
		touch --reference="$src_doc" $dest_file
		binarez_touch -cmx "-r""$src_doc" $dest_file
	done
	popd
done