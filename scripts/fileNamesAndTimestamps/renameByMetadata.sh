#!/bin/bash
# renameByMetadata.sh - Rename ONE file using metadata timestamps
# 
# DESCRIPTION
# Renames a single file (and optionally its sidecar files) based on metadata
# timestamps (DateTimeOriginal or CreateDate) with fallback to filesystem
# timestamps (creation time, then modification time) ONLY if --allow-rename-by-file-time is specified.
#
# By default, filesystem timestamps are NOT used as a fallback to prevent
# inaccurate renaming based on unreliable filesystem metadata.
#
# Sidecar files are identified by matching basename BEFORE any rename occurs,
# then renamed to match the new basename.
#
# After successful rename, the new filenames are automatically appended to
# rename_excludes.txt in the current working directory to prevent re-processing
# in future runs. This behavior can be disabled with --no-auto-exclude.
#
# EXCLUDE LIST
# See 'renameByMetadata.sh --help' for exclude list documentation.
#
# DEPENDENCIES
# ExifTool, stat
#
# USAGE
print_help() {
    cat << EOF
$PROGNAME - Rename a single file based on metadata timestamps

Usage: $PROGNAME [OPTIONS] <filename>

OPTIONS:
    -y, --yes               Skip confirmation prompt
    -d, --dry-run           Show what would happen without renaming
    -v, --verbose           Verbose output
    --no-sidecars           Skip sidecar file renaming
    --no-auto-exclude       Skip auto-adding renamed files to exclude list
    -a, --allow-rename-by-file-time
                            Allow fallback to filesystem timestamps (creation time,
                            then modification time) if no metadata timestamp found.
                            WARNING: Filesystem timestamps can be inaccurate!
    -b, --bypass-metadata-check
                            Skip metadata examination entirely and attempt rename using
                            filesystem timestamps. Enables --allow-rename-by-file-time.
                            Use this when you know files have no metadata and want
                            to save processing time by skipping exiftool checks.
    -h, --help              Show this help

EXAMPLES:
    $PROGNAME -y DSC_0001.NEF
    $PROGNAME --dry-run --verbose video.mp4
    $PROGNAME --no-sidecars document.pdf
    $PROGNAME --allow-rename-by-file-time old_photo.jpg
    $PROGNAME --bypass-metadata-check old_photo.jpg

EXCLUDE LIST:
    To exclude files from renaming, list them in rename_excludes.txt files.
    
    - a rename_excludes.txt file anywhere in the directory tree that this
      script works on will affect all files in the whole tree:
      - parent directory exclude files apply to all child directories
      - child directory exclude files add to parent excludes
    - lines starting with '#' are ignored
    - exact matches only (file name detection is case-sensitive)
    - one filename per line (base name + extension only) in the file, for example:
        # in a rename_excludes.txt:
        crying_while_eating.jpg
        crescent_fresh.png
    
    - After successful rename, new filenames are automatically added to
      rename_excludes.txt in the current working directory, wrapped in
      # === START renameByMetadata.sh auto-add === markers.
    
    Examples:
        # in /photos/rename_excludes.txt:
        that_one_time_Rey_whooped_Kylos_hinie.jpg
        precious_memories_with_Darth_Maul.png
        
        # in /photos/2024/wedding/rename_excludes.txt:
        DSC_VIP.JPG        # Excludes just this one VIP photo

NOTES:
    - sidecar discovery is done for ALL files in same directory with matching basename
    - file system timestamp fallback is an active-opt in option (DISABLED by default)
      to prevent inaccurate renaming based on unreliable filesystem metadata. To enable
      renaming by file system time stamps, pass the switch --allow-rename-by-file-time,
	  or use:
    - --bypass-metadata-check enables renaming by timestamps and skips all exiftool
	  checks for faster processing
    - rename collisions get suffixes to make the file names unique: -1, -2, etc.
    - exits with error if new filename exceeds 240 characters
    - logs to rename_by_metadata.log in current directory
    - auto-exclude prevents re-renaming already-processed files
    - data can be set up to test this script (or the wrapper that
      calls it, renameAllTypeByMetadata.sh) with makeRNDtestFilesTree.sh

EOF
}

