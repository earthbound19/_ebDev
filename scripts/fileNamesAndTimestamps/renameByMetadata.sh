# DESCRIPTION
read -p "NOTE that this script is, at this writing, a minimally tested
major refactor with an added feature. Please examine the comments and
proceed with caution if you accept this. To continue, press ENTER."
# Renames many image, sound and video files (of many supported types, and in the current directory)
# after dateTimeOriginal and createDate metadata.
# For files without metadata (including non-media files), falls back to using Windows filesystem
# CreationTime timestamp. This means ALL files in the current directory will be renamed either by
# their metadata or by filesystem timestamps.
# As this is an irreversible process (unless you keep backups), it requires password confirmation to continue.
# Identifies associated sidecar files that have the same base name as a file after renaming (by using
# sha256sums to identify renamed files, remembering the previous file name), and renames them to the
# same new base file name.

# DEPENDENCIES
# ExifTool, awk, sha256sum, stat

# USAGE
# Run from a directory with files you wish to rename (WARNING: ALL files in the directory will be renamed):
#    renameByMetadata.sh
#
# OPTIONS:
#    -p, --password <password>    Bypass confirmation prompt if password equals "NORTHERP"
#                                 If wrong password is provided, prompt will still appear
#    -n, --nosidecars             Skip sidecar file identification and renaming (faster)
#    -h, --help                   Show this help message
#
# EXAMPLES:
#    renameByMetadata.sh --password NORTHERP
#    renameByMetadata.sh --nosidecars
#    renameByMetadata.sh --password NORTHERP --nosidecars
#
# NOTES:
# - You can view all timestamp metadata in a file with this command:
#    exiftool -time:all -g1 -a -s <inputFileName.file>
# - This script renames ALL files in the current directory:
#    * Media files with metadata → renamed using CreateDate or DateTimeOriginal
#    * Files without metadata → renamed using Windows filesystem CreationTime
#    * Sidecar files (matching basenames) → renamed to match their associated media files
# - This is a list of all supported exiftool file types for which tags can be written,
#   obtained via the command `exiftool -listwf`:
#   360 3G2 3GP 3GP2 3GPP AAX AI AIT APNG ARQ ARW AVIF CIFF CR2 CR3 CRM CRW CS1 DCP DNG DR4 DVB EPS EPS2 EPS3 EPSF ERF EXIF EXV F4A F4B F4P F4V FFF FLIF GIF GPR HDP HEIC HEIF HIF ICC ICM IIQ IND INDD INDT INSP J2K JNG JP2 JPE JPEG JPF JPG JPM JPS JPX JXL JXR LRV M4A M4B M4P M4V MEF MIE MNG MOS MOV MP4 MPO MQV MRW NEF NKSC NRW ORF ORI PBM PDF PEF PGM PNG PPM PS PS2 PS3 PSB PSD PSDT QT RAF RAW RW2 RWL SR2 SRW THM TIF TIFF VRD WDP X3F XMP
# - Non-media files (text files, PDFs, etc.) without metadata will still be renamed using filesystem timestamps
#
# REFERENCE
# https://gist.github.com/rjames86/33b9af12548adf091a26
# https://ninedegreesbelow.com/photography/exiftool-commands.html#rename
# https://sno.phy.queensu.ca/~phil/exiftool/filename.html


# CODE
# TO DO:
# - add option to rename with postfix label (name / tag)?
# - add option to rename by extenson (-t --type)?
#   - with -a --all as a flag which conflicts with that if both are present, and alone operates on all file types?
# - adapt scripts that use this to new usage (fix their breaking change-reliant state)

# Function to show help
print_halp() {
    cat << EOF
Usage: $PROGNAME [OPTIONS]

Renames ALL files in the current directory based on metadata timestamps (for media files)
with fallback to filesystem creation time (for all files without metadata).

OPTIONS:
    -p, --password <password>    Bypass confirmation prompt if password equals "NORTHERP"
                                 If wrong password is provided, prompt will still appear
    -n, --nosidecars             Skip sidecar file identification and renaming (faster)
    -h, --help                   Show this help message

EXAMPLES:
    $PROGNAME --password NORTHERP
    $PROGNAME --nosidecars
    $PROGNAME --password NORTHERP --nosidecars

NOTES:
    - This script permanently renames ALL files in the current directory.
    - Always keep backups before running this script.
    - Media files with metadata are renamed using CreateDate or DateTimeOriginal.
    - Files without metadata (including non-media files) are renamed using Windows filesystem creation time.
    - Sidecar files (same basename, different extension) are renamed to match their associated media files.
EOF
}

# Function to check for empty optional argument (used by getopts)
check_space_in_opt_arg() {
    if [ "$2" == "" ]; then
        echo "ERROR: No value or a space (resulting in empty value) passed after optional switch $1."
        echo "Pass a value without any space after $1 (for example: $1""value\"\"), or if a default is available, don't pass $1, and the default will be used."
        exit 4
    fi
}

