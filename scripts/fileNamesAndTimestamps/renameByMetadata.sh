# WARNING: this script renames files without backup and without any prompt. For this reason everything under the CODE comment is left undone by an `exit` command which you must comment out to use the script (it will otherwise do nothing other than start and exit). Uncomment exit and save again when done with the script.

# DESCRIPTION
# Renames image files and .MOV and .mp4 files after dateTimeOriginal and createDate metadata, respectively.

# DEPENDENCY
# This script must be in your $PATH.

# USAGE
# Invoke from a directory with media files you wish to so rename, e.g.:
#  renameByMetadata.sh

# KNOWN ISSUES
# THIS MAY NOT PERFECTLY segregate by creation date metadata type; it potentially renames many files twice (first by creation date metadata, then dateTimeOriginal metadata). ALSO, for files from some sources mixed with others (something doing with dateTimeOriginal metadata in one jpg source and not another?) it may loop endlessly . . .

# REFERENCE
# https://gist.github.com/rjames86/33b9af12548adf091a26
# https://ninedegreesbelow.com/photography/exiftool-commands.html#rename

# UNRELATED REFERENCE
# https://sno.phy.queensu.ca/~phil/exiftool/filename.html

# TO DO
# Update all dateTimeOriginal metadata which lacks milliseconds by adding random milliseconds before the next line of code which appears later:
	# exiftool '-dateTimeOriginal<fileCreateDate' -if '(($dateTimeOriginal)) and ($filetype eq "JPEG")' .
# Exploit that given at this URL? : https://smarnach.github.io/pyexiftool/

# CODE
exit

# renames all image formats in current directory which exiftool decides to:
exiftool -v -overwrite_original '-Filename<${dateTimeOriginal}${subsecTimeOriginal;$_.=0 x(3-length)}.%e' -d "%Y_%m_%d__%H_%M_%S" .
# renames all .mov files in current directory:
exiftool -v -overwrite_original '-Filename<${createDate}.%e' -d "%Y_%m_%d__%H_%M_%S" *.MOV
# renames all .m4v files in current directory:
exiftool -v -overwrite_original '-Filename<${createDate}.%e' -d "%Y_%m_%d__%H_%M_%S" *.m4v
# It's important that these next commands are run last:
# rename all JPEG format files which lack a dateTimeOriginal metadata field by file creation date, with a %%c counter against any potential duplicate resulting file names (making unique file names where the time stamp is identical) ; re https://sno.phy.queensu.ca/~phil/exiftool/exiftool_pod.html#Advanced-formatting-feature :
# perl expressions can be done on tags in this format:
# ${TAG;EXPR}
# (e.g. ) ${-FileName;somePerlExprThatMakesRandomCharacters}
exiftool -v -overwrite_original '-FileName<FileCreateDate' -d %Y_%m_%d__%H_%M_%S__%%c.%%e -if '((not $dateTimeOriginal)) and ($filetype eq "JPEG")' .
# For all JPEG format files which lack a dateTimeOriginal field, create one from fileCreateDate:
exiftool -v -overwrite_original '-dateTimeOriginal<fileCreateDate' -if '(($dateTimeOriginal)) and ($filetype eq "JPEG")' .