#!/usr/bin/env bash
# DESCRIPTION
# Resaves all SVGs in a directory (and optionally subdirectories) so that the view canvas shows everything. Useful for example for adjusting auto-exported glyphs from fonts where the canvas crops out things below the letter baseline. In detail: for every vector file of a given type (default SVG) in the current directory (and optionally all subdirectories), selects all, resizes the canvas to fit the selection, and exports a plain (if possible?) format version of that file over itself.
#
# Optionally parallel processes using xargs -P. Ctrl+C kills all child processes.

# DEPENDENCIES
# inkscape with CLI capability installed and in your PATH.
# xargs (standard on MSYS2) for parallel execution.
# nproc (usually part of coreutils) to detect core count.

# USAGE
#   -t, --type <ext>                   File type to process (default: svg)
#   -r, --recursive                    Process files in subdirectories as well
#   -m, --multiprocess-percent-cores <float>   Enable parallel mode. If used, a float between 0 and 1 (e.g., -m0.4) is required. Short form -m must have the float immediately after the -m, for example -m0.4. Long form --multiprocess-percent-cores must use the form =value, for example --multiprocess-percent-cores=0.4
#   -h, --help                         Show this help
#
# If -m is omitted, runs sequentially. Example: -m 0.4 uses 40% of cores.

# CODE

PROGNAME=$(basename "$0")

function print_halp {
    cat <<EOF
Usage: $PROGNAME [options]

Options:
  -t, --type <ext>       File extension to process (default: svg)
  -r, --recursive        Process files in all subdirectories as well
  -m, --multiprocess-percent-cores <float>   Enable parallel mode. If used, a float between 0 and 1 (e.g., -m0.4) is required. Short form -m must have the float immediately after the -m, for example -m0.4. Long form --multiprocess-percent-cores must use the form =value, for example --multiprocess-percent-cores=0.4
  -h, --help             Show this help

If -m is not given, runs sequentially.
EOF
}

cleanup() {
    echo -e "\nInterrupted. Terminating all child processes..."
    pkill -TERM -P $$ 2>/dev/null
    sleep 0.5
    pkill -KILL -P $$ 2>/dev/null
    exit 1
}
trap cleanup SIGINT SIGTERM

# Defaults
inputFileType="svg"
recursiveFlag=""
parallelJobs=0
fraction=""

# Parse options: -m is optional argument (::) so we can detect missing value
OPTS=$(getopt -o ht:rm:: --long help,type:,recursive,multiprocess-percent-cores:: -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -h|--help)
            print_halp
            exit 0
            ;;
        -t|--type)
            inputFileType="$2"
            shift; shift
            ;;
        -r|--recursive)
            recursiveFlag="-r"
            shift
            ;;
        -m|--multiprocess-percent-cores)
            # No space allowed after -m; for long form, use =.
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "ERROR: Option $1 requires a value. When using the short form (-m), don't use a space (example: -m0.4). For the long form, use an equals sign (example: --multiprocess-percent-cores=0.4)." >&2
                exit 4
            fi
            fraction="$2"
            shift; shift
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

# Compute parallel jobs if -m was used
if [ -n "$fraction" ]; then
    totalCores=$(nproc 2>/dev/null || echo 1)
    if [[ ! "$fraction" =~ ^0(\.[0-9]+)?$|^1(\.0+)?$ ]]; then
        echo "ERROR: Value for -m must be a decimal between 0 and 1 (e.g., 0.5). Got '$fraction'" >&2
        exit 1
    fi
    parallelJobs=$(awk "BEGIN {printf \"%d\", $fraction * $totalCores}")
    if [ "$parallelJobs" -lt 1 ]; then
        parallelJobs=1
    fi
    # Optional cap via environment variable
    if [ -n "$MAX_PARALLEL_JOBS" ] && [ "$parallelJobs" -gt "$MAX_PARALLEL_JOBS" ]; then
        echo "Capping parallel jobs from $parallelJobs to $MAX_PARALLEL_JOBS (MAX_PARALLEL_JOBS)"
        parallelJobs=$MAX_PARALLEL_JOBS
    fi
    echo "Using $parallelJobs concurrent jobs (detected $totalCores cores, fraction $fraction)."
fi

# Build find command
if [ -n "$recursiveFlag" ]; then
    subDirSearchParam=""
else
    subDirSearchParam="-maxdepth 1"
fi

mapfile -t filesList < <(find . $subDirSearchParam -type f -iname "*.$inputFileType" -printf "%P\n")
nFilesInList=${#filesList[@]}

if [ $nFilesInList -eq 0 ]; then
    echo "No *.$inputFileType files found. Exiting."
    exit 0
fi

echo "Found $nFilesInList file(s) of type .$inputFileType"

process_one_file() {
    local file="$1"
    echo "[$file] Starting..."
    if [ "$inputFileType" == "svg" ]; then
        inkscape --export-filename="$file" --export-plain-svg --actions="select-all;fit-canvas-to-selection" "$file"
    else
        inkscape --export-filename="$file" --actions="select-all;fit-canvas-to-selection" "$file"
    fi
    echo "[$file] Finished."
}
export -f process_one_file
export inputFileType

if [ "$parallelJobs" -gt 1 ]; then
    echo "Running in parallel mode with $parallelJobs concurrent jobs (xargs)."
    printf "%s\0" "${filesList[@]}" | xargs -0 -P "$parallelJobs" -I {} bash -c 'process_one_file "$@"' _ {}
else
    echo "Running sequentially (one file at a time)."
    i=0
    for file in "${filesList[@]}"; do
        i=$((i+1))
        echo "working on file $file ... ($i of $nFilesInList)"
        process_one_file "$file"
    done
fi

echo "All files processed."