#!/bin/bash
#
# DESCRIPTION
# Creates N randomly shaped "blob" images using either the fast Python implementation randomBlobs.py, or the legacy bash/ImageMagick implementation randomBlob.sh

# USAGE
#    getRandomBlobs.sh [options]
#
# Options:
#   -n, --number NUM         Number of blobs to generate (required)
#   -s, --scriptversion VER  Script version: 'python' (default) or 'bash'
#   --newswitches "SWITCHES" Additional switches for Python version (fails if using bash)
#   
#   Common switches (with defaults shown):
#     --pts, --numpts NUM     Fixed number of points per blob (default: random 4-22 per blob)
#     -l, --linewidth WIDTH   Width of connecting lines (default: random 8-21 per blob)
#     -p, --pixinc INC        Pixel increment for splines (default: 1)
#     -d, --drawtype TYPE     Draw type: 'line' or 'spline' (default: 'spline')
#     -T, --tension VAL       Spline tension (default: 0)
#     -C, --continuity VAL    Spline continuity (default: 0)
#     -B, --bias VAL          Spline bias (default: 0)
#     -k, --kind TYPE         Distribution: 'uniform' or 'gaussian' (default: 'uniform')
#     -g, --gsigma VAL        Gaussian sigma (default: 67)
#     -c, --constrain VAL     Constrain: 'yes' or 'no' (default: 'yes')
#     -i, --isize SIZE        Inner region size (default: 400)
#     -o, --osize SIZE        Output image size (default: 512)
#     -b, --blur SIGMA        Gaussian blur sigma (default: 11)
#     -t, --thresh PERCENT    Threshold percentage (default: 5)
#     -s, --shape SHAPE       Inner shape: 'square' or 'disk' (default: 'disk')
#     -f, --file FILE         Point pairs file (exact count)
#     -F, --file2 FILE        Point pairs file (indexed)
#     -S, --seed SEED         Random seed (works for both bash and python)
#   
#   -h, --help                Show this help
#
# Examples:
#   getRandomBlobs.sh -n 100 --pts 15 -l 5 -d spline -T 0.5
#   getRandomBlobs.sh -n 50 -s bash -l 5 -d spline -S 42
#   getRandomBlobs.sh -n 20 --newswitches "--typeoutput svg --cpu 75"

PROGNAME=$(basename $0)

function print_halp {
    cat << EOF
Usage: $PROGNAME [options]

Required:
  -n, --number NUM         Number of blobs to generate

Options:
  -s, --scriptversion VER  Script version: 'python' (default) or 'bash'
  --newswitches "SWITCHES" Additional switches for Python version (fails if using bash)
  -h, --help               Show this help

Common switches (with defaults):
  --pts, --numpts NUM      Fixed number of points per blob (default: random 4-22 per blob)
  -l, --linewidth WIDTH    Width of connecting lines (default: random 8-21 per blob)
  -p, --pixinc INC         Pixel increment for splines (default: 1)
  -d, --drawtype TYPE      Draw type: 'line' or 'spline' (default: 'spline')
  -T, --tension VAL        Spline tension (default: 0)
  -C, --continuity VAL     Spline continuity (default: 0)
  -B, --bias VAL           Spline bias (default: 0)
  -k, --kind TYPE          Distribution: 'uniform' or 'gaussian' (default: 'uniform')
  -g, --gsigma VAL         Gaussian sigma (default: 67)
  -c, --constrain VAL      Constrain: 'yes' or 'no' (default: 'yes')
  -i, --isize SIZE         Inner region size (default: 400)
  -o, --osize SIZE         Output image size (default: 512)
  -b, --blur SIGMA         Gaussian blur sigma (default: 11)
  -t, --thresh PERCENT     Threshold percentage (default: 5)
  -s, --shape SHAPE        Inner shape: 'square' or 'disk' (default: 'disk')
  -f, --file FILE          Point pairs file (exact count)
  -F, --file2 FILE         Point pairs file (indexed)
  -S, --seed SEED          Random seed (works for both bash and python)

Examples:
  $PROGNAME -n 100
  $PROGNAME -n 50 -s bash -l 5 -d spline -S 42
  $PROGNAME -n 20 --newswitches "--typeoutput svg --cpu 75"
EOF
}

function check_space_in_opt_arg {
    if [ "$2" == "" ]; then 
        echo "ERROR: No value or a space (resulting in empty value) passed after optional switch $1. Pass a value without any space after $1 (for example: $1""value""), or if a default is available, don't pass $1, and the default will be used. Exit."; 
        exit 4; 
    fi
}