# Function to rename ANY file using filesystem creation time (fallback for files without metadata)
# This applies to ALL file types, not just media files
rename_with_creation_time() {
    local file="$1"
    local log_file="$2"
    
    # Get creation time using stat
    creation_time=$(stat --format="%w" "$file" 2>/dev/null)
    if [ -z "$creation_time" ]; then
        echo "WARNING: Could not get creation time for $file" | tee -a "$log_file"
        return 1
    fi
    
    # Parse date and time from stat output (format: "YYYY-MM-DD HH:MM:SS.ms timezone")
    date_part=$(echo "$creation_time" | awk '{print $1}')
    time_part=$(echo "$creation_time" | awk '{print $2}' | cut -d'.' -f1)
    
    # Extract components
    year=$(echo "$date_part" | cut -d'-' -f1)
    month=$(echo "$date_part" | cut -d'-' -f2)
    day=$(echo "$date_part" | cut -d'-' -f3)
    hour=$(echo "$time_part" | cut -d':' -f1)
    minute=$(echo "$time_part" | cut -d':' -f2)
    second=$(echo "$time_part" | cut -d':' -f3)
    
    # Format timestamp like exiftool does: YYYY_MM_DD__HH_MM_SS
    timestamp="${year}_${month}_${day}__${hour}_${minute}_${second}"
    
    # Get file extension
    extension="${file##*.}"
    if [ "$extension" = "$file" ]; then
        extension=""
    fi
    
    # Generate new filename with duplicate handling
    base_name="${timestamp}"
    counter=0
    while true; do
        if [ $counter -eq 0 ]; then
            if [ -n "$extension" ]; then
                new_name="${base_name}.${extension}"
            else
                new_name="${base_name}"
            fi
        else
            if [ -n "$extension" ]; then
                new_name="${base_name}-${counter}.${extension}"
            else
                new_name="${base_name}-${counter}"
            fi
        fi
        
        if [ ! -f "$new_name" ]; then
            break
        fi
        ((counter++))
    done
    
    # Rename the file
    if mv "$file" "$new_name" 2>/dev/null; then
        echo "Fallback rename: $file -> $new_name" | tee -a "$log_file"
        return 0
    else
        echo "ERROR: Failed to rename $file to $new_name" | tee -a "$log_file"
        return 1
    fi
}

# Get script name for getopt
PROGNAME=$(basename "$0")

# Parse command line arguments with getopt
OPTS=$(getopt -o hp:n --long help,password:,nosidecars -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi

eval set -- "$OPTS"

# Initialize variables
PASSWORD=""
NOSIDECARS=false

# Process arguments
while true; do
    case "$1" in
        -h | --help)
            print_halp
            exit 0
            ;;
        -p | --password)
            PASSWORD="$2"
            shift
            shift
            ;;
        -n | --nosidecars)
            NOSIDECARS=true
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done

