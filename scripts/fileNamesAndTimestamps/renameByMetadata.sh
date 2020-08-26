# DESCRIPTION
# Renames image files and .MOV and .mp4 files after dateTimeOriginal and createDate metadata, respectively. As this is an irreversible process (unless you keep backups), it asks you to enter a password (which it presents to you) to continue.

# USAGE
# Run from a directory with media files you wish to so rename, e.g.:
#    renameByMetadata.sh
# KNOWN ISSUES
# THIS MAY NOT PERFECTLY segregate by creation date metadata type; it potentially renames many files twice (first by creation date metadata, then dateTimeOriginal metadata). ALSO, for files from some sources mixed with others (something doing with dateTimeOriginal metadata in one jpg source and not another?) it may loop endlessly . . .


# CODE
# TO DO
# Update all dateTimeOriginal metadata which lacks milliseconds by adding random milliseconds before the next line of code which appears later:
	# exiftool '-dateTimeOriginal<fileCreateDate' -if '(($dateTimeOriginal)) and ($filetype eq "JPEG")' .
# Exploit that given at this URL? : https://smarnach.github.io/pyexiftool/
#
# REFERENCE
# https://gist.github.com/rjames86/33b9af12548adf091a26
# https://ninedegreesbelow.com/photography/exiftool-commands.html#rename
#
# UNRELATED REFERENCE
# https://sno.phy.queensu.ca/~phil/exiftool/filename.html

echo ""
echo "WARNING: THIS SCRIPT PERMANENTLY BLANKS all files in the current directory, and all subdirectories (changes them to 0 bytes long). If this is what you want to do, type NORTHERP and then press <enter> (or <return>)."
read -p "TYPE HERE: " SILLYWORD

if ! [ "$SILLYWORD" == "NORTHERP" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi

# renames all image formats in current directory which exiftool decides to:
exiftool -v -overwrite_original '-Filename<${dateTimeOriginal}${subsecTimeOriginal;$_.=0 x(3-length)}.%e' -d "%Y_%m_%d__%H_%M_%S" .
# renames all .mov files in current directory:
exiftool -v -overwrite_original '-Filename<${createDate}.%e' -d "%Y_%m_%d__%H_%M_%S" *.MOV
# renames all .m4v files in current directory:
exiftool -v -overwrite_original '-Filename<${createDate}.%e' -d "%Y_%m_%d__%H_%M_%S" *.m4v
# It's important that these next commands are run last:
# rename all JPEG format files which lack a dateTimeOriginal metadata field by file creation date, with a %%c counter against any potential duplicate resulting file names (making unique file names where the time stamp is identical) ; re https://sno.phy.queensu.ca/~phil/exiftool/exiftool_pod.html#Advanced-formatting-feature :
# Perl expressions can be done on tags in this format:
# ${TAG;EXPR}
# (e.g. ) ${-FileName;somePerlExprThatMakesRandomCharacters}
exiftool -v -overwrite_original '-FileName<FileCreateDate' -d %Y_%m_%d__%H_%M_%S__%%c.%%e -if '((not $dateTimeOriginal)) and ($filetype eq "JPEG")' .
# For all JPEG format files which lack a dateTimeOriginal field, create one from fileCreateDate:
exiftool -v -overwrite_original '-dateTimeOriginal<fileCreateDate' -if '(($dateTimeOriginal)) and ($filetype eq "JPEG")' .