function get_python_script_path {
    # Try to find randomBlob.py in common locations
    local script_name="randomBlob.py"
    local search_paths=(
        "."
        "./scripts"
        "$HOME/bin"
        "/usr/local/bin"
        "/usr/bin"
    )
    
    # Check if getFullPathToFile.sh exists and use it
    if command -v getFullPathToFile.sh >/dev/null 2>&1; then
        local path=$(getFullPathToFile.sh "$script_name")
        if [ -n "$path" ] && [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    fi
    
    # Fallback: search common paths
    for path in "${search_paths[@]}"; do
        if [ -f "$path/$script_name" ]; then
            echo "$path/$script_name"
            return 0
        fi
    done
    
    # Last resort: try to find in PATH
    local path=$(command -v "$script_name" 2>/dev/null)
    if [ -n "$path" ]; then
        echo "$path"
        return 0
    fi
    
    return 1
}

# Notify of use of defaults if no parameters passed
if [ ${#@} == 0 ]; then
    echo "No options provided. Use -h for help."
    print_halp
    exit 1
fi

# Parse command line arguments with getopt
# Note: The colon after a letter means it takes an argument
OPTS=$(getopt -o hn:s:l:p:d:T:C:B:k:g:c:i:o:b:t:s:f:F:S: --long help,number:,scriptversion:,newswitches:,numpts:,pts:,linewidth:,pixinc:,drawtype:,tension:,continuity:,bias:,kind:,gsigma:,constrain:,isize:,osize:,blur:,thresh:,shape:,file:,file2:,seed: -n $PROGNAME -- "$@")

if [ $? != 0 ]; then 
    echo "Failed parsing options." >&2 
    exit 1 
fi

eval set -- "$OPTS"

# Set defaults for common parameters
SCRIPT_VERSION="python"
NEW_SWITCHES=""
NUMBER=""  # Required, no default

# Common parameter defaults
NUM_PTS=""  # Special: will be randomized per blob if not set
LINE_WIDTH=""  # Special: will be randomized per blob if not set
PIXINC="1"
DRAWTYPE="spline"
TENSION="0"
CONTINUITY="0"
BIAS="0"
KIND="uniform"
GSIGMA="67"
CONSTRAIN="yes"
ISIZE="400"
OSIZE="512"
BLUR="11"
THRESH="5"
SHAPE="disk"
FILE=""
FILE2=""
SEED=""  # Works for both bash and python

# Build array to collect pass-through arguments
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
        --newswitches )
            check_space_in_opt_arg $1 $2
            NEW_SWITCHES=$2
            shift 2
            ;;
        # Handle numpts (with both --pts and --numpts for convenience)
        --pts | --numpts )
            check_space_in_opt_arg $1 $2
            NUM_PTS=$2
            PASSTHROUGH_ARGS+=("-n" "$2")
            shift 2
            ;;
        # Common switches - store values and add to passthrough
        -l | --linewidth )
            check_space_in_opt_arg $1 $2
            LINE_WIDTH=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -p | --pixinc )
            check_space_in_opt_arg $1 $2
            PIXINC=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -d | --drawtype )
            check_space_in_opt_arg $1 $2
            if [[ "$2" != "line" && "$2" != "spline" ]]; then
                echo "ERROR: drawtype must be 'line' or 'spline'"
                exit 1
            fi
            DRAWTYPE=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -T | --tension )
            check_space_in_opt_arg $1 $2
            TENSION=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -C | --continuity )
            check_space_in_opt_arg $1 $2
            CONTINUITY=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -B | --bias )
            check_space_in_opt_arg $1 $2
            BIAS=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -k | --kind )
            check_space_in_opt_arg $1 $2
            if [[ "$2" != "uniform" && "$2" != "gaussian" ]]; then
                echo "ERROR: kind must be 'uniform' or 'gaussian'"
                exit 1
            fi
            KIND=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -g | --gsigma )
            check_space_in_opt_arg $1 $2
            GSIGMA=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -c | --constrain )
            check_space_in_opt_arg $1 $2
            if [[ "$2" != "yes" && "$2" != "no" ]]; then
                echo "ERROR: constrain must be 'yes' or 'no'"
                exit 1
            fi
            CONSTRAIN=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -i | --isize )
            check_space_in_opt_arg $1 $2
            ISIZE=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -o | --osize )
            check_space_in_opt_arg $1 $2
            OSIZE=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -b | --blur )
            check_space_in_opt_arg $1 $2
            BLUR=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -t | --thresh )
            check_space_in_opt_arg $1 $2
            THRESH=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -s | --shape )
            check_space_in_opt_arg $1 $2
            if [[ "$2" != "square" && "$2" != "disk" ]]; then
                echo "ERROR: shape must be 'square' or 'disk'"
                exit 1
            fi
            SHAPE=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -f | --file )
            check_space_in_opt_arg $1 $2
            FILE=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -F | --file2 )
            check_space_in_opt_arg $1 $2
            FILE2=$2
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -S | --seed )
            check_space_in_opt_arg $1 $2
            SEED=$2
            # Add to passthrough for BOTH versions (seed works everywhere)
            PASSTHROUGH_ARGS+=("$1" "$2")
            shift 2
            ;;
        -- ) 
            shift
            break 
            ;;
        * ) 
            break 
            ;;
    esac
