#!/usr/bin/env bash
# DESCRIPTION
# Converts all SVG files in the current directory (non-recursive) to a raster image
# format (PNG, JPG, etc.) using SVG2img.sh. By default runs parallel conversions
# using 60% of available CPU cores. Can convert svgs in subdirectories also
# (recursive). Output format defaults to PNG. Longest side is optional; if omitted,
# SVG2img.sh will use its own default (4280px).

# DEPENDENCIES
# - SVG2img.sh in PATH (or specify full path)
# - dependencies of SVG2img.sh (see)
# - xargs, nproc (coreutils)

PROGNAME=$(basename "$0")

# USAGE
print_help() {
    cat <<EOF
Usage: $PROGNAME [options]

Options:
  -l, --longest-side-px <pixels>      Optional: longest side in pixels.
  -f, --target-image-format <format>  Optional: output format (default: png).
  -c, --background-color <color>      Optional: background color.
                                       Special values: 'transparent', 'none',
                                       'default-opaque' (see SVG2img.sh for their
									   meanings), hex codes with or without
									   alpha, or any color name passed along
									   by SVG2img.sh that will work (at this
									   writing, anything cairosvg accepts).
  -m, --multiprocess-percent-cores <float>   Parallel process conversions.
                                       float is fraction of CPU cores to use
                                       (0 to 1). Default: 0.6.
  -r, --recursive                     Process SVG files in all subdirectories
                                       recursively. Changes into each directory
                                       before conversion to preserve relative
                                       path references.
  -h, --help                           Show this help.

Short form requires value attached: -m0.4
Long form requires equals sign: --multiprocess-percent-cores=0.4
A previous version of this script used positional switches; see NOTES comments
in source code if you need to adapt from the previous positional switches.

Examples:
  # Basic usage - convert all SVGs in current directory to PNG
  $PROGNAME
  
  # Recursive - convert all SVGs in current directory and all subdirectories
  $PROGNAME --recursive
  
  # Recursive with custom dimensions and transparent background
  $PROGNAME --recursive --longest-side-px 4200 --target-image-format png --background-color transparent
  
  # Recursive using 75% of CPU cores, JPEG output
  $PROGNAME -r -l3000 -fjpg -cffffff -m0.75
  
  # Non-recursive with specific background color
  $PROGNAME -l4200 -fpng -c000066ff
EOF
}

# NOTES
# PREVIOUSLY, the usage was positional switches; if you have something calling this script and returning errors about wrong data or types, you may need to update the positional switches to use the named switches below:
# - $1 the number of pixels you wish the longest side of the output image to be -- NOW -l <pixels> OR --longest-side-px <pixels>
# - $2 the target file format e.g. png or jpg -- default was jpg if not provided (NOW defaults to png) -- NOW -f <format> OR --target-image-format <format>
# - $3 optional background color (passed as $4 to SVG2img.sh) -- NOW -c <color> OR --background-color <color>
# e.g. WHAT WAS
#    allSVG2img.sh 4200 png 000066
# -- IS NOW
#    allSVG2img.sh --longest-side-px 4200 --target-image-format png --background-color 000066ff
# -- OR MORE SIMPLY (or maybe confusingly) :
#    allSVG2img.sh -l 4200 -f png -c 000066ff
# -- and you may also now run multiprocess on a fraction of CPU cores, for example on 75 percent of cores:
#    allSVG2img.sh --longest-side-px 4200 --target-image-format png --background-color 000066ff --multiprocess-percent-cores 0.75
# Default opaque background #39383bff (replaces old hardcoded fallback):
#       SVG2img.sh -i in.svg -c default-opaque

# CODE
ORIGINAL_DIR="$PWD"

cleanup() {
    cd "$ORIGINAL_DIR" 2>/dev/null
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
parallelFraction="0.6"
parallelJobs=0
recursive=false

# Parse options
OPTS=$(getopt -o hl:f:c:m::r --long help,longest-side-px:,target-image-format:,background-color:,multiprocess-percent-cores::,recursive -n "$PROGNAME" -- "$@")
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
            if [ -z "$2" ]; then
                echo "ERROR: --background-color/-c requires a value." >&2
                exit 4
            fi
            bgColor="$2"
            shift 2
            ;;
        -m|--multiprocess-percent-cores)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "ERROR: Option $1 requires a value. Short form: -m0.4 (no space). Long form: --multiprocess-percent-cores=0.4" >&2
                exit 4
            fi
            parallelFraction="$2"
            shift 2
            ;;
        -r|--recursive)
            recursive=true
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

