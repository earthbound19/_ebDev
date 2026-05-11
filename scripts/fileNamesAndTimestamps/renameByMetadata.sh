#!/bin/bash
# DESCRIPTION
# Renames a single file and by default also its sidecar (or sibling / same base
# file name based on metadata. For example if you have a totally unhelpfully named
# file from a digital camera named something like IMG3284.jpg, this will rename it
# to something far more useful like the date and time it was taken, for example
# 2026_05_05__00_21_08.jpg (yyyy_mm_dd__hh_mm_ss.extension). If creation time
# metadata is not available, falls back to file system timestamps, trying first for
# creation time, then modification time.
#
# Sidecar files are identified by matching basename before any rename occurs,
# then renamed to match the new basename.
#
# DEPENDENCIES
# ExifTool, stat
#
# USAGE
print_help() {
    cat << EOF
Renames a single file based on metadata timestamps, with sidecar support.

  Usage: $PROGNAME [OPTIONS] <filename>

OPTIONS
  -y, --yes               skip confirmation prompt
  -d, --dry-run           show what would happen without renaming
  -v, --verbose           verbose output
  --no-sidecars           skip sidecar file renaming
  -h, --help              show this help message

EXAMPLES
To rename a file DSC_0001.NEF by metadata and bypass prompt to confirm rename, run:
  $PROGNAME -y DSC_0001.NEF
To see how video.mp4 would be renamed and print any relevant debug details:
  $PROGNAME --dry-run --verbose video.mp4
To rename ANY type of file for which metadata may (or may not be!) available, for
example a PDF, with no sidecar check or rename:
  $PROGNAME --no-sidecars document.pdf

See the NOTES header comment section in the script for additional details.
EOF
}

# NOTES
# - sidecar discovery and rename operates on ALL files in same directory with
  # a matching basename. For example, if you have three files named:

   # DSC_4813.jpg
   # DSC_4813.NEF
   # DSC_4813.xmp

# -- and you run:

   # $PROGNAME -y DSC_4813.NEF

# -- the script will:
# - identify the sidecar / sibling files DSC_4813.jpg and DSC_4813.xmp, and remember them
# - look up creation time metadata in the NEF file and rename it, for example:

   # mv DSC_4813.NEF 2026_05_10__20_06_30.NEF

# it will then rename the sidecar and sibling files to match:

   # mv DSC_4813.xmp 2026_05_10__20_06_30.xmp
   # mv DSC_4813.jpg 2026_05_10__20_06_30.jpg

# - duplicate filenames get -1, -2, etc. suffix (matching exiftool %-c)
# - the script exits with an error if the origin or new filename exceeds 240 characters.
# - the script logs renames to YYYY-MM-DD_HH-MM-SS.log in the current directory.
# - media files use CreateDate or DateTimeOriginal metadata
# - fallback rename if no metadata found uses creation time, then modification time
# - any file with same basename (before rename) is considered a sidecar
# - duplicate filenames get -1, -2 suffix
# - filenames exceeding 240 characters trigger error
# - logs are written to rename_by_metadata.log

# REFERENCE
  # https://exiftool.org/filename.html


# CODE
PROGNAME=$(basename "$0")
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# log file global name
LOG_FILE="rename_by_metadata.log"

