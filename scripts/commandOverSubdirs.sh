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
OPTIONAL. -d --depth, an integer, which is how many folders deep to search for folders to execute command -c in. If omitted, defaults to all subfolders under the current directory. If 0, you may as well not use this script and just run a command by itself, as it only operates on the current directory. If 1, it operates on all subfolders one level deep (all folders within the current folder, but not any of their subfolders), and if 2, two levels deep (all folders within those but no deeper), and so on.

# NOTE
Short forms of switches must have the value immediately after without any space, e.g. -d2

EXAMPLES
For example, to run a Python script reduceIMGsimilarAssistant.py across all subdirectories within the current directory (default), run:
    $PROGNAME --command "python /path_to/reduceIMGsimilarAssistant.py"
Or to do the same but only one folder deep:
    $PROGNAME --command "python /path_to/reduceIMGsimilarAssistant.py" -d 1
EOF
}

# CODE
if [ $# -eq 0 ]; then
    print_help
    exit 0
fi

# The following variable, being empty, is seen by bash as undefined and returns a false check for existance. find searches all subdirectories if you don't specify maxdepth; this variable being undefined results in that default. But if -d --depth, an integer, is passed to this script, it will result in constructing a --maxdepth <value of -d> switch, so that directories are only searched to that depth:
SUBDIRECTORIES_MAXDEPTH=
# SWITCH PARSING MAY OVERRIDE THAT ^ :

# Parse arguments using getopt
OPTS=$(getopt -o c:d:h --long command:,depth:,help -n "$PROGNAME" -- "$@")
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
if [ -n "$SUBDIRECTORIES_MAXDEPTH" ]; then
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
echo ""

# Execute command in each directory
for dir in "${dirs[@]}"; do
    echo ">>> Entering: $dir"
    pushd . &>/dev/null
    cd "$dir"
    eval "$COMMAND"
    popd &>/dev/null
    echo ">>> Returned to: $(pwd)"
    echo ""
done

echo "Done."
exit 0