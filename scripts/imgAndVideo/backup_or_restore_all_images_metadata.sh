#!/usr/bin/env bash
# backup_or_restore_all_images_metadata.sh
#
# DESCRIPTION
# Batch metadata backup or restore for all image files in the current directory
# (and optionally subdirectories). Simply calls backup_or_restore_image_metadata.sh
# for each file found.
#
# For PNG files, the single-image script handles everything automatically:
# - Auto-detects all custom fields (Prompt, workflow, etc.)
# - No manual field name specification needed
# - No config file management needed
#
# See backup_or_restore_image_metadata.sh --help for detailed documentation
# on PNG metadata handling.
#
# DEPENDENCIES
# - backup_or_restore_image_metadata.sh in PATH
# - printAllIMGfileNames.sh in PATH
# - exiftool (required by backup_or_restore_image_metadata.sh)
# - jq (required for PNG operations)
# - xargs, nproc (coreutils)
#
# USAGE
#   backup_or_restore_all_images_metadata.sh [OPTIONS]
#
# OPTIONS
#   -b, --backup-all        Create metadata backups for all images
#   -r, --restore-all       Restore metadata from backups for all images
#   -d, --delete-all        Delete all backup files
#   -c, --check-all         Check backup status for all images
#   -s, --subdirectories    Include images in subdirectories (recursive)
#   -m, --multiprocess-percent-cores <float>   
#                           Fraction of CPU cores to use (0 to 1). Default: 0.6
#   --full-paths           Use full paths instead of relative (for logging/display)
#   --dry-run              Show what would be done without actually doing it
#   -h, --help             Show this help
#
# EXAMPLES
#   # Backup all PNGs in current directory (auto-detects all custom fields)
#   backup_or_restore_all_images_metadata.sh --backup-all
#
#   # Backup all images recursively
#   backup_or_restore_all_images_metadata.sh --backup-all --subdirectories
#
#   # Restore all images in parallel
#   backup_or_restore_all_images_metadata.sh --restore-all --subdirectories -m0.6
#
#   # Check backup status of all PNGs
#   backup_or_restore_all_images_metadata.sh --check-all
#
# NOTES
# - PNG files are handled automatically. No field names or config files needed.
# - The single-image script requires jq for PNG operations. Install it if missing.
# - Parallel execution uses xargs -P with null-separated input.
# - Restore operations run without confirmation prompts.


# CODE
PROGNAME=$(basename "$0")

print_help() {
    cat <<EOF
Usage: $PROGNAME [OPTIONS]

Actions (choose one):
  -b, --backup-all        Create metadata backups for all images
  -r, --restore-all       Restore metadata from backups for all images
  -d, --delete-all        Delete all backup files
  -c, --check-all         Check backup status for all images

Options:
  -s, --subdirectories    Include images in subdirectories (recursive)
  -m, --multiprocess-percent-cores <float>   
                          Fraction of CPU cores to use (0 to 1). Default: 0.6
  --full-paths           Use full paths instead of relative
  --dry-run              Show what would be done without actually doing it
  -h, --help             Show this help

Examples:
  # Backup all images in current directory
  $PROGNAME --backup-all
  
  # Backup all images recursively
  $PROGNAME --backup-all --subdirectories
  
  # Restore all images in parallel
  $PROGNAME --restore-all --subdirectories -m0.6
  
  # Check backup status
  $PROGNAME --check-all

For PNG files, all custom fields (Prompt, workflow, etc.) are auto-detected.
No manual configuration needed.
EOF
}

# Defaults
subdirectories=false
parallelFraction="0.6"
parallelJobs=0
fullPaths=false
dryRun=false
action=""

# Parse options
OPTS=$(getopt -o hb::r::d::c::sm:: --long help,backup-all,restore-all,delete-all,check-all,subdirectories,multiprocess-percent-cores::,full-paths,dry-run -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -b|--backup-all)
            action="backup"
            shift
            ;;
        -r|--restore-all)
            action="restore"
            shift
            ;;
        -d|--delete-all)
            action="delete"
            shift
            ;;
        -c|--check-all)
            action="check"
            shift
            ;;
        -s|--subdirectories)
            subdirectories=true
            shift
            ;;
        -m|--multiprocess-percent-cores)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "ERROR: Option $1 requires a value." >&2
                exit 4
            fi
            parallelFraction="$2"
            shift 2
            ;;
        --full-paths)
            fullPaths=true
            shift
            ;;
        --dry-run)
            dryRun=true
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

