#!/usr/bin/env bash
# DESCRIPTION
function print_help {
    cat << EOF
Recursively walks through the current directory and all its
subdirectories, launching an instance of VoidTools Everything.exe for each
directory found. For each directory, it opens an Everything search window
pre-filtered to that path with an optional search string.

Use case: Quickly preview files (e.g., images with thumbnails) across many
subfolders by stepping through one folder at a time, preserving Everything's
last view settings (thumbnails, sorting, etc.).

DEPENDENCIES
============
- Everything.exe must be installed and in your PATH (or accessible via command -v)
- MSYS2 Bash on Windows 10 (or any environment where Everything.exe and Bash coexist)

USAGE
With this script in you PATH, run
  ${PROGNAME} [-s|--search-string "SEARCH"] [-n|--start-folder-number N] [--help]

OPTIONS:
  -s, --search-string SEARCH   Optional search term to pass to Everything.exe
  -n, --start-folder-number N         Start from the Nth folder (1-indexed). Skips first N-1 folders.
  -h, --help                   Show this help message

EXAMPLES
========
Search for ".png" in current folder and all subfolders, one by one
   ${PROGNAME} -s ".png"

Open Everything for every subfolder (no search filter)
   ${PROGNAME}

Open Everything in current folder and all subfolders, one by one,
with a search string of .pdf, skipping to the 25th listed folder
  ${PROGNAME} -s ".pdf" -n 25

Show help
   ${PROGNAME} --help

NOTES
=====
- This attempts to open Everything.exe in a background Bash process;
type any key after each Everything window opens to proceed to the next folder.
- To exit early, press Ctrl+C.
- If there are hundreds of subfolders, you will be prompted hundreds of times.
- Search string is optional; if omitted, Everything shows all files in that path.
- Paths are passed as-is to Everything.exe (no conversion). Tested with MSYS2.
- Everything.exe must be in your PATH
- Paths are passed as-is to Everything.exe (no conversion)
- Tested with MSYS2 on Windows 10

BEHAVIOR:
  - Finds all directories recursively starting from current directory (including .)
  - For each directory, runs: 'Everything.exe' -path "directory" -s "search-string"
  - Waits for you to press any key before launching the next instance
  - Press Ctrl+C to abort early
  - With -n N: Starts processing from the Nth folder (N must be >= 1)
  - If N exceeds total folder count, nothing is processed
EOF
}

# CODE
set -e  # Exit on error, but we handle gracefully

# Parse command line arguments
SEARCH_STRING=""
START_NUMBER=1
OPTS=$(getopt -o hs:n: --long help,search-string:,start-folder-number: -n "$PROGNAME" -- "$@")
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
        -s|--search-string)
            SEARCH_STRING="$2"
            shift 2
            ;;
        -n|--start-folder-number)
            START_NUMBER="$2"
            # Validate that START_NUMBER is a positive integer
            if ! [[ "$START_NUMBER" =~ ^[1-9][0-9]*$ ]]; then
                echo "ERROR: --start-folder-number must be a positive integer (>= 1). Got: $START_NUMBER" >&2
                exit 1
            fi
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error: Unknown option $1" >&2
            exit 1
            ;;
    esac
done

# Locate Everything.exe
EVERYTHING_PATH=$(command -v Everything.exe)
if [ -z "$EVERYTHING_PATH" ]; then
    echo "ERROR: Everything.exe not found in PATH. Please install Everything or add it to PATH."
    exit 1
fi

# Find all directories recursively (including current directory .)
# Using find with -type d, printing full path relative to current dir
# Use process substitution to read into array safely (no spaces issues)
mapfile -t ALL_DIRS < <(find . -type d 2>/dev/null | sort)

if [ ${#ALL_DIRS[@]} -eq 0 ]; then
    echo "No directories found (unreachable because '.' is always there). Exiting."
    exit 0
fi

# Apply start-folder-number slicing (skip first N-1 folders)
if [ $START_NUMBER -gt 1 ]; then
    SLICE_START=$((START_NUMBER - 1))
    if [ $SLICE_START -ge ${#ALL_DIRS[@]} ]; then
        echo "Start number $START_NUMBER exceeds total folders (${#ALL_DIRS[@]}). Nothing to process."
        exit 0
    fi
    ALL_DIRS=("${ALL_DIRS[@]:$SLICE_START}")
fi

echo "Found ${#ALL_DIRS[@]} directories to process (after applying start-folder-number=$START_NUMBER)."
echo "Using Everything.exe at: $EVERYTHING_PATH"
if [ -n "$SEARCH_STRING" ]; then
    echo "Search string: $SEARCH_STRING"
else
    echo "Search string: (none — will show all files in each path)"
fi
echo "Press any key after each Everything window opens to continue to the next folder."
echo "Press Ctrl+C to abort early."
echo

# Iterate and launch
for DIR in "${ALL_DIRS[@]}"; do
    # Remove leading "./" for cleaner display (optional)
    DISPLAY_DIR="${DIR#./}"
    [ -z "$DISPLAY_DIR" ] && DISPLAY_DIR="."

    echo "========================================="
    echo "Launching Everything for: $DISPLAY_DIR"
    echo "Command: '$EVERYTHING_PATH' -path \"$DIR\" -s \"$SEARCH_STRING\""

    # Launch Everything in background so it doesn't block the read prompt
    "$EVERYTHING_PATH" -path "$DIR" -s "$SEARCH_STRING" &
    EVERYTHING_PID=$!

    # Wait a moment for window to appear (adjust if needed)
    sleep 0.5

    echo "Press any key to proceed to next folder..."
    # Use read -n 1 for any key; if that fails, user can press Enter
    read -n 1 -s -r
    echo ""  # newline after keypress

    # Optionally kill Everything? No — leave it open per your spec.
    # Just move on.
done

echo "========================================="
echo "All directories processed. Exiting."