# CODE
# TO DO: flag to bypass metadata check and go straight to file system time stamp (to work more efficiently in cases where it is known metatada will not be found for any of the processed files), with any conflicting switch checks and errors that would apply

# 

PROGNAME=$(basename "$0")
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Log file global name
LOG_FILE="rename_by_metadata.log"

# If PARALLEL_TEMP_LOG is set, use it instead (for batch collection in renameAllTypeByMetadata.sh)
if [ -n "$PARALLEL_TEMP_LOG" ]; then
    LOG_FILE="$PARALLEL_TEMP_LOG"
fi

# Default values
YES_MODE=false
DRY_RUN=false
VERBOSE=false
NO_SIDECARS=false
NO_AUTO_EXCLUDE=false
ALLOW_FS_FALLBACK=false
BYPASS_METADATA=false
TARGET_FILE=""

# Color codes for output (if terminal supports)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message" >&2
            echo "[$timestamp] ERROR: $message" >> "$LOG_FILE"
            ;;
        WARNING)
            echo -e "${YELLOW}[WARNING]${NC} $message" >&2
            echo "[$timestamp] WARNING: $message" >> "$LOG_FILE"
            ;;
        INFO)
            echo "$message" >&2
            echo "[$timestamp] INFO: $message" >> "$LOG_FILE"
            ;;
        VERBOSE)
            if [ "$VERBOSE" = true ]; then
                echo -e "${GREEN}[VERBOSE]${NC} $message" >&2
            fi
            echo "[$timestamp] VERBOSE: $message" >> "$LOG_FILE"
            ;;
        *)
            echo "$message" >&2
            echo "[$timestamp] $message" >> "$LOG_FILE"
            ;;
    esac
}

# Global exclude patterns collected once per run
declare -a GLOBAL_EXCLUDE_PATTERNS=()

