# DESCRIPTION
# Renames many image, sound and video files (of many supported types, and in the current directory) after dateTimeOriginal and createDate metadata. As this is an irreversible process (unless you keep backups), it asks you to enter a password, which it presents to you, to continue.

# DEPENDENCIES
# ExifTool

# USAGE
# Run from a directory with media files you wish to so rename, e.g.:
#    renameByMetadata.sh
# OR OPTIONALLY run with one parameter, which is the word NORTHERP:
#    renameByMetadata.sh NORTHERP
# -- to bypass the password check and rename all files by metadata without warning.
# KNOWN ISSUES
# - THIS MAY NOT PERFECTLY split by creation date metadata type; it potentially renames many files twice (first by creation date metadata, then dateTimeOriginal metadata). ALSO, for files from some sources mixed with others (something doing with dateTimeOriginal metadata in one jpg source and not another?) it may loop endlessly . . .
# - It may miss files that have uppercase letters in their extensions. To lowercase all those, see `toLowercaseExtensions.sh`.


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

# Allow to override prompt for password to continue by parsing $1; assign $1 to SILLYWORD, and if it equals "NORTHERP", a later check will pass and the remainder of the script will execute. Otherwise the check will fail and the script will exit.
if [ "$1" != "NORTHERP" ]
then
	echo ""
	echo "WARNING: THIS SCRIPT PERMANENTLY RENAMES as many files as it can in the current directory, for many image types and all .m4a, .mov and .mp4 video files. It renames them after what creation metadata it can find. If this is what you want to do, type NORTHERP and then press <enter> (or <return>)."
	read -p "TYPE HERE: " SILLYWORD

	if ! [ "$SILLYWORD" == "NORTHERP" ]
	then
		echo ""
		echo Typing mismatch\; exit.
		exit
	else
		echo continuing . .
	fi
fi

# renames all image formats in current directory which exiftool decides to:
# q. on DateTimeOriginal vs. CreateDate (I had previously used the latter) answered here: DateTimeOriginal;
# the %%-c does some magic that renames with a -<number> in case of duplicate file names. Can't seem to get it to format that way with anything other than a dash:
exiftool -v -overwrite_original '-Filename<DateTimeOriginal' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" .

# BONEYARD: APPARENTLY UNECESSARY CODE, which may have been developed when the above was in a broken state (it's fixed now) and so I thought it just wasn't working for video and audio files, but I was just using unsupported (?) tag names:
# renames many video format files in current directory:
#allVideoFileNames=($(printAllVideoFileNames.sh))
#for fileName in ${allVideoFileNames[@]}
#do
#	exiftool -v -overwrite_original '-Filename<DateTimeOriginal' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" $fileName
#done
# renames many sound format files in the current directory:
#allSoundFileNames=($(printAllSoundFileNames.sh))
#for fileName in ${allSoundFileNames[@]}
#do
#	exiftool -v -overwrite_original '-Filename<DateTimeOriginal' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" $fileName
#done


# OPTIONAL:
# It's important that these next commands are run last:
# rename all JPEG format files which lack a dateTimeOriginal metadata field by file creation date, with a %%c counter against any potential duplicate resulting file names (making unique file names where the time stamp is identical) ; re https://sno.phy.queensu.ca/~phil/exiftool/exiftool_pod.html#Advanced-formatting-feature :
# Perl expressions can be done on tags in this format:
# ${TAG;EXPR}
# (e.g. ) ${-FileName;somePerlExprThatMakesRandomCharacters}
# BUT THIS IS DEPRECATED, as this could get screwed up metadata if files have been copied accross file systems and therefore had their original fileCreateDate (operating system create date) modified beyond the actual origin date of the file; moreover this defies this script's expectation of "rename by metadata," because it uses file system data, not metadata in the file:
# exiftool -v -overwrite_original '-FileName<FileCreateDate' -d %Y_%m_%d__%H_%M_%S__%%c.%%e -if '((not $dateTimeOriginal)) and ($filetype eq "JPEG")' .
# ALSO DEPRECATED, as this could get screwed up metadata if files have been copied accross file systems and therefore had their original fileCreateDate (operating system create date) modified beyond the actual origin date of the file; also, don't I need a "not" in that (()) conditional? : for all JPEG format files which lack a dateTimeOriginal field, create one from fileCreateDate:
# exiftool -v -overwrite_original '-dateTimeOriginal<fileCreateDate' -if '(($dateTimeOriginal)) and ($filetype eq "JPEG")' .
# NOTE: to reverse this if you did this erroneously, you may use something like:
# exiftool -overwrite_original '-DateTimeOriginal<ModifyDate' *.jpg
# -- or any other field that will will work and is correct after the <.