# Build directory list
directories=(".")
if [[ "$recursive" == true ]]; then
    echo "Recursive mode enabled. Scanning subdirectories..."
    # Use mapfile for safe handling of directory names with spaces or special chars
    mapfile -t subdirs < <(find . -mindepth 1 -type d -printf "%P\n" 2>/dev/null)
    if [ ${#subdirs[@]} -gt 0 ]; then
        directories+=("${subdirs[@]}")
    fi
    echo "Found $(( ${#directories[@]} - 1 )) subdirectories (plus current directory)."
fi

# Process each directory
total_successful_dirs=0
total_failed_dirs=0
overall_failed_files=()

for dir in "${directories[@]}"; do
    echo ""
    echo "=========================================="
    echo "Processing directory: $dir"
    echo "=========================================="
    
    # Change into directory
    if ! pushd "$dir" > /dev/null 2>&1; then
        echo "WARNING: Cannot enter directory '$dir', skipping"
        ((total_failed_dirs++))
        continue
    fi
    
    # Find all SVG files in current directory
    filesList=()
    while IFS= read -r -d '' file; do
        filesList+=("$file")
    done < <(find . -maxdepth 1 -type f -iname "*.svg" -printf "%P\0" 2>/dev/null)
    
    nFiles=${#filesList[@]}
    if [ $nFiles -eq 0 ]; then
        echo "No .svg files found in $dir"
        popd > /dev/null
        continue
    fi
    echo "Found $nFiles SVG file(s) in $dir"
    
    # Temporary file for collecting failures in parallel mode for this directory
    failures_file=$(mktemp)
    trap 'rm -f "$failures_file"' RETURN
    
    # Function to process one file (uses current directory)
    process_one_file() {
        local file="$1"
        local cmd="SVG2img.sh --input-file \"$file\""
        
        [[ -n "$longestSide" ]] && cmd="$cmd --longest-side-px \"$longestSide\""
        cmd="$cmd --target-image-format \"$imgFormat\""
        [[ -n "$bgColor" ]] && cmd="$cmd --background-color \"$bgColor\""
        
        if eval $cmd; then
            echo "[$file] OK"
            return 0
        else
            echo "[$file] FAILED" >&2
            echo "$file" >> "$failures_file"
            return 1
        fi
    }
    export -f process_one_file
    export longestSide imgFormat bgColor failures_file
    
    # Process files in this directory
    failed_count=0
    if [ "$parallelJobs" -gt 1 ]; then
        echo "Running in parallel mode within $dir"
        > "$failures_file"
        printf "%s\0" "${filesList[@]}" | xargs -0 -P "$parallelJobs" -I {} bash -c 'process_one_file "$@"' _ {}
        if [ -s "$failures_file" ]; then
            failed_count=$(sort -u "$failures_file" | wc -l)
            # Record failed files with full relative path
            while IFS= read -r failed_file; do
                overall_failed_files+=("$dir/$failed_file")
            done < <(sort -u "$failures_file")
        else
            failed_count=0
        fi
    else
        echo "Running sequentially within $dir"
        for file in "${filesList[@]}"; do
            if ! process_one_file "$file"; then
                ((failed_count++))
                overall_failed_files+=("$dir/$file")
            fi
        done
    fi
    
    # Directory summary
    if [ "$failed_count" -eq 0 ]; then
        echo "Successfully processed $nFiles file(s) in $dir"
        ((total_successful_dirs++))
    else
        echo "$failed_count of $nFiles file(s) failed in $dir"
        ((total_failed_dirs++))
    fi
    
    # Cleanup and return to original directory
    rm -f "$failures_file"
    popd > /dev/null
done

# Final summary
cd "$ORIGINAL_DIR"
echo ""
echo "=========================================="
echo "FINAL SUMMARY"
echo "=========================================="
echo "Total directories processed: $(( total_successful_dirs + total_failed_dirs ))"
echo "  - Successful: $total_successful_dirs"
echo "  - Failed (or skipped): $total_failed_dirs"

if [ ${#overall_failed_files[@]} -eq 0 ]; then
    echo "All SVG files converted successfully!"
    exit 0
else
    echo "Failed files (${#overall_failed_files[@]} total):"
    for failed_file in "${overall_failed_files[@]}"; do
        echo "  - $failed_file"
    done
    exit 1
fi