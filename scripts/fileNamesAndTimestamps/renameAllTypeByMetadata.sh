#!/bin/bash
# renameAllTypeByMetadata.sh - Batch rename files by metadata with parallel file processing
#
# DESCRIPTION
# Finds all files of type $EXTENSION in current directory (and optionally
# subdirectories) and renames each using renameByMetadata.sh.
#
# Parallel execution occurs at the FILE level. Each file is processed
# independently. Logs are appended directly to rename_by_metadata.log
# (atomic appends are safe for concurrent writes).
#
# IMPORTANT: This wrapper forces -y (yes mode) for all rename operations
# to avoid prompting in parallel mode, where the user can't possibly respond to any y/n
# prompt.
#
# DEPENDENCIES
# renameByMetadata.sh, find, xargs, nproc
#
# USAGE
print_help() {
    cat << EOF
$PROGNAME - Batch rename files by metadata with parallel file processing

Usage: $PROGNAME -t EXTENSION [OPTIONS]

OPTIONS:
    -t, --type EXTENSION        File extension to process (e.g., NEF, JPG, no dot)
    -s, --subdirectories        Process subdirectories recursively
    -a, --allow-rename-by-file-time
                                Allow fallback to filesystem timestamps (creation time,
                                then modification time) if no metadata timestamp found.
                                WARNING: Filesystem timestamps can be inaccurate!
    -m, --multiprocess-percent-cores FLOAT  
                                Fraction of CPU cores for parallel processing
                                (default: 0.6 = 60% of cores)
    -d, --dry-run               Show what would happen without renaming
    -v, --verbose               Verbose output
    --no-sidecars               Skip sidecar renaming
    -h, --help                  Show this help

EXAMPLES:
    $PROGNAME -t NEF                         # operate on all NEF files in the current directory only
    $PROGNAME -t JPG -s                      # operate on all JPG files, including in subdirectories
    $PROGNAME -t CR2 -s -m0.75               # multiprocessing mode using 75%% of cores on al CR2 files
    $PROGNAME -t MOV --dry-run               # operate on all MOV files, preview changes (no rename)
    $PROGNAME -t PNG -s --no-sidecars        # skip sidecar detection or rename
    $PROGNAME -t NEF -a                      # allow filesystem timestamp fallback for files without metadata
EOF
}

# CODE
PROGNAME=$(basename "$0")
PATH_TO_RENAME_BY_METADATA=$(command -v renameByMetadata.sh)

# Default values
EXTENSION=""
SUBDIRECTORIES=false
ALLOW_FS_FALLBACK=false
PARALLEL_FRACTION="0.6"
DRY_RUN=false
VERBOSE=false
NO_SIDECARS=false

cleanup() {
    echo -e "\nInterrupted. Terminating all child processes..."
    rm -f "/tmp/rename_by_metadata.failures.$$" 2>/dev/null
    exit 1
}
trap cleanup SIGINT SIGTERM

# Parse arguments
OPTS=$(getopt -o ht:sm:adva --long help,type:,subdirectories,multiprocess-percent-cores:,allow-rename-by-file-time,dry-run,verbose,no-sidecars -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -h|--help) print_help; exit 0 ;;
        -t|--type) EXTENSION="$2"; shift 2 ;;
        -s|--subdirectories) SUBDIRECTORIES=true; shift ;;
        -a|--allow-rename-by-file-time)
            ALLOW_FS_FALLBACK=true
            shift
            ;;
        -m|--multiprocess-percent-cores) 
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "ERROR: Option $1 requires a value. Short form: -m0.6 (no space). Long form: --multiprocess-percent-cores=0.6" >&2
                exit 4
            fi
            PARALLEL_FRACTION="$2"
            shift 2
            ;;
        -d|--dry-run) DRY_RUN=true; shift ;;
        -v|--verbose) VERBOSE=true; shift ;;
        --no-sidecars) NO_SIDECARS=true; shift ;;
        --) shift; break ;;
        *) echo "Internal error!" >&2; exit 1 ;;
    esac
done

# Validate
if [ -z "$EXTENSION" ]; then
    echo "ERROR: -t/--type is required"
    exit 1
