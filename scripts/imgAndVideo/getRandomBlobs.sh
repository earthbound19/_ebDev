# DESCRIPTION
# Creates N ($1) randomly shaped "blob" images using a clean-room reimplementation
# of Fred Weinhaus's randomblob concept.

# USAGE
# From a directory you wish to fill with so many random blob images, run with one parameter, which is the number of blobs to make, e.g.:
#    getRandomBlobs.sh 100

# DEPENDENCIES
# - bash 4.0+ (for seq command)
# - randomBlob.sh (the clean-room reimplementation in this repository) in your PATH or current directory
# - ImageMagick 7 (required by randomBlob.sh)
# - bc (basic calculator) - required by randomBlob.sh
# - od (octal dump) - for reading /dev/urandom
# - sed, tr - for text processing

# Platform Support:
# - Linux/Unix: Works natively
# - macOS: Works with standard tools
# - Windows/Cygwin: Requires Cygwin with necessary packages (coreutils, sed, etc.)

# NOTES
# - Known issue: Random images may occasionally be blank. This could happen if:
#   * Cygwin's /dev/urandom entropy is exhausted (rare)
#   * randomBlob.sh generates points outside the image bounds
#   * The combination of parameters produces an empty result
# - This script now uses the clean-room reimplementation of randomBlob.sh
# - For ImageMagick 7 compatibility, the underlying randomBlob.sh uses 'magick' not 'convert'
# - These blobs could be animated by cycling the spline tension from negative to positive values
# - Using the -d straight parameter (as this script does) is significantly faster than splines
# - The seed value from /dev/urandom can be any size; the randomBlob.sh script will handle it

# TIPS FOR CUSTOMIZATION
# To vary more parameters, you can uncomment and modify lines in the loop below:
#   - Spline tension: add -T $tension to the command
#   - Distribution type: add -k gaussian -g $sigma
#   - Inner region size: add -i $isize
#   - Blur amount: add -b $blur
#   - Threshold: add -t $threshold

# CODE
# -----------------------------------------------------------------------------

# Check for required parameter
if [ $# -ne 1 ]; then
    echo "Error: Please specify the number of blobs to generate"
    echo "Usage: getRandomBlobs.sh <number_of_blobs>"
    exit 1
fi

# Validate input is a positive integer
if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -eq 0 ]; then
    echo "Error: Parameter must be a positive integer"
    exit 1
fi

# Check if randomBlob.sh exists and is executable
if ! command -v randomBlob.sh >/dev/null 2>&1; then
    # Also check current directory
    if [ -f "./randomBlob.sh" ] && [ -x "./randomBlob.sh" ]; then
        # Add current directory to PATH for this script
        PATH=".:$PATH"
    else
        echo "Error: randomBlob.sh not found in PATH or current directory"
        echo "Please ensure the clean-room reimplementation of randomBlob.sh is available"
        exit 1
    fi
fi

# Check for required tools
for cmd in od sed tr seq; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "Error: Required tool '$cmd' not found"
        exit 1
    fi
done

# Check for /dev/urandom availability
if [ ! -r "/dev/urandom" ]; then
    echo "Warning: /dev/urandom not readable, falling back to \$RANDOM"
    use_fixed_random=1
fi

echo "Generating $1 random blob images..."

for i in $(seq $1)
do
	# Get a random seed from /dev/urandom if available, otherwise use bash's RANDOM
	if [ -z "$use_fixed_random" ]; then
		# Read 8 bytes from /dev/urandom as a decimal number
		seed=$(od -vAn -N8 -tu8 < /dev/urandom | tr -d ' \n\r')
		# Ensure we have a valid number (od might produce leading spaces)
		seed=${seed:-0}
	else
		# Fallback to bash's RANDOM (only 15-bit range)
		seed=$RANDOM
	fi

	# Use string comparison instead of arithmetic, to avoid errors about expected integer expressions
	if [ -z "$seed" ] || [ "$seed" = "0" ]; then
		seed=$(( RANDOM + 1 ))
	fi
    
    # Generate random parameters
    # Number of points: 3-13 (3 + 0-10)
    numRandomPoints=$(( 3 + (RANDOM % 11) ))
    
    # Line width: 3-13 (3 + 0-10)
    lineWidth=$(( 3 + (RANDOM % 11) ))
    
    # Fixed parameters
    interpolationPoints=1
    
    # Create output filename - using parameter expansion instead of sed for clarity
    outfile="randomBlob_S${seed}_n${numRandomPoints}_p${interpolationPoints}_l${lineWidth}.png"
    
    # Build and execute command
    command="randomBlob.sh -S $seed -n $numRandomPoints -p $interpolationPoints -l $lineWidth -d straight \"$outfile\""
    
    echo "[$i/$1] Generating: $outfile"
    
    # Execute the command
    if eval $command; then
        echo "  -> Success"
    else
        echo "  -> Failed with error code $?"
    fi
done

echo "Done! Generated $1 blob images."