# Default values
YES_MODE=false
DRY_RUN=false
VERBOSE=false
NO_SIDECARS=false
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
            echo -e "${YELLOW}[WARNING]${NC} $message"
            echo "[$timestamp] WARNING: $message" >> "$LOG_FILE"
            ;;
        INFO)
            echo "$message"
            echo "[$timestamp] INFO: $message" >> "$LOG_FILE"
            ;;
        VERBOSE)
            if [ "$VERBOSE" = true ]; then
                echo -e "${GREEN}[VERBOSE]${NC} $message"
            fi
            echo "[$timestamp] VERBOSE: $message" >> "$LOG_FILE"
            ;;
        *)
            echo "$message"
            echo "[$timestamp] $message" >> "$LOG_FILE"
            ;;
    esac
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
    
    # Discover sidecars BEFORE rename (by basename)
    local sidecars=()
    if [ "$NO_SIDECARS" != true ]; then
        log "INFO" "Discovering sidecar files for basename: $old_name_no_ext"
        for f in "$old_dir"/*; do
            if [ -f "$f" ]; then
                local f_basename=$(basename "$f")
                local f_name_no_ext="${f_basename%.*}"
                
                # Skip the target file itself (explicit basename comparison)
                if [ "$f_basename" = "$old_basename" ]; then
                    log "VERBOSE" "Skipping target file: $f_basename"
                    continue
                fi
                
                # Check if basename matches (potential sidecar)
                if [ "$f_name_no_ext" = "$old_name_no_ext" ]; then
                    sidecars+=("$f")
                    log "VERBOSE" "Found sidecar: $(basename "$f")"
                fi
            fi
        done
        
        # Final verification: ensure target file is NOT in sidecar array
        local found_target=false
        for sidecar in "${sidecars[@]}"; do
            if [ "$(basename "$sidecar")" = "$old_basename" ]; then
                found_target=true
                log "ERROR" "BUG: Target file $old_basename found in sidecar array!"
            fi
        done
        
        if [ "$found_target" = false ]; then
            log "VERBOSE" "Verified target file not in sidecar array"
        fi
        
        log "INFO" "Found ${#sidecars[@]} sidecar file(s)"
    fi
    
    # Generate new filename for main file
    local new_filename=$(get_unique_filename "$new_basename" "$old_extension")
    log "VERBOSE" "New filename generated: $new_filename"
    
    # Check path length
    check_filename_length "$new_filename" || return 1
    
    # Dry run mode - just report
    if [ "$DRY_RUN" = true ]; then
        log "INFO" "[DRY RUN] Would rename: $old_basename -> $new_filename"
        for sidecar in "${sidecars[@]}"; do
            local sidecar_basename=$(basename "$sidecar")
            local sidecar_name_no_ext="${sidecar_basename%.*}"
            local sidecar_ext="${sidecar_basename##*.}"
            if [ "$sidecar_name_no_ext" = "$sidecar_basename" ]; then
                sidecar_ext=""
            fi
            local new_sidecar_name=$(get_unique_filename "$new_basename" "$sidecar_ext")
            log "INFO" "[DRY RUN] Would rename sidecar: $sidecar_basename -> $new_sidecar_name"
        done
        return 0
    fi
    
    # Confirm if not in yes mode
    if [ "$YES_MODE" != true ]; then
        echo ""
        echo -e "${YELLOW}This will rename the following files:${NC}"
        echo "  Main:   $old_basename -> $new_filename"
        if [ ${#sidecars[@]} -gt 0 ]; then
            echo "  Sidecars:"
            for sidecar in "${sidecars[@]}"; do
                local sidecar_basename=$(basename "$sidecar")
                local sidecar_name_no_ext="${sidecar_basename%.*}"
                local sidecar_ext="${sidecar_basename##*.}"
                if [ "$sidecar_name_no_ext" = "$sidecar_basename" ]; then
                    sidecar_ext=""
                fi
                local new_sidecar_name=$(get_unique_filename "$new_basename" "$sidecar_ext")
                echo "    $sidecar_basename -> $new_sidecar_name"
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
    log "INFO" "Renaming main file: $old_basename -> $new_filename"
    if ! mv "$file" "$new_filename" 2>/dev/null; then
        log "ERROR" "Failed to rename main file: $file -> $new_filename"
        return 1
    fi
    
    # Rename sidecars
    local renamed_count=0
    for sidecar in "${sidecars[@]}"; do
        local sidecar_basename=$(basename "$sidecar")
        local sidecar_name_no_ext="${sidecar_basename%.*}"
        local sidecar_ext="${sidecar_basename##*.}"
        if [ "$sidecar_name_no_ext" = "$sidecar_basename" ]; then
            sidecar_ext=""
        fi
        
        local new_sidecar_name=$(get_unique_filename "$new_basename" "$sidecar_ext")
        log "INFO" "Renaming sidecar: $sidecar_basename -> $new_sidecar_name"
        
        if mv "$sidecar" "$(dirname "$sidecar")/$new_sidecar_name" 2>/dev/null; then
            ((renamed_count++))
        else
            log "ERROR" "Failed to rename sidecar: $sidecar_basename"
        fi
    done
    
    log "INFO" "Successfully renamed $renamed_count of ${#sidecars[@]} sidecar(s)"
    return 0
}

# Parse command line arguments
TEMP=$(getopt -o ydvh --long yes,dry-run,verbose,no-sidecars,help -n "$PROGNAME" -- "$@")
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
        --no-sidecars)
            NO_SIDECARS=true
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

# Add a blank line before new session if log already has content
if [ -s "$LOG_FILE" ]; then
    echo "" >> "$LOG_FILE"
else
	touch "$LOG_FILE"  # Creates file if not exists, does nothing if exists
fi

log "INFO" "========================================="
log "INFO" "Starting rename operation"
log "INFO" "Target file: $TARGET_FILE"
log "INFO" "Dry run: $DRY_RUN"
log "INFO" "Verbose: $VERBOSE"
log "INFO" "Sidecar handling: $([ "$NO_SIDECARS" = true ] && echo 'disabled' || echo 'enabled')"
log "INFO" "========================================="

# Get timestamp (metadata first, then filesystem)
TIMESTAMP=""

if TIMESTAMP=$(get_timestamp_from_metadata "$TARGET_FILE"); then
    log "INFO" "Using metadata timestamp: $TIMESTAMP"
elif TIMESTAMP=$(get_timestamp_from_filesystem "$TARGET_FILE"); then
    log "INFO" "Using filesystem timestamp: $TIMESTAMP"
else
    log "ERROR" "Could not determine any timestamp for $TARGET_FILE"
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