fi

# Validate parallel fraction
if [[ ! "$PARALLEL_FRACTION" =~ ^0(\.[0-9]+)?$|^1(\.0+)?$ ]]; then
    echo "ERROR: Parallel fraction must be a decimal between 0 and 1 (e.g., 0.5). Got '$PARALLEL_FRACTION'" >&2
    exit 1
fi

# Compute parallel jobs
total_cores=$(nproc 2>/dev/null || echo 1)
parallel_jobs=$(awk "BEGIN {printf \"%d\", $PARALLEL_FRACTION * $total_cores}")
[ "$parallel_jobs" -lt 1 ] && parallel_jobs=1

echo "========================================="
echo "Batch Rename Configuration"
echo "Extension: .$EXTENSION"
echo "Subdirectories: $([ "$SUBDIRECTORIES" = true ] && echo 'yes' || echo 'no')"
echo "Parallel jobs: $parallel_jobs ($PARALLEL_FRACTION of $total_cores cores)"
echo "Dry run: $DRY_RUN"
echo "Verbose: $VERBOSE"
echo "Sidecar handling: $([ "$NO_SIDECARS" = true ] && echo 'disabled' || echo 'enabled')"
echo "Filesystem timestamp fallback: $([ "$ALLOW_FS_FALLBACK" = true ] && echo 'enabled' || echo 'disabled')"
echo "========================================="

# Find all target files (preserving relative paths)
if [ "$SUBDIRECTORIES" = true ]; then
    mapfile -t all_files < <(find . -type f -iname "*.$EXTENSION" | sed 's|^\./||' | sort 2>/dev/null || true)
else
    mapfile -t all_files < <(find . -maxdepth 1 -type f -iname "*.$EXTENSION" | sed 's|^\./||' | sort 2>/dev/null || true)
fi

if [ ${#all_files[@]} -eq 0 ]; then
    echo "No *.$EXTENSION files found."
    exit 0
fi

echo "Found ${#all_files[@]} file(s)."
echo ""

# Temporary file for collecting failures
failures_file="/tmp/rename_by_metadata.failures.$$"
> "$failures_file"

# Function to process one file (-y is used to avoid prompts in parallel mode)
process_one_file() {
    local file="$1"
    
    if "$PATH_TO_RENAME_BY_METADATA" -y \
        $([ "$DRY_RUN" = true ] && echo '-d') \
        $([ "$VERBOSE" = true ] && echo '-v') \
        $([ "$NO_SIDECARS" = true ] && echo '--no-sidecars') \
        $([ "$ALLOW_FS_FALLBACK" = true ] && echo '-a') \
        "$file"; then
        echo "[$file] OK" >&2
        return 0
    else
        echo "[$file] FAILED" >&2
        echo "$file" >> "$failures_file"
        return 1
    fi
}

export -f process_one_file
# all these exports are actually needed for wonky reasons; if you remove any things may not work as expected.
# the exported function relies on these exported variables is why.
export PATH_TO_RENAME_BY_METADATA failures_file ALLOW_FS_FALLBACK DRY_RUN VERBOSE NO_SIDECARS

# Process files in parallel
echo "Processing with $parallel_jobs parallel job(s)..."

if [ "$parallel_jobs" -gt 1 ]; then
    printf "%s\0" "${all_files[@]}" | xargs -0 -P "$parallel_jobs" -I {} bash -c 'process_one_file "$@"' _ {}
else
    for file in "${all_files[@]}"; do
        process_one_file "$file"
    done
fi

# Summary
failed_count=0
if [ -s "$failures_file" ]; then
    failed_count=$(sort -u "$failures_file" | wc -l)
fi

echo ""
echo "========================================="
echo "Batch rename complete."
echo "Processed: ${#all_files[@]} file(s)"
echo "Failed: $failed_count file(s)"

if [ "$failed_count" -gt 0 ] && [ -s "$failures_file" ]; then
    echo "Failed files:"
    sort -u "$failures_file" | sed 's/^/  - /'
    exit 1
fi

# Cleanup
rm -f "$failures_file"

exit 0