# DESCRIPTION
# Renames many image, sound and video files (of many supported types, and in the current directory) after dateTimeOriginal and createDate metadata. As this is an irreversible process (unless you keep backups), it asks you to enter a password, which it presents to you, to continue.

# DEPENDENCIES
# ExifTool

# USAGE
# Run from a directory with media files you wish to so rename, e.g.:
#    renameByMetadata.sh
# OR OPTIONALLY, to bypass the password check and rename all files by metadata without warning, run with one parameter, which is the word NORTHERP:
#    renameByMetadata.sh NORTHERP
# NOTES
# - You can view all timestamp metadata in a file with this command; you would replace `<inputFileName.file>` with an actual source file name you want to get the metadata for:
#    exiftool -time:all -g1 -a -s <inputFileName.file>
# - This is a list of all supported exiftool file types for which tags can be written, obtained via the command `exiftool -listwf`: 360 3G2 3GP 3GP2 3GPP AAX AI AIT APNG ARQ ARW AVIF CIFF CR2 CR3 CRM CRW CS1 DCP DNG DR4 DVB EPS EPS2 EPS3 EPSF ERF EXIF EXV F4A F4B F4P F4V FFF FLIF GIF GPR HDP HEIC HEIF HIF ICC ICM IIQ IND INDD INDT INSP J2K JNG JP2 JPE JPEG JPF JPG JPM JPS JPX JXL JXR LRV M4A M4B M4P M4V MEF MIE MNG MOS MOV MP4 MPO MQV MRW NEF NKSC NRW ORF ORI PBM PDF PEF PGM PNG PPM PS PS2 PS3 PSB PSD PSDT QT RAF RAW RW2 RWL SR2 SRW THM TIF TIFF VRD WDP X3F XMP

# CODE
# TO DO
# - Update all dateTimeOriginal metadata which lacks milliseconds by adding random milliseconds before the next line of code which appears later? As in:
	# exiftool '-dateTimeOriginal<fileCreateDate' -if '(($dateTimeOriginal)) and ($filetype eq "JPEG")' .
# REFERENCE
# https://gist.github.com/rjames86/33b9af12548adf091a26
# https://ninedegreesbelow.com/photography/exiftool-commands.html#rename
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

# renames all image formats in current directory which exiftool can; the %%-c does some magic that renames with a -<number> in case of duplicate file names. Can't seem to get it to format that way with anything other than a dash; uses a conditional like is given in this post: 
# https://exiftool.org/forum/index.php?topic=6519.msg32511#msg32511 -- but adding an -else clause:
exiftool -if "defined $CreateDate" -v -overwrite_original '-Filename<CreateDate' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" -else -v -overwrite_original '-Filename<DateTimeOriginal' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" *.*

# DEV NOODLING: attempt to rename sidecars and other files with the same base filename when you rename a master such as a raw (e.g. cr2) file: re: https://exiftool.org/forum/index.php?topic=9423.0 -- this command works IF there's metadata in both files (source raw and xmp sidecar) identifying them as a pair! :
# exiftool -V -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" '-FileName<${DateTimeOriginal}' .