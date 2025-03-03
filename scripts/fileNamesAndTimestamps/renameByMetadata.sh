# DESCRIPTION
# Renames many image, sound and video files (of many supported types, and in the current directory) after dateTimeOriginal and createDate metadata. As this is an irreversible process (unless you keep backups), it asks you to enter a password, which it presents to you, to continue. Identifies associated file names that have the same base name as a file after renaming (by using sha256sums to identify renamed files, remembering the previous file name), and rename them to the same new base file name.

# DEPENDENCIES
# ExifTool, awk, sha256sum

# USAGE
# Run from a directory with media files you wish to so rename, e.g.:
#    renameByMetadata.sh
# OR OPTIONALLY, to bypass the password check and rename all files by metadata without warning, run with one parameter $1, which is the word NORTHERP:
#    renameByMetadata.sh NORTHERP
# MOREOVER, to bypass attempt to rename any matching sidecards (as it can take a long time to identify the checksum of all files, and this is a waste of time if you know there are no sidecars), pass an optional third parameter $3, which can be anything, for example the word THANTHURB:
#    renameByMetadata.sh NORTHERP THANTHURB
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

# THIS PART mostly written by a large language model! (DeepSeek)
# Create an array to store the SHA256 checksums and filenames
declare -A file_checksums

# get checksums if no paramter $2 was passed
if [ ! "$2" ]
then
	# Get the SHA256 checksums for all files in the current directory
	for file in *; do
		if [ -f "$file" ]; then
			checksum=$(sha256sum "$file" | awk '{print $1}')
			file_checksums["$file"]="$checksum"
		fi
	done
fi
# END large language model writing

# renames all image formats in current directory which exiftool can; the %%-c does some magic that renames with a -<number> in case of duplicate file names. Can't seem to get it to format that way with anything other than a dash; uses a conditional like is given in this post: 
# https://exiftool.org/forum/index.php?topic=6519.msg32511#msg32511 -- but adding an -else clause:
exiftool -if "defined $CreateDate" -v -overwrite_original '-Filename<CreateDate' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" -else -v -overwrite_original '-Filename<DateTimeOriginal' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" *.*

# Create an array of all files in the directory
all_files=($(ls))

# Create an array to track renamed files
renamed_files=()

# use collected checksums to do sidecar etc. renaming if no paramter $2 was passed
if [ ! "$2" ]
# construct log file name including date and time
logFileName=$(date +"%Y%m%d_%H%M%S.%N_renameByMetadataLog.txt")
then
    echo "identifying sidecar etc. files by comparing sha256sum of renamed file and renaming files with a basename matching the original file's basename.."
    # THIS PART mostly written by a large language model! (DeepSeek)
    # Identify renamed files and update associated sidecar etc. files that have the same basename as the file before it was renamed:
	for old_file in "${!file_checksums[@]}"; do
		old_checksum="${file_checksums[$old_file]}"
		
		# Iterate over only the files that haven't been renamed yet
		for new_file in "${all_files[@]}"; do
			if [ -f "$new_file" ]; then
				new_checksum=$(sha256sum "$new_file" | awk '{print $1}')
				if [ "$new_checksum" == "$old_checksum" ] && [ "$new_file" != "$old_file" ]; then
					# Extract the base names (without extension)
					old_base=$(basename "$old_file" | cut -d. -f1)
					new_base=$(basename "$new_file" | cut -d. -f1)
					
                    # Rename associated sidecar or similarly associated files
					for sidecar_file in *; do
						if [ -f "$sidecar_file" ] && [[ "$sidecar_file" == "$old_base".* ]]; then
							new_sidecar_name="${sidecar_file/$old_base/$new_base}"
							mv "$sidecar_file" "$new_sidecar_name"
                            echo "Renamed sidecar etc. file: $sidecar_file -> $new_sidecar_name"
							echo "Renamed sidecar etc. file: $sidecar_file -> $new_sidecar_name" >> $logFileName
						fi
					done

					# Add the renamed file to the renamed_files array
					renamed_files+=("$new_file")
				fi
			fi
		done

		# Remove renamed files from the all_files array
		all_files=($(printf "%s\n" "${all_files[@]}" | grep -vFxf <(printf "%s\n" "${renamed_files[@]}")))
	done
fi
# END large language model writing