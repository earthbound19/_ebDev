#!/bin/bash
# renameByMetadata.sh - Rename ONE file using metadata timestamps
# 
# DESCRIPTION
# Renames a single file (and optionally its sidecar files) based on metadata
# timestamps (DateTimeOriginal or CreateDate) with fallback to filesystem
# timestamps (creation time, then modification time).
#
# Sidecar files are identified by matching basename BEFORE any rename occurs,
# then renamed to match the new basename.
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
    -h, --help              Show this help

EXAMPLES:
    $PROGNAME -y DSC_0001.NEF
    $PROGNAME --dry-run --verbose video.mp4
    $PROGNAME --no-sidecars document.pdf

EXCLUDE LIST:
    To exclude files from renaming, list them in rename_excludes.txt files.
    
	- a rename_exclude.txt file anywhere in the directory tree that this
	  script works on will affect all files in the whole tree:
      - parent directory exclude files apply to all child directories
      - child directory exclude files add to parent excludes
    - lines starting with '#' are ignored
    - exact matches only (file name detection is case-sensitive)
    - one filename per line (base name + extension only) in the file, for example:
		# in a rename_excludes.txt:
		crying_while_eating.jpg
		crescent_fresh.png
    
    Examples:
        # in /photos/rename_excludes.txt:
        that_one_time_Rey_whooped_Kylos_hinie.jpg
        precious_memories_with_Darth_Maul.png
        
        # in /photos/2024/wedding/rename_excludes.txt:
        DSC_VIP.JPG        # Excludes just this one VIP photo

NOTES:
    - sidecar discovery is done for ALL files in same directory with matching basename
    - rename collisions get suffixes to make unique: -1, -2, etc.
    - exits with error if new filename exceeds 240 characters
    - logs to rename_by_metadata.log in current directory
EOF
}

# CODE
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
        
        while IFS= read -r pattern || [ -n "$pattern" ]; do
            # Skip comments and empty lines
            [[ -z "$pattern" || "$pattern" =~ ^[[:space:]]*# ]] && continue
            # Trim whitespace
            pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            [[ -z "$pattern" ]] && continue
            
            GLOBAL_EXCLUDE_PATTERNS+=("$pattern")
            log "VERBOSE" "  Added global exclude: $pattern"
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