#!/bin/bash
PROGNAME=$(basename "$0")

print_help() {
    cat << EOF
---
$PROGNAME
---
# DESCRIPTION
Executes command -c --command (any valid bash command enclosed in double or single quotes) in all subdirectories (default), or to depth -d --depth.

# USAGE
Call this script with these parameters:
REQUIRED. -c --command, and valid bash command enclosed in double or single quote marks.
OPTIONAL. -d --depth, an integer, which is how many folders deep to search for folders to execute command -c in. If omitted, defaults to 1, which is all folders within the current directory, but not the folders beneath them. To search subfolders of those subfolders (2 levels down), pass -d2. If passed as 0, you may as well not use this script and just run a command by itself, as it only operates on the current directory. To search all subfolders and all their subfolders to every depth, pass -d-1 (a switch value of negative 1.) NOTE that this is not a bash convention; it's a convention of this script. (Bash convention is to pass nothing for maxdepth if you want infinite depth.)
OPTIONAL. -s --skip-to-folder-number <integer>, skips the first (s-1) folders and starts executing the command at folder number s (1-indexed). For example, -s 3 would skip folders 1 and 2, and start executing at folder 3. This is useful for resuming interrupted operations.

# NOTE
Short forms of switches must have the value immediately after without any space, e.g. -d2 or -s3

EXAMPLES
For example, to run a Python script reduceIMGsimilarAssistant.py across all subdirectories within the current directory (default), run:
    $PROGNAME --command "python /path_to/reduceIMGsimilarAssistant.py"
Or to do the same but only one folder deep:
    $PROGNAME --command "python /path_to/reduceIMGsimilarAssistant.py" -d 1
Or to skip the first 5 folders and start at folder 6:
    $PROGNAME --command "python /path_to/reduceIMGsimilarAssistant.py" -s 6
EOF
}

# CODE
if [ $# -eq 0 ]; then
    print_help
    exit 0
fi

# The following variable, being empty, is seen by bash as undefined and returns a false check for existance. find searches all subdirectories if you don't specify maxdepth; this variable being undefined results in that default. But if -d --depth, an integer, is passed to this script, it will result in constructing a --maxdepth <value of -d> switch, so that directories are only searched to that depth:
SUBDIRECTORIES_MAXDEPTH=1
# SKIP_TO_FOLDER_NUMBER defaults to 1 (start at first folder)
SKIP_TO_FOLDER_NUMBER=1
# SWITCH PARSING MAY OVERRIDE THAT ^ :

# Parse arguments using getopt
OPTS=$(getopt -o c:d:s:h --long command:,depth:,skip-to-folder-number:,help -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options. Use --help for usage." >&2
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -c|--command)
            COMMAND="$2"
            shift 2
            ;;
        -d|--depth)
            SUBDIRECTORIES_MAXDEPTH="$2"
            shift 2
            ;;
        -s|--skip-to-folder-number)
            SKIP_TO_FOLDER_NUMBER="$2"
            shift 2
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
            echo "Internal error!" >&2
            exit 1
            ;;
    esac
done

# Validate required -c
if [ -z "$COMMAND" ]; then
    echo "ERROR: -c/--command is required. Use --help for usage." >&2
    exit 1
fi

# Build find command with -maxdepth if depth was specified
if [ -n "$SUBDIRECTORIES_MAXDEPTH" ] && [ "$SUBDIRECTORIES_MAXDEPTH" != "-1" ]; then
    subdirSearchCommand="-maxdepth $SUBDIRECTORIES_MAXDEPTH"
    echo "Searching directories to depth: $SUBDIRECTORIES_MAXDEPTH"
else
    subdirSearchCommand=""
    echo "Searching all subdirectories recursively"
fi

# Find all directories (excluding current directory unless depth=0)
if [ "$SUBDIRECTORIES_MAXDEPTH" = "0" ]; then
    dirs=(".")
else
    mapfile -t dirs < <(find . $subdirSearchCommand -mindepth 1 -type d -printf "%P\n" 2>/dev/null || true)
fi

if [ ${#dirs[@]} -eq 0 ]; then
    if [ "$SUBDIRECTORIES_MAXDEPTH" = "0" ]; then
        echo "Operating on current directory only:"
    else
        echo "No subdirectories found."
        exit 0
    fi
else
    echo "Found ${#dirs[@]} director(ies) to process"
fi

# Apply skip-to-folder-number logic
if [ "$SKIP_TO_FOLDER_NUMBER" -gt 1 ]; then
    if [ "$SKIP_TO_FOLDER_NUMBER" -gt ${#dirs[@]} ]; then
        echo "WARNING: Skip value ($SKIP_TO_FOLDER_NUMBER) exceeds number of directories (${#dirs[@]}). Nothing to process."
        exit 0
    fi
    skip_count=$((SKIP_TO_FOLDER_NUMBER - 1))
    echo "Skipping first $skip_count folder(s), starting at folder $SKIP_TO_FOLDER_NUMBER"
    dirs=("${dirs[@]:$skip_count}")
fi

echo "Processing ${#dirs[@]} director(ies) starting from folder $SKIP_TO_FOLDER_NUMBER"
echo ""

# Execute command in each directory
current_folder_number=$SKIP_TO_FOLDER_NUMBER
for dir in "${dirs[@]}"; do
    echo ">>> [$current_folder_number] Entering: $dir"
    pushd . &>/dev/null
    cd "$dir"
    eval "$COMMAND"
    popd &>/dev/null
    echo ">>> Returned to: $(pwd)"
    echo ""
    ((current_folder_number++))
done

echo "Done."
exit 0