done

# Throw error and exit if mandatory argument(s) missing
if [ -z "$NUMBER" ]; then
    echo "ERROR: Number of blobs (-n | --number) is required"
    exit 1
fi

# Validate NEW_SWITCHES with bash version
if [ "$SCRIPT_VERSION" = "bash" ] && [ -n "$NEW_SWITCHES" ]; then
    echo "ERROR: --newswitches cannot be used with bash script version (these switches are Python-only features)"
    exit 1
fi

# Get Python script path if needed
PYTHON_SCRIPT=""
if [ "$SCRIPT_VERSION" = "python" ]; then
    PYTHON_SCRIPT=$(get_python_script_path)
    if [ $? -ne 0 ] || [ -z "$PYTHON_SCRIPT" ]; then
        echo "ERROR: Could not find randomBlob.py. Please ensure it's in PATH or use -s bash"
        exit 1
    fi
    echo "Using Python script: $PYTHON_SCRIPT"
fi

echo "Generating $NUMBER random blob images using $SCRIPT_VERSION script..."
echo "Common parameters: numpts=${NUM_PTS:-random}, linewidth=${LINE_WIDTH:-random}, pixinc=$PIXINC, drawtype=$DRAWTYPE, tension=$TENSION, continuity=$CONTINUITY, bias=$BIAS, kind=$KIND, gsigma=$GSIGMA, constrain=$CONSTRAIN, isize=$ISIZE, osize=$OSIZE, blur=$BLUR, thresh=$THRESH, shape=$SHAPE"

for i in $(seq $NUMBER); do
    # Determine number of points (fixed if set by user, otherwise random)
    if [ -z "$NUM_PTS" ]; then
        current_numpts=$(( 4 + (RANDOM % 22) ))
        numpts_arg="-n $current_numpts"
    else
        numpts_arg=""  # Already in PASSTHROUGH_ARGS
        current_numpts=$NUM_PTS
    fi
    
    # Determine line width (fixed if set by user, otherwise random)
    if [ -z "$LINE_WIDTH" ]; then
        current_linewidth=$(( 8 + (RANDOM % 21) ))
        linewidth_arg="-l $current_linewidth"
    else
        linewidth_arg=""  # Already in PASSTHROUGH_ARGS
        current_linewidth=$LINE_WIDTH
    fi
    
    # Create output filename
    if [ -n "$SEED" ]; then
        # User provided a seed, use it in filename
        outfile="randomBlob_S${SEED}_n${current_numpts}_p${PIXINC}_l${current_linewidth}.png"
    else
        # No seed provided, use timestamp
        timestamp=$(date +%s%N | cut -b1-13)
        outfile="randomBlob_${timestamp}_n${current_numpts}_p${PIXINC}_l${current_linewidth}.png"
    fi
    
    # Build command with debug and save for investigation
    if [ "$SCRIPT_VERSION" = "bash" ]; then
        # Bash/IM7 version
        cmd="randomBlob.sh ${PASSTHROUGH_ARGS[@]} $numpts_arg $linewidth_arg --debug --save \"$outfile\""
    else
        # Python version; for connected lins save and debug add --debug --save before \"$outfile\" ; OR pass those with --newswitches as:
		#    --newswitches "-debug --save"
        cmd="python \"$PYTHON_SCRIPT\" ${PASSTHROUGH_ARGS[@]} $numpts_arg $linewidth_arg $NEW_SWITCHES \"$outfile\""
    fi
    
    # Remove extra spaces
    cmd=$(echo "$cmd" | tr -s ' ')
    
    echo "[$i/$NUMBER] Generating: $outfile"
    echo "  Command: $cmd"
    
    if eval $cmd; then
        echo "  -> Success"
    else
        echo "  -> Failed with error code $?"
        # Optionally exit on first failure? For now, continue
        # exit 1
    fi
done

echo "Done! Generated $NUMBER blob images."