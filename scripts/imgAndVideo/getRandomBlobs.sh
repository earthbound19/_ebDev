#!/bin/bash
#
# DESCRIPTION
# Creates N randomly shaped "blob" images using either the fast Python implementation randomBlob.py, 
# or the legacy bash/ImageMagick implementation randomBlob.sh

# USAGE
#    getRandomBlobs.sh [options] -- [switches to pass to randomBlob]
#
# Options:
#   -n, --number NUM         Number of blobs to generate (required)
#   -s, --scriptversion VER  Script version: 'python' (default) or 'bash'
#   
#   All other switches are passed directly to the underlying randomBlob script.
#   For full list of randomBlob switches, see randomBlob.py --help
#
# Examples:
#   getRandomBlobs.sh -n 100
#   getRandomBlobs.sh -n 100 --pts 15 -l 5 --drawtype spline -T 0.5
#   getRandomBlobs.sh -n 50 -s bash --drawtype line -S 42
#   getRandomBlobs.sh -n 20 --typeoutput svg --cpu 75

PROGNAME=$(basename $0)

function print_halp {
    cat << EOF
Usage: $PROGNAME [options] -- [switches to pass to randomBlob]

Required:
  -n, --number NUM         Number of blobs to generate

Options:
  -s, --scriptversion VER  Script version: 'python' (default) or 'bash'
  -h, --help               Show this help

All other switches are passed directly to the underlying randomBlob script.
For full list of randomBlob switches, see randomBlob.py --help

Examples:
  $PROGNAME -n 100
  $PROGNAME -n 100 --pts 15 -l 5 --drawtype spline -T 0.5
  $PROGNAME -n 50 -s bash --drawtype line -S 42
  $PROGNAME -n 20 --typeoutput svg --cpu 75
EOF
}

function check_space_in_opt_arg {
    if [ "$2" == "" ]; then 
        echo "ERROR: No value or a space (resulting in empty value) passed after optional switch $1. Pass a value without any space after $1 (for example: $1""value""), or if a default is available, don't pass $1, and the default will be used. Exit."; 
        exit 4; 
    fi
}

# Print help if nothing passed to script
if [ ${#@} == 0 ]; then
    echo "No options provided. Printing help (-h)."
    print_halp
    exit 1
fi

# Parse command line arguments with getopt
OPTS=$(getopt -o hn:s: --long help,number:,scriptversion: -n $PROGNAME -- "$@")

if [ $? != 0 ]; then 
    echo "Failed parsing options." >&2 
    exit 1 
fi

eval set -- "$OPTS"

# Set defaults
SCRIPT_VERSION="python"
NUMBER=""  # Required, no default

# Collect all remaining arguments to pass through
PASSTHROUGH_ARGS=()

while true; do
    case "$1" in
        -h | --help ) 
            print_halp
            exit 0 
            ;;
        -n | --number )
            check_space_in_opt_arg $1 $2
            NUMBER=$2
            shift 2
            ;;
        -s | --scriptversion )
            check_space_in_opt_arg $1 $2
            if [[ "$2" != "python" && "$2" != "bash" ]]; then
                echo "ERROR: scriptversion must be 'python' or 'bash'"
                exit 1
            fi
            SCRIPT_VERSION=$2
            shift 2
            ;;
        -- ) 
            shift
            # Everything after -- goes to passthrough
            PASSTHROUGH_ARGS+=("$@")
            break 
            ;;
        * ) 
            # If we get here without --, treat as passthrough
            PASSTHROUGH_ARGS+=("$1")
            shift
            ;;
    esac
done

# Throw error and exit if mandatory argument(s) missing
if [ -z "$NUMBER" ]; then
    echo "ERROR: Number of blobs (-n | --number) is required"
    exit 1
fi

# Get script path
if [ "$SCRIPT_VERSION" = "python" ]; then
    SCRIPT_PATH=$(command -v randomBlob.py 2>/dev/null)
    if [ -z "$SCRIPT_PATH" ]; then
        echo "ERROR: Could not find randomBlob.py. Please ensure it's in PATH or use -s bash"
        exit 1
    fi
    SCRIPT_CMD="python \"$SCRIPT_PATH\""
else
    SCRIPT_PATH=$(command -v randomBlob.sh 2>/dev/null)
    if [ -z "$SCRIPT_PATH" ]; then
        echo "ERROR: Could not find randomBlob.sh. Please ensure it's in PATH"
        exit 1
    fi
    SCRIPT_CMD="bash \"$SCRIPT_PATH\""
fi

echo "Generating $NUMBER random blob images using $SCRIPT_VERSION script ($SCRIPT_PATH)..."
echo "Pass-through switches: ${PASSTHROUGH_ARGS[@]}"

for i in $(seq $NUMBER); do
    # Generate seed if not present in passthrough
    seed_in_passthrough=0
    for arg in "${PASSTHROUGH_ARGS[@]}"; do
        if [[ "$arg" == "-S" ]]; then
            seed_in_passthrough=1
            break
        fi
    done
    
    if [ $seed_in_passthrough -eq 0 ]; then
        # Generate random seed in Python's valid range (1 to 2^32-1)
        while true; do
            current_seed=$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')
            [ "$current_seed" -ne 0 ] && break
        done
        seed_arg="-S $current_seed"
    else
        current_seed="(from user)"
        seed_arg=""
    fi
    
    # Determine number of points (randomize if not specified in passthrough)
    pts_in_passthrough=0
    for arg in "${PASSTHROUGH_ARGS[@]}"; do
        if [[ "$arg" == "-n" ]]; then
            pts_in_passthrough=1
            break
        fi
    done
    
    if [ $pts_in_passthrough -eq 0 ]; then
        current_numpts=$(( 4 + (RANDOM % 22) ))
        numpts_arg="-n $current_numpts"
    else
        numpts_arg=""
        current_numpts="(from user)"
    fi
    
    # Determine line width (randomize if not specified in passthrough)
    lw_in_passthrough=0
    for arg in "${PASSTHROUGH_ARGS[@]}"; do
        if [[ "$arg" == "-l" ]]; then
            lw_in_passthrough=1
            break
        fi
    done
    
    if [ $lw_in_passthrough -eq 0 ]; then
        current_linewidth=$(( 8 + (RANDOM % 21) ))
        linewidth_arg="-l $current_linewidth"
    else
        linewidth_arg=""
        current_linewidth="(from user)"
    fi
    
    # Build command
    cmd="$SCRIPT_CMD $seed_arg $numpts_arg $linewidth_arg ${PASSTHROUGH_ARGS[@]}"
    
    # Remove extra spaces
    cmd=$(echo "$cmd" | tr -s ' ')
    
    echo "[$i/$NUMBER] Generating blob (seed: $current_seed, points: $current_numpts, linewidth: $current_linewidth)"
    echo "  Command: $cmd"
    
    if eval $cmd; then
        echo "  -> Success"
    else
        echo "  -> Failed with error code $?"
        # Continue on failure
    fi
done

echo "Done! Generated $NUMBER blob images."