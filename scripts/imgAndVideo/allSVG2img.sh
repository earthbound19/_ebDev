#!/usr/bin/env bash
# DESCRIPTION
# Converts all SVG files in the current directory (non-recursive) to a raster image
# format (PNG, JPG, etc.) using SVG2img.sh. By default runs in parallel using 60% of
# available CPU cores. Output format defaults to PNG. Longest side is optional; if
# omitted, SVG2img.sh will use its own default.
#
# Parallelism can be controlled with the -m / --multiprocess-percent-cores option.
# Use -m0.6 (short form, no space) or --multiprocess-percent-cores=0.6.
#
# DEPENDENCIES
# - SVG2img.sh in PATH (or specify full path)
# - dependencies of SVG2img.sh (see)
# - xargs, nproc (coreutils)

# USAGE
PROGNAME=$(basename "$0")

print_help() {
    cat <<EOF
Usage: $PROGNAME [options]

Call with the following switches:
  -l, --longest-side-px <pixels>      Optional: longest side in pixels.
  -f, --target-image-format <format>  Optional: output format (default: png).
  -c, --background-color <color>      Optional: background color (e.g., white, #ffffff).
  -m, --multiprocess-percent-cores <float>   Optional, but if used a value is required.
                                       Fraction of CPU cores to use, expressed as decimal
                                       percent from 0 to 1. So for example 0.45 would be
                                       45% of cores. If omitted defaults to 0.6.
  -h, --help                           Show this help.

If -m is provided without a value (e.g., just -m), the script exits with an error.
Short form requires the value directly attached: -m0.4
Long form requires an equals sign: --multiprocess-percent-cores=0.4
EOF
}


# CODE

cleanup() {
    echo -e "\nInterrupted. Terminating all child processes..."
    pkill -TERM -P $$ 2>/dev/null
    sleep 0.5
    pkill -KILL -P $$ 2>/dev/null
    exit 1
}
trap cleanup SIGINT SIGTERM

# Defaults
longestSide=""
imgFormat="png"
bgColor=""
parallelFraction="0.6"   # default when -m is absent
parallelJobs=0
userProvidedM=false

# Parse options
OPTS=$(getopt -o hl:f:c:m:: --long help,longest-side-px:,target-image-format:,background-color:,multiprocess-percent-cores:: -n "$PROGNAME" -- "$@")
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
        -l|--longest-side-px)
            longestSide="$2"
            shift 2
            ;;
        -f|--target-image-format)
            imgFormat="$2"
            shift 2
            ;;
        -c|--background-color)
            bgColor="$2"
            shift 2
            ;;
        -m|--multiprocess-percent-cores)
            userProvidedM=true
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "ERROR: Option $1 requires a value. When using the short form (-m), don't use a space (example: -m0.4). For the long form, use an equals sign (example: --multiprocess-percent-cores=0.4)." >&2
                exit 4
            fi
            parallelFraction="$2"
            shift 2
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

# Compute parallel jobs
totalCores=$(nproc 2>/dev/null || echo 1)
if [[ ! "$parallelFraction" =~ ^0(\.[0-9]+)?$|^1(\.0+)?$ ]]; then
    echo "ERROR: Parallel fraction must be a decimal between 0 and 1 (e.g., 0.5). Got '$parallelFraction'" >&2
    exit 1
fi
parallelJobs=$(awk "BEGIN {printf \"%d\", $parallelFraction * $totalCores}")
if [ "$parallelJobs" -lt 1 ]; then
    echo "WARNING: Computed parallel jobs ($parallelJobs) less than 1, forcing to 1."
    parallelJobs=1
fi
if [ -n "$MAX_PARALLEL_JOBS" ] && [ "$parallelJobs" -gt "$MAX_PARALLEL_JOBS" ]; then
    echo "Capping parallel jobs from $parallelJobs to $MAX_PARALLEL_JOBS (MAX_PARALLEL_JOBS)"
    parallelJobs=$MAX_PARALLEL_JOBS
fi
echo "Using $parallelJobs concurrent jobs (detected $totalCores cores, fraction $parallelFraction)."

# Find SVG files (non‑recursive, current directory only)
# Use null delimiter for safety, mapfile to read into array
filesList=()
while IFS= read -r -d '' file; do
    filesList+=("$file")
done < <(find . -maxdepth 1 -type f -iname "*.svg" -printf "%P\0")

nFiles=${#filesList[@]}
if [ $nFiles -eq 0 ]; then
    echo "No .svg files found in current directory. Exiting."
    exit 0
fi
echo "Found $nFiles SVG file(s)."

# Temporary file for collecting failures in parallel mode
failures_file=$(mktemp)
trap 'rm -f "$failures_file"' EXIT

# Function to process one file
process_one_file() {
    local file="$1"
    # Build argument array for SVG2img.sh
    # Start with required filename
    local cmd_args=( "$file" )
    # Add optional longest side if provided
    [[ -n "$longestSide" ]] && cmd_args+=( "$longestSide" )
    # Always add format (defaults to png)
    cmd_args+=( "$imgFormat" )
    # Add optional background color if provided
    [[ -n "$bgColor" ]] && cmd_args+=( "$bgColor" )

    # Run the conversion
    if SVG2img.sh "${cmd_args[@]}"; then
        echo "[$file] OK"
        return 0
    else
        echo "[$file] FAILED" >&2
        # Record failure in temp file (parallel mode only)
        echo "$file" >> "$failures_file"
        return 1
    fi
}
export -f process_one_file
export longestSide imgFormat bgColor failures_file

# Process files
failed_count=0
if [ "$parallelJobs" -gt 1 ]; then
    echo "Running in parallel mode."
    # Clear failures file
    > "$failures_file"
    printf "%s\0" "${filesList[@]}" | xargs -0 -P "$parallelJobs" -I {} bash -c 'process_one_file "$@"' _ {}
    # Count failures by reading unique entries (one per failed file)
    if [ -s "$failures_file" ]; then
        failed_count=$(sort -u "$failures_file" | wc -l)
    else
        failed_count=0
    fi
else
    echo "Running sequentially (should not happen with default parallelism; jobs=$parallelJobs)"
    for file in "${filesList[@]}"; do
        process_one_file "$file" || ((failed_count++))
    done
fi

# Summary
if [ "$failed_count" -eq 0 ]; then
    echo "All $nFiles file(s) processed successfully."
    exit 0
else
    echo "ERROR: $failed_count of $nFiles file(s) failed."
    if [ "$parallelJobs" -gt 1 ] && [ -s "$failures_file" ]; then
        echo "Failed files:"
        sort -u "$failures_file" | sed 's/^/  - /'
    fi
    exit 1
fi