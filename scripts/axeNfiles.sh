#!/usr/bin/env bash
# DESCRIPTION
# Splits all files in the current directory of type $EXTENSION into subdirectories 
# by multiples of $NUMBER_PER_FOLDER (axe files into folders), with folder prefix 
# name $FOLDER_PREFIX.
#
# This version uses named switches and parallel batch processing where each
# parallel job executes a single `mv` command moving ALL files for one folder.

# USAGE
#   axeNfiles.sh -e EXTENSION -n NUMBER_PER_FOLDER [options]
#
# REQUIRED SWITCHES:
#   -e, --extension EXT           File extension to axe (no dot, e.g., hexplt)
#   -n, --number-per-folder N     Number of files per subfolder
#
# OPTIONAL SWITCHES:
#   -p, --folder-prefix PREFIX    Folder name prefix (default: _toEndFR_)
#   -s, --shuffle                 Randomize file order before distribution
#   -m, --multiprocess-percent-cores FLOAT  
#                                 Fraction of CPU cores for parallel moves
#                                 (default: 0.3 = 30% of cores)
#   -h, --help                    Show this help

set -euo pipefail

PROGNAME=$(basename "$0")

print_help() {
    cat <<EOF
$PROGNAME - Axe files into numbered subfolders

Usage: $PROGNAME -e EXTENSION -n NUMBER_PER_FOLDER [options]

Required:
  -e, --extension EXT           File extension to axe (e.g., hexplt, no dot)
  -n, --number-per-folder N     Number of files per subfolder

Optional:
  -p, --folder-prefix PREFIX    Folder name prefix (default: _toEndFR_)
  -s, --shuffle                 Randomize file order before distribution
  -m, --multiprocess-percent-cores FLOAT  
                                Fraction of CPU cores for parallel moves
                                (default: 0.6 = 60% of cores)
  -h, --help                    Show this help

Examples:
  $PROGNAME -e hexplt -n 80                    # 30% parallel
  $PROGNAME -e hexplt -n 80 -m0.75 -s          # 75% parallel, shuffled
  $PROGNAME -e hexplt -n 80 -m0                # sequential

Parallel Implementation:
  Files are grouped by destination folder. For each folder, a single `mv` command
  is constructed with ALL files as arguments. These commands run in parallel
  using xargs -P, giving one subshell per folder, not per file.
EOF
}

# === PARSE ARGUMENTS ===
EXTENSION=""
NUMBER_PER_FOLDER=""
FOLDER_PREFIX="_toEndFR_"
SHUFFLE=false
PARALLEL_FRACTION="0.6"

OPTS=$(getopt -o he:n:p:sm: --long help,extension:,number-per-folder:,folder-prefix:,shuffle,multiprocess-percent-cores: -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -h|--help) print_help; exit 0 ;;
        -e|--extension) EXTENSION="$2"; shift 2 ;;
        -n|--number-per-folder) NUMBER_PER_FOLDER="$2"; shift 2 ;;
        -p|--folder-prefix) FOLDER_PREFIX="$2"; shift 2 ;;
        -s|--shuffle) SHUFFLE=true; shift ;;
        -m|--multiprocess-percent-cores) PARALLEL_FRACTION="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "Internal error!" >&2; exit 1 ;;
    esac
done

# === VALIDATE ===
[ -z "$EXTENSION" ] && echo "ERROR: -e required" >&2 && exit 1
[ -z "$NUMBER_PER_FOLDER" ] && echo "ERROR: -n required" >&2 && exit 1

# === PARALLEL JOBS ===
total_cores=$(nproc 2>/dev/null || echo 1)
parallel_jobs=$(awk "BEGIN {printf \"%d\", $PARALLEL_FRACTION * $total_cores}")
[ "$parallel_jobs" -lt 1 ] && parallel_jobs=1
echo "Using $parallel_jobs parallel job(s) ($PARALLEL_FRACTION of $total_cores cores)"

# === FIND FILES ===
mapfile -t all_files < <(find . -maxdepth 1 -type f -iname "*.$EXTENSION" -printf "%P\n" 2>/dev/null || true)
num_files=${#all_files[@]}
[ $num_files -eq 0 ] && echo "No *.$EXTENSION files found." && exit 0
echo "Found $num_files file(s)."

# === SHUFFLE ===
if [ "$SHUFFLE" = true ]; then
    echo "Shuffling..."
    for i in $(seq $((num_files - 1)) -1 1); do
        j=$((RANDOM % (i + 1)))
        tmp="${all_files[i]}"
        all_files[i]="${all_files[j]}"
        all_files[j]="$tmp"
    done
fi

# === BUILD PARALLEL MV COMMANDS ===
# Each command: mkdir -p dest && mv file1 file2 ... dest/
pad_digits=${#num_files}
commands=()
folder_num=0
batch_files=()

for idx in "${!all_files[@]}"; do
    if [ $((idx % NUMBER_PER_FOLDER)) -eq 0 ]; then
        # Flush previous batch if exists
        if [ ${#batch_files[@]} -gt 0 ]; then
            padded=$(printf "%0${pad_digits}d" "$folder_num")
            dest="${FOLDER_PREFIX}${padded}"
            commands+=("mkdir -p '$dest' && mv ${batch_files[*]} '$dest/'")
        fi
        folder_num=$((folder_num + 1))
        batch_files=()
    fi
    # Quote each filename to handle spaces
    batch_files+=("'${all_files[idx]}'")
done

# Flush last batch
if [ ${#batch_files[@]} -gt 0 ]; then
    padded=$(printf "%0${pad_digits}d" "$folder_num")
    dest="${FOLDER_PREFIX}${padded}"
    commands+=("mkdir -p '$dest' && mv ${batch_files[*]} '$dest/'")
fi

echo "Built ${#commands[@]} mv command(s) (one per folder)."

# === EXECUTE IN PARALLEL ===
printf "%s\n" "${commands[@]}" | xargs -P "$parallel_jobs" -I {} bash -c "{}"

echo "Done. Moved $num_files files into $folder_num folder(s)."