# Validate action
if [ -z "$action" ]; then
    echo "ERROR: No action specified. Use -b, -r, -d, or -c." >&2
    exit 1
fi

# Check dependencies
for dep in backup_or_restore_image_metadata.sh printAllIMGfileNames.sh exiftool; do
    if ! command -v "$dep" &> /dev/null; then
        echo "ERROR: $dep not found in PATH." >&2
        exit 2
    fi
done

# Build arguments for printAllIMGfileNames.sh
printArgs=()
if [ "$subdirectories" = true ]; then
    printArgs+=("BROGNALF")
else
    printArgs+=("NULL")
fi
if [ "$fullPaths" = true ]; then
    printArgs+=("RETURN OF BROGNALF")
fi

# Get image list
echo "Scanning for image files..."
imageFiles=()
while IFS= read -r file; do
    [ -n "$file" ] && imageFiles+=("$file")
done < <(printAllIMGfileNames.sh "${printArgs[@]}")

nFiles=${#imageFiles[@]}
if [ $nFiles -eq 0 ]; then
    echo "No image files found. Exiting."
    exit 0
fi
echo "Found $nFiles image file(s)."

# Compute parallel jobs
if [ "$parallelFraction" != "0" ]; then
    totalCores=$(nproc 2>/dev/null || echo 1)
    parallelJobs=$(awk "BEGIN {printf \"%d\", $parallelFraction * $totalCores}")
    [ "$parallelJobs" -lt 1 ] && parallelJobs=1
    echo "Using $parallelJobs concurrent jobs (detected $totalCores cores)."
else
    parallelJobs=1
fi

# Action to flag mapping
action_to_flag() {
    case "$1" in
        backup) echo "-b" ;;
        restore) echo "-r" ;;
        delete) echo "-d" ;;
        check) echo "-c" ;;
    esac
}

# Process files
failed_count=0

if [ "$dryRun" = true ]; then
    echo "DRY RUN MODE"
    flag=$(action_to_flag "$action")
    for file in "${imageFiles[@]}"; do
        echo "[DRY RUN] backup_or_restore_image_metadata.sh $flag \"$file\""
    done
    echo "Would process $nFiles file(s)"
    exit 0
fi

if [ "$parallelJobs" -gt 1 ]; then
    echo "Running in parallel mode..."
    
    temp_script=$(mktemp)
    cat > "$temp_script" << 'EOF'
#!/bin/bash
file="$1"
action="$2"
flag=$(case "$action" in
    backup) echo "-b" ;;
    restore) echo "-r" ;;
    delete) echo "-d" ;;
    check) echo "-c" ;;
esac)

if backup_or_restore_image_metadata.sh "$flag" "$file" >/dev/null 2>&1; then
    echo "SUCCESS: $file"
    exit 0
else
    echo "FAILED: $file"
    exit 1
fi
EOF
    chmod +x "$temp_script"
    
    failures=$(mktemp)
    printf "%s\0" "${imageFiles[@]}" | xargs -0 -P "$parallelJobs" -I '{}' bash "$temp_script" "{}" "$action" > "$failures" 2>&1
    
    failed_count=$(grep -c "^FAILED:" "$failures" 2>/dev/null | tr -d '\n\r' || echo 0)
	# Force to integer
	failed_count=$((failed_count + 0))
    if [ "$failed_count" -gt 0 ] 2>/dev/null; then
        echo ""
        echo "Failed files:"
        grep "^FAILED:" "$failures" | sed 's/^FAILED: /  - /'
    fi
    
    rm -f "$temp_script" "$failures"
else
    echo "Running sequentially..."
    flag=$(action_to_flag "$action")
    for file in "${imageFiles[@]}"; do
        if backup_or_restore_image_metadata.sh "$flag" "$file"; then
            echo "[$file] $action: SUCCESS"
        else
            echo "[$file] $action: FAILED" >&2
            ((failed_count++))
        fi
    done
fi

echo "----------------------------------------"
if [ "$failed_count" -eq 0 ]; then
    echo "All $nFiles file(s) processed successfully."
    exit 0
else
    echo "ERROR: $failed_count of $nFiles file(s) failed."
    exit 1
fi