# Notify if no arguments were passed (use defaults)
if [ ${#@} == 0 ] && [ -z "$PASSWORD" ] && [ "$NOSIDECARS" == false ]; then
    echo "No options provided. Continuing with default settings."
    echo ""
fi

# PASSWORD CHECK
# If --password was provided with correct value, bypass prompt
# If --password was provided with wrong value, still prompt
# If no --password, prompt
if [ "$PASSWORD" == "NORTHERP" ]; then
    echo "Password accepted. Bypassing confirmation prompt."
    echo ""
else
    if [ -n "$PASSWORD" ]; then
        echo "Incorrect password provided. Falling back to interactive prompt."
        echo ""
    fi
    
    echo ""
    echo "WARNING: THIS SCRIPT PERMANENTLY RENAMES ALL files in the current directory."
    echo "Media files with metadata are renamed after their creation metadata."
    echo "Files without metadata (including non-media files) are renamed after their"
    echo "Windows filesystem creation timestamp."
    echo ""
    echo "If this is what you want to do, type NORTHERP and then press <enter> (or <return>)."
    read -p "TYPE HERE: " SILLYWORD
    
    if ! [ "$SILLYWORD" == "NORTHERP" ]; then
        echo ""
        echo "Typing mismatch; exit."
        exit 1
    else
        echo "Continuing..."
        echo ""
    fi
fi

# Create log file name with date and time
logFileName=$(date +"%Y-%m-%d_%H-%M-%S.%N_renameByMetadataLog.txt")
echo "Log file: $logFileName"
echo "Starting rename process at $(date)" > "$logFileName"
echo "" >> "$logFileName"

# Capture initial file list and checksums for sidecar detection
declare -A file_checksums
echo "Calculating file checksums for sidecar detection..." | tee -a "$logFileName"

# Only calculate checksums if sidecar detection is enabled
if [ "$NOSIDECARS" != true ]; then
    for file in *; do
        if [ -f "$file" ]; then
            checksum=$(sha256sum "$file" | awk '{print $1}')
            file_checksums["$file"]="$checksum"
        fi
    done
    echo "Checksums calculated for ${#file_checksums[@]} files." | tee -a "$logFileName"
    echo "" >> "$logFileName"
fi

# Capture initial file list for fallback detection
initial_files=()
for file in *; do
    if [ -f "$file" ]; then
        initial_files+=("$file")
    fi
done
echo "Initial file count: ${#initial_files[@]}" >> "$logFileName"

# MAIN RENAME PASS - exiftool metadata-based rename
# This processes media files with metadata support
# Non-media files and files without metadata will be handled in fallback pass
echo "" | tee -a "$logFileName"
echo "Running exiftool metadata-based rename..." | tee -a "$logFileName"
echo "This may take a moment..." | tee -a "$logFileName"

# Renames all file types that exiftool can process
# Uses CreateDate if available, otherwise DateTimeOriginal
# %%-c handles duplicate filenames by adding -1, -2, etc.
exiftool -if "defined $CreateDate" -v -overwrite_original '-Filename<CreateDate' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" -else -v -overwrite_original '-Filename<DateTimeOriginal' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" *.* 2>&1 | tee -a "$logFileName"

echo "" | tee -a "$logFileName"
echo "Exiftool rename pass complete." | tee -a "$logFileName"

# FALLBACK RENAME PASS - for files that still have original names (no metadata)
# This handles ALL file types that weren't renamed by exiftool (including non-media files)
echo "" | tee -a "$logFileName"
echo "Checking for files that need fallback rename (no metadata)..." | tee -a "$logFileName"

fallback_count=0
for original_file in "${initial_files[@]}"; do
    # Check if the file still exists with its original name
    if [ -f "$original_file" ]; then
        echo "File not renamed by exiftool: $original_file" >> "$logFileName"
        
        # Attempt fallback rename using creation time
        if rename_with_creation_time "$original_file" "$logFileName"; then
            ((fallback_count++))
        fi
    fi
done

echo "" | tee -a "$logFileName"
echo "Fallback rename complete. Renamed $fallback_count file(s) using filesystem creation time." | tee -a "$logFileName"

# SIDECAR RENAME PASS - identify and rename associated sidecar files
if [ "$NOSIDECARS" == true ]; then
    echo "" | tee -a "$logFileName"
    echo "Sidecar detection skipped (--nosidecars flag provided)." | tee -a "$logFileName"
else
    echo "" | tee -a "$logFileName"
    echo "Identifying sidecar files by comparing sha256sums..." | tee -a "$logFileName"
    
    # Get current list of all files
    all_files=($(ls))
    
    # Create an array to track renamed files
    renamed_files=()
    
    # Identify renamed files and update associated sidecar files
    for old_file in "${!file_checksums[@]}"; do
        old_checksum="${file_checksums[$old_file]}"
        
        # Iterate over files that haven't been renamed yet
        for new_file in "${all_files[@]}"; do
            if [ -f "$new_file" ]; then
                new_checksum=$(sha256sum "$new_file" | awk '{print $1}')
                if [ "$new_checksum" == "$old_checksum" ] && [ "$new_file" != "$old_file" ]; then
                    # Extract the base names (without extension)
                    old_base=$(basename "$old_file" | sed 's/\.[^.]*$//')
                    new_base=$(basename "$new_file" | sed 's/\.[^.]*$//')
                    
                    # Rename associated sidecar or similarly associated files
                    for sidecar_file in *; do
                        if [ -f "$sidecar_file" ] && [[ "$sidecar_file" == "$old_base".* ]]; then
                            new_sidecar_name="${sidecar_file/$old_base/$new_base}"
                            if mv "$sidecar_file" "$new_sidecar_name" 2>/dev/null; then
                                echo "Renamed sidecar file: $sidecar_file -> $new_sidecar_name" | tee -a "$logFileName"
                            else
                                echo "ERROR: Failed to rename sidecar file: $sidecar_file -> $new_sidecar_name" | tee -a "$logFileName"
                            fi
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
    
    echo "Sidecar detection complete." | tee -a "$logFileName"
fi

# Final summary
echo "" | tee -a "$logFileName"
echo "========================================" | tee -a "$logFileName"
echo "RENAME PROCESS COMPLETE" | tee -a "$logFileName"
echo "========================================" | tee -a "$logFileName"
echo "Log file: $logFileName" | tee -a "$logFileName"
echo "" | tee -a "$logFileName"
echo "DONE. See $logFileName for details on renames and / or any failures."
echo "NOTE: to rename result files with a tag by extension, for example"
echo "if you have files named like 2026_03_22__09_53_28.jpg, you can"
echo "rename them all to have an identifying tag with a command like this:"
echo 'for f in *.jpg; do mv "$f" "${f%.jpg}_Seractal.jpg"; done'
echo "-- which will rename them like this: 2026_03_22__09_53_28_Seractal.jpg"

# Exit successfully
exit 0