# Build global exclude list by scanning all directories for rename_excludes.txt
build_global_exclude_list() {
    local start_dir="$1"
    
    log "VERBOSE" "Building global exclude list from: $start_dir"
    
    # Find all rename_excludes.txt files in the tree
    while IFS= read -r exclude_file; do
        log "VERBOSE" "Found exclude file: $exclude_file"
        
        while IFS= read -r line || [ -n "$line" ]; do
            # Strip inline comments (anything after # including the space)
            line="${line%%#*}"
            # Trim whitespace
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            # Skip empty lines
            [[ -z "$line" ]] && continue
            
            GLOBAL_EXCLUDE_PATTERNS+=("$line")
            log "VERBOSE" "  Added global exclude: $line"
        done < "$exclude_file"
    done < <(find "$start_dir" -type f -name "rename_excludes.txt" 2>/dev/null)
    
    # Remove duplicates
    if [ ${#GLOBAL_EXCLUDE_PATTERNS[@]} -gt 0 ]; then
        local -A seen
        local unique=()
        for pattern in "${GLOBAL_EXCLUDE_PATTERNS[@]}"; do
            if [ -z "${seen[$pattern]}" ]; then
                seen[$pattern]=1
                unique+=("$pattern")
            fi
        done
        GLOBAL_EXCLUDE_PATTERNS=("${unique[@]}")
        log "VERBOSE" "Global exclude patterns (${#GLOBAL_EXCLUDE_PATTERNS[@]} unique): ${GLOBAL_EXCLUDE_PATTERNS[*]}"
    else
        log "VERBOSE" "No global exclude patterns found"
    fi
}

# Check if file should be excluded (uses global list)
is_excluded() {
    local file="$1"
    local basename_file=$(basename "$file")
    
    for pattern in "${GLOBAL_EXCLUDE_PATTERNS[@]}"; do
        if [ "$basename_file" = "$pattern" ]; then
            log "INFO" "File excluded by global pattern: $basename_file"
            return 0
        fi
    done
    
    return 1
}

# Add successfully renamed files to auto-exclude list
add_to_auto_exclude() {
    local new_filenames=("$@")
    
    # Skip if disabled or dry-run
    if [ "$NO_AUTO_EXCLUDE" = true ] || [ "$DRY_RUN" = true ]; then
        return 0
    fi
    
    local auto_exclude_file="$PWD/rename_excludes.txt"
    local start_marker="# === START renameByMetadata.sh auto-add to prevent more renames! ==="
    local end_marker="# === END renameByMetadata.sh auto-add to prevent more renames! ==="
    
    # If file doesn't exist, create it with markers
    if [ ! -f "$auto_exclude_file" ]; then
        {
            echo "$start_marker"
            for filename in "${new_filenames[@]}"; do
                echo "$filename"
                log "VERBOSE" "Added to auto-exclude: $filename"
            done
            echo "$end_marker"
        } > "$auto_exclude_file"
        return 0
    fi
    
    # Check if markers already exist
    if grep -q "^$start_marker$" "$auto_exclude_file"; then
        # Extract content between markers (excluding empty lines)
        local existing_content=$(sed -n "/^$start_marker$/,/^$end_marker$/p" "$auto_exclude_file" | tail -n +2 | head -n -1 | grep -v '^$')
        
        # Build new content between markers (each filename on its own line)
        local new_content=""
        for filename in "${new_filenames[@]}"; do
            if ! echo "$existing_content" | grep -qFx "$filename"; then
                new_content="${new_content}${filename}"$'\n'
                log "VERBOSE" "Added to auto-exclude: $filename"
            fi
        done
        
        # If there are new files, update the file
        if [ -n "$new_content" ]; then
            # Remove old marker section and insert new one
            local temp_file=$(mktemp)
            # Copy everything before start marker
            sed -n "1,/^$start_marker$/p" "$auto_exclude_file" | head -n -1 > "$temp_file"
            # Write start marker
            echo "$start_marker" >> "$temp_file"
            # Write existing content (if any) with newline
            if [ -n "$existing_content" ]; then
                echo "$existing_content" >> "$temp_file"
            fi
            # Write new content (already has newline from $'\n')
            echo -n "$new_content" >> "$temp_file"
            # Write end marker
            echo "$end_marker" >> "$temp_file"
            # Copy everything after end marker
            sed -n "/^$end_marker$/,\$p" "$auto_exclude_file" | tail -n +2 >> "$temp_file"
            mv "$temp_file" "$auto_exclude_file"
        fi
    else
        # No markers yet, append new section to end of file
        {
            echo ""
            echo "$start_marker"
            for filename in "${new_filenames[@]}"; do
                echo "$filename"
                log "VERBOSE" "Added to auto-exclude: $filename"
            done
            echo "$end_marker"
        } >> "$auto_exclude_file"
    fi
}

get_timestamp_from_metadata() {
    local file="$1"
    local timestamp=""
    
    log "VERBOSE" "Checking exiftool metadata for $file"
    
    # Try CreateDate first, then DateTimeOriginal
    timestamp=$(exiftool -d "%Y_%m_%d__%H_%M_%S" \
        -if 'defined $CreateDate' -p '$CreateDate' \
        -else -p '$DateTimeOriginal' \
        "$file" 2>/dev/null | head -1)
    
    if [ -n "$timestamp" ]; then
        log "VERBOSE" "Metadata timestamp found: $timestamp"
        echo "$timestamp"
        return 0
    fi
    
    log "VERBOSE" "No metadata timestamp found"
    return 1
}

get_timestamp_from_filesystem() {
    local file="$1"
    local timestamp=""
    
    log "VERBOSE" "Checking filesystem timestamps for $file"
    
    # Try creation time first
    local fs_time=$(stat --format="%w" "$file" 2>/dev/null)
    if [ -z "$fs_time" ] || [ "$fs_time" = "-" ]; then
        log "VERBOSE" "No creation time available, using modification time"
        fs_time=$(stat --format="%y" "$file" 2>/dev/null)
    fi
    
    if [ -n "$fs_time" ] && [ "$fs_time" != "-" ]; then
        # Format: 2024-01-01 12:00:00.123456789 +0000
        # Extract date and time parts
        local date_part=$(echo "$fs_time" | awk '{print $1}')
        local time_part=$(echo "$fs_time" | awk '{print $2}' | cut -d'.' -f1)
        
        # Replace hyphens with underscores, colons with underscores
        timestamp="${date_part//-/_}__${time_part//:/_}"
        log "VERBOSE" "Filesystem timestamp found: $timestamp"
        echo "$timestamp"
        return 0
    fi
    
    log "ERROR" "Could not get any filesystem timestamp for $file"
    return 1
}

get_unique_filename() {
    local base="$1"
    local ext="$2"
    local counter=0
    local result
    
    while true; do
        if [ $counter -eq 0 ]; then
            if [ -n "$ext" ]; then
                result="${base}.${ext}"
            else
                result="${base}"
            fi
        else
            if [ -n "$ext" ]; then
                result="${base}-${counter}.${ext}"
            else
                result="${base}-${counter}"
            fi
        fi
        
        if [ ! -f "$result" ]; then
            echo "$result"
            return 0
        fi
        log "VERBOSE" "Filename collision: $result exists, trying counter $((counter+1))"
        ((counter++))
    done
}

check_filename_length() {
    local filename="$1"
    local max_length=240  # Leave room for path components (260-20)
    
    if [ ${#filename} -gt $max_length ]; then
        log "ERROR" "New filename exceeds $max_length characters: $filename"
        log "ERROR" "Length: ${#filename} (max: $max_length)"
        return 1
    fi
    return 0
}

rename_with_sidecars() {
    local file="$1"
    local new_basename="$2"
    local -a renamed_filenames=()
    
    local old_dir=$(dirname "$file")
    local old_basename=$(basename "$file")
    local old_name_no_ext="${old_basename%.*}"
    local old_extension="${old_basename##*.}"
    
    # Handle files with no extension
    if [ "$old_name_no_ext" = "$old_basename" ]; then
        old_extension=""
    fi
    
    log "INFO" "Original file: $old_basename"
    log "INFO" "Target basename: $new_basename"
    
    # Discover sidecars BEFORE rename (by basename), excluding any excluded files
    local sidecars=()
    if [ "$NO_SIDECARS" != true ]; then
        log "INFO" "Discovering sidecar files for basename: $old_name_no_ext"
        for f in "$old_dir"/*; do
            if [ -f "$f" ]; then
                local f_basename=$(basename "$f")
                local f_name_no_ext="${f_basename%.*}"
                
                # Skip the target file itself
                if [ "$f_basename" = "$old_basename" ]; then
                    continue
                fi
                
                # Skip if this sidecar is in exclude list
                if is_excluded "$f"; then
                    log "VERBOSE" "Skipping excluded sidecar: $f_basename"
                    continue
                fi
                
                # Check if basename matches (potential sidecar)
                if [ "$f_name_no_ext" = "$old_name_no_ext" ]; then
                    sidecars+=("$f")
                    log "VERBOSE" "Found sidecar: $f_basename"
                fi
            fi
        done
        log "INFO" "Found ${#sidecars[@]} sidecar file(s)"
    fi
    
    # Generate new filename for main file (preserving directory)
    local new_filename="$old_dir/$(get_unique_filename "$new_basename" "$old_extension")"
    log "VERBOSE" "New filename generated: $new_filename"
    
    # Check path length
    check_filename_length "$(basename "$new_filename")" || return 1
    
    # Dry run mode - just report
    if [ "$DRY_RUN" = true ]; then
        log "INFO" "[DRY RUN] Would rename: $old_basename -> $(basename "$new_filename")"
        for sidecar in "${sidecars[@]}"; do
            local sidecar_basename=$(basename "$sidecar")
            local sidecar_name_no_ext="${sidecar_basename%.*}"
            local sidecar_ext="${sidecar_basename##*.}"
            if [ "$sidecar_name_no_ext" = "$sidecar_basename" ]; then
                sidecar_ext=""
            fi
            local new_sidecar_name="$old_dir/$(get_unique_filename "$new_basename" "$sidecar_ext")"
            log "INFO" "[DRY RUN] Would rename sidecar: $sidecar_basename -> $(basename "$new_sidecar_name")"
        done
        return 0
    fi
    
    # Confirm if not in yes mode
    if [ "$YES_MODE" != true ]; then
        echo ""
        echo -e "${YELLOW}WARNING: This will rename the following files:${NC}"
        echo "  Main:   $old_basename -> $(basename "$new_filename")"
        if [ ${#sidecars[@]} -gt 0 ]; then
            echo "  Sidecars:"
            for sidecar in "${sidecars[@]}"; do
                local sidecar_basename=$(basename "$sidecar")
                local sidecar_name_no_ext="${sidecar_basename%.*}"
                local sidecar_ext="${sidecar_basename##*.}"
                if [ "$sidecar_name_no_ext" = "$sidecar_basename" ]; then
                    sidecar_ext=""
                fi
                local new_sidecar_name="$old_dir/$(get_unique_filename "$new_basename" "$sidecar_ext")"
                echo "    $sidecar_basename -> $(basename "$new_sidecar_name")"
            done
        fi
        echo ""
        read -p "Proceed with rename? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "INFO" "Rename cancelled by user"
            return 1
        fi
    fi
    
    # Perform the rename
    log "INFO" "Renaming main file: $old_basename -> $(basename "$new_filename")"
    if ! mv "$file" "$new_filename" 2>/dev/null; then
        log "ERROR" "Failed to rename main file: $file -> $new_filename"
        return 1
    fi
    renamed_filenames+=("$(basename "$new_filename")")
    
    # Rename sidecars
    local renamed_count=0
    for sidecar in "${sidecars[@]}"; do
        local sidecar_basename=$(basename "$sidecar")
        local sidecar_name_no_ext="${sidecar_basename%.*}"
        local sidecar_ext="${sidecar_basename##*.}"
        if [ "$sidecar_name_no_ext" = "$sidecar_basename" ]; then
            sidecar_ext=""
        fi
        
        local new_sidecar_name="$old_dir/$(get_unique_filename "$new_basename" "$sidecar_ext")"
        log "INFO" "Renaming sidecar: $sidecar_basename -> $(basename "$new_sidecar_name")"
        
        if mv "$sidecar" "$new_sidecar_name" 2>/dev/null; then
            renamed_filenames+=("$(basename "$new_sidecar_name")")
            ((renamed_count++))
        else
            log "ERROR" "Failed to rename sidecar: $sidecar_basename"
        fi
    done
    
    log "INFO" "Successfully renamed $renamed_count of ${#sidecars[@]} sidecar(s)"
    
    # Add all renamed files to auto-exclude list
    if [ ${#renamed_filenames[@]} -gt 0 ]; then
        add_to_auto_exclude "${renamed_filenames[@]}"
    fi
    
    return 0
}

# Parse command line arguments
TEMP=$(getopt -o ydvhab --long yes,dry-run,verbose,no-sidecars,no-auto-exclude,allow-rename-by-file-time,bypass-metadata-check,help -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options" >&2
    exit 1
fi

eval set -- "$TEMP"

while true; do
    case "$1" in
        -y|--yes)
            YES_MODE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -a|--allow-rename-by-file-time)
            ALLOW_FS_FALLBACK=true
            shift
            ;;
        -b|--bypass-metadata-check)
            BYPASS_METADATA=true
            ALLOW_FS_FALLBACK=true  # Implicitly enable filesystem fallback
            shift
            ;;
        --no-sidecars)
            NO_SIDECARS=true
            shift
            ;;
        --no-auto-exclude)
            NO_AUTO_EXCLUDE=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error"
            exit 1
            ;;
    esac
done
# echo "DEBUG renameByMetadata.sh: ALLOW_FS_FALLBACK = $ALLOW_FS_FALLBACK" >&2
# echo "DEBUG renameByMetadata.sh: BYPASS_METADATA = $BYPASS_METADATA" >&2

# Get target file
if [ $# -eq 0 ]; then
    echo "ERROR: No filename provided"
    echo "Usage: $PROGNAME [OPTIONS] <filename>"
    echo "Try '$PROGNAME --help' for more information"
    exit 1
fi

TARGET_FILE="$1"

# Validate target file
if [ ! -f "$TARGET_FILE" ]; then
    echo "ERROR: File not found: $TARGET_FILE"
    exit 1
fi

# Build global exclude list from current working directory
build_global_exclude_list "$PWD"

# Check exclude list for target file
if is_excluded "$TARGET_FILE"; then
    log "INFO" "File excluded from renaming: $TARGET_FILE"
    exit 0
fi

# Initialize log file
if [[ "$LOG_FILE" == *.tmp ]]; then
    # Temp log for parallel batch - start fresh
    > "$LOG_FILE"
else
    # Main log - add separator if content exists
    if [ -s "$LOG_FILE" ]; then
        echo "" >> "$LOG_FILE"
    else
        touch "$LOG_FILE"
    fi
fi

log "INFO" "========================================="
log "INFO" "Starting rename operation"
log "INFO" "Target file: $TARGET_FILE"
log "INFO" "Dry run: $DRY_RUN"
log "INFO" "Verbose: $VERBOSE"
log "INFO" "Sidecar handling: $([ "$NO_SIDECARS" = true ] && echo 'disabled' || echo 'enabled')"
log "INFO" "Auto-exclude: $([ "$NO_AUTO_EXCLUDE" = true ] && echo 'disabled' || echo 'enabled')"
log "INFO" "Filesystem timestamp fallback: $([ "$ALLOW_FS_FALLBACK" = true ] && echo 'enabled' || echo 'disabled')"
log "INFO" "Metadata bypass: $([ "$BYPASS_METADATA" = true ] && echo 'enabled' || echo 'disabled')"
log "INFO" "========================================="

# Get timestamp (metadata first, then filesystem ONLY if allowed)
TIMESTAMP=""

if [ "$BYPASS_METADATA" = true ]; then
    log "INFO" "Bypassing metadata check as requested"
    if TIMESTAMP=$(get_timestamp_from_filesystem "$TARGET_FILE"); then
        log "INFO" "Using filesystem timestamp: $TIMESTAMP"
    else
        log "ERROR" "Could not get filesystem timestamp for $TARGET_FILE"
        exit 1
    fi
elif TIMESTAMP=$(get_timestamp_from_metadata "$TARGET_FILE"); then
    log "INFO" "Using metadata timestamp: $TIMESTAMP"
elif [ "$ALLOW_FS_FALLBACK" = true ] && TIMESTAMP=$(get_timestamp_from_filesystem "$TARGET_FILE"); then
    log "INFO" "Using filesystem timestamp (fallback): $TIMESTAMP"
else
    if [ "$ALLOW_FS_FALLBACK" = false ]; then
        log "ERROR" "No metadata timestamp found for $TARGET_FILE"
        log "ERROR" "Filesystem timestamp fallback is disabled. Use --allow-rename-by-file-time or --bypass-metadata-check to enable it."
    else
        log "ERROR" "Could not determine any timestamp for $TARGET_FILE"
    fi
    exit 1
fi

# Perform rename
if rename_with_sidecars "$TARGET_FILE" "$TIMESTAMP"; then
    log "INFO" "========================================="
    log "INFO" "Rename completed successfully"
    log "INFO" "Log file: $LOG_FILE"
    exit 0
else
    log "ERROR" "Rename failed"
    log "INFO" "Log file: $LOG_FILE"
    exit 1
fi