# DESCRIPTION
# Convert image whiteness to alpha transparency using GraphicsMagick, and either
# save as a new image or overwrite original.
# Uses grayscale-to-alpha method:
# - white becomes fully transparent
# - black remains fully opaque
# - near-white becomes mostly transparent
# - near-black becomes mostly opaque
# -- etc.
# Optional fuzz factor allows controlling color matching tolerance for near-white detection

# DEPENDENCIES
# - GraphicsMagick (gm) must be installed and in PATH
# - MSYS2 bash environment (or any bash-compatible shell)
# - Standard Unix tools: getopt, basename, find, bc (for floating point math)

# USAGE
# Options:
#   -i, --input FILENAME     Process single file only
#   -t, --type EXTENSION     Process all files with given extension in current directory
#   -r, --recursive          When used with --type, process subdirectories recursively
#   -o, --overwriteoriginal  Overwrite original files instead of creating copies that add _alpha to the
#                            base file name
#   -f, --fuzz PERCENT       Fuzz factor for color matching tolerance -- an integer or decimal
#                            between 0 to 100 (for percent). For example:
#                            15  = 15%
#                            15.5  = 15.5% (fine control)
#                            0.15  = 0.15% (NOT 15%!)
#   -h, --help               Display this help message
#
# Examples:
#   imagesGrayscaleToAlpha.sh -i image.jpg                    # Process single file -> image_alpha.jpg
#   imagesGrayscaleToAlpha.sh -t png                           # Process all PNGs in current dir
#   imagesGrayscaleToAlpha.sh -t jpg -o                         # Process all JPGs, overwrite originals
#   imagesGrayscaleToAlpha.sh -t png -r                          # Process all PNGs recursively
#   imagesGrayscaleToAlpha.sh -i photo.png -f 15                # 15% fuzz for near-white pixels
#   imagesGrayscaleToAlpha.sh -t png -f 10 -r                    # 10% fuzz on all PNGs recursively

# NOTES
# - The --input and --type options are mutually exclusive
# - When using --type, extension should be provided without dot (e.g., "png" not ".png")
# - Output files are named [basename]_alpha.[extension] unless --overwriteoriginal is used
# - Recursive mode only works with --type, not with single file
# - Original files are only modified when --overwriteoriginal is explicitly specified
#
# ABOUT THE --fuzz OPTION:
# - Uses GraphicsMagick's official "fuzz" concept for color matching tolerance
# - Fuzz calculates Euclidean distance in RGB color space
# - Pixels within fuzz% of white (in 3D RGB space) are considered "white"
# - 0%: Only exact #FFFFFF matches (pure white)
# - 15%: Colors within 15% Euclidean distance from white
# - This is functionally a threshold on "whiteness" but GraphicsMagick/ImageMagick
#   use the term "fuzz" for color matching tolerance across all operations
# - Useful for:
#   * JPEG artifacts (near-white pixels from compression)
#   * Slightly off-white paper in scanned images
#   * Removing specific color backgrounds with tolerance
#
# TECHNICAL DETAILS:
# The conversion uses a two-step process when fuzz is specified:
#   1. First, -fuzz and -transparent white identify near-white pixels based on
#      Euclidean distance in RGB space and makes them transparent
#   2. Then, grayscale-to-alpha conversion creates smooth transparency from
#      luminance values of the remaining pixels
# This preserves original RGB colors while making white/near-white areas transparent
#
# Supported formats: PNG, TIFF, GIF, and many others that support alpha channels.
# Works best with PNG and TIFF (full alpha support). Other formats that support alpha
# (GIF, WebP, PSD, BMP, etc.) may work; GraphicsMagick can read/write over 92
# formats - try any image format and verify whether it works for your use case.
# Formats without alpha support (like JPEG) will typically have transparency flattened
# to the background color, white.


# CODE
# Adapted from a getopt template bash script and GraphicsMagick documentation;
# written nearly entirely by deepseek (a code-aware Large Language Model) to
# specifics refined via collaboration with a human.
# TO DO
# - Perceptual color space selection (HCT, okHSV) for alpha via external Python +
#   coloraide script; this would allow making specific colors transparent based
#   more nearly on human perception (where sRGB does so very little).
# - Write glitch-rock music after unexpected behavior encounterd in development,
#   where a 1-bit OPAQUE alpha channel in a source image was carried over
#   into target images so we couldn't modify alpha from grayscale as expected:
# Glitch-rock band: "1-Bit Alpha Channel" - debut album: "Opaque Expectations"
# Track listing:
# "Hidden Transparency"
# "The Gremlin in the Bits"
# "Plus Matte (Radio Edit)"
# "CopyOpacity Blues"


PROGNAME=$(basename "$0")

function print_halp {
    cat << EOF
$PROGNAME - Convert image whiteness to alpha transparency

USAGE:
    $PROGNAME [OPTIONS]

OPTIONS:
    -i, --input FILENAME     Process a single file
    -t, --type EXTENSION     Process all files with given extension
    -r, --recursive          Process subdirectories recursively (with --type only)
    -o, --overwriteoriginal  Overwrite original files instead of creating copies
    -f, --fuzz PERCENT       Fuzz factor for color matching tolerance (0-100, default: 0)
    -h, --help              Show this help message

EXAMPLES:
    $PROGNAME -i image.jpg
    $PROGNAME -t png
    $PROGNAME -t jpg -o
    $PROGNAME -t png -r
    $PROGNAME -i photo.png -f 15
    $PROGNAME -t png -f 10 -r

FUZZ FACTOR:
    Enter as percentage (0-100), with optional decimals
    Examples: 
        15    = 15% (correct for most uses)
        15.5  = 15.5% (fine control)
        0.15  = 0.15% (NOT 15% - beware!)

    Note: Fuzz measures color distance, not luminance. Use for removing
    off-white backgrounds or specific color ranges.

DEPENDENCIES:
    GraphicsMagick (gm) must be installed and accessible in PATH
    bc - for floating point math in fuzz validation

EOF
}

function check_dependencies {
    if ! command -v gm &> /dev/null; then
        echo "ERROR: GraphicsMagick (gm) not found in PATH"
        echo "Please install GraphicsMagick and / or ensure it is in PATH"
        exit 1
    fi
    
    if ! command -v bc &> /dev/null; then
        echo "ERROR: bc (basic calculator) not found in PATH"
        echo "Please install bc (usually part of MSYS2 coreutils) and / or"
        echo "ensure it is in PATH"
        exit 2
    fi
}

function check_space_in_opt_arg {
    if [ "$2" == "" ]; then 
        echo "ERROR: No value or a space (resulting in empty value) passed after optional switch $1"
        echo "Pass a value without any space after $1 (for example: $1""value"")"
        exit 3
    fi
}

function validate_file_exists {
    if [ ! -f "$1" ]; then
        echo "ERROR: File '$1' does not exist"
        exit 4
    fi
}

function validate_extension {
    if [[ ! "$1" =~ ^[a-zA-Z0-9]+$ ]]; then
        echo "ERROR: Invalid extension format: '$1'"
        echo "Extension must contain only letters and numbers (no dot, e.g., 'png' not '.png')"
        exit 5
    fi
    echo "$1"
}

function validate_fuzz {
    local fuzz="$1"
    
    # Check if it's a number (integer or decimal) between 0-100
    # Examples: 0, 5, 15, 15.5, 100
    if ! [[ "$fuzz" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "ERROR: Fuzz factor must be an integer or decimal between 0-100, got: '$fuzz'"
        echo "Examples: 0, 5, 15, 15.5, 100; meaning zero, five percent, fifteen percent,"
        echo "fifteen-point-five percent, and 100 percent, respectively."
        exit 6
    fi
    
    # Check range using bc for floating point comparison
    if (( $(echo "$fuzz < 0" | bc -l) )) || (( $(echo "$fuzz > 100" | bc -l) )); then
        echo "ERROR: Fuzz factor must be an integer or decimal between 0 and 100, got: $fuzz"
        exit 7
    fi
}

function build_file_array {
    local mode="$1"
    local value="$2"
    local recursive="$3"
    local -n arr_ref="$4"  # Nameref for array return
    
    arr_ref=()  # Clear array
    
    # creates an array of one file in the case of file mode, or of all
    # files of the given type if in type mode; also files from all subdirectories
    # if recrusive mode is set.
    case "$mode" in
        "file")
            # Single file mode
            # the following function exits the script with an error if
            # the file does not exist; otherwise the script will continue
            # and $value can be safely added to the array:
            validate_file_exists "$value"
            arr_ref+=("$value")
            ;;
        "type")
            # Type mode - find files with given extension
            local ext_pattern="*.$value"
            
            if [ "$recursive" = "true" ]; then
                # Recursive find
                while IFS= read -r -d '' file; do
                    arr_ref+=("$file")
                    # here, the -z option tells sort to use null characters (\0)
                    # as line terminators instead of newlines. It's helpful because:
                    # find ... -print0 - Outputs filenames separated by null characters (\0)
                    # instead of newlines. sort -z - Reads null-terminated input and outputs
                    # null-terminated results. Without -print0 and -z, filenames with spaces,
                    # newlines, or other special characters would break.
                done < <(find . -type f -iname "$ext_pattern" -print0 | sort -z)
            else
                # Current directory only
                while IFS= read -r -d '' file; do
                    # Remove leading ./ for cleaner output
                    file="${file#./}"
                    arr_ref+=("$file")
                done < <(find . -maxdepth 1 -type f -iname "$ext_pattern" -print0 | sort -z)
            fi
            
            if [ ${#arr_ref[@]} -eq 0 ]; then
                echo "WARNING: No files found with extension '.$value'"
            fi
            ;;
    esac
}

function process_image {
    local input_file="$1"
    local overwrite="$2"
    local fuzz="$3"
    
    # Get directory, basename, and extension
    local dir=$(dirname "$input_file")
    local filename=$(basename "$input_file")
    local basename="${filename%.*}"
    local extension="${filename##*.}"
    
    # Determine output filename
    local output_file
    if [ "$overwrite" = "true" ]; then
        output_file="$input_file"
        echo "Processing: $input_file (overwriting original) [fuzz: $fuzz%]"
    else
        output_file="${dir}/${basename}_alpha.${extension}"
        echo "Processing: $input_file -> $output_file [fuzz: $fuzz%]"
    fi
    
    # Create temporary files
    local temp_input="${dir}/temp_input_$$.${extension}"
    local temp_mask="${dir}/temp_mask_$$.${extension}"
    
    # Step 1: Strip any existing alpha channel from input
    gm convert "$input_file" +matte "$temp_input"
    
    # Step 2: Create mask based on fuzz setting
    if [ "$fuzz" != "0" ]; then
        # With fuzz: first remove near-white pixels by color, then create grayscale mask
        gm convert "$temp_input" -fuzz ${fuzz}% -transparent white \
            -colorspace Gray -negate +matte "$temp_mask"
    else
        # Without fuzz: pure grayscale-to-alpha mask
        gm convert "$temp_input" -colorspace Gray -negate +matte "$temp_mask"
    fi
    
    # Step 3: Apply mask as alpha channel
    gm composite -compose CopyOpacity "$temp_mask" "$temp_input" "$output_file"
    
    # Step 4: Clean up temp files
    rm -f "$temp_input" "$temp_mask"
    
    # Check if successful
    if [ ! -f "$output_file" ]; then
        echo "ERROR: Failed to process $input_file"
        return 1
    fi
    
    return 0
}

# MAIN SCRIPT EXECUTION

# Prompt to learn usage if no switches etc. passed:
if [ ${#@} == 0 ]; then
    echo "No options provided. Run with -h to see usage help."
    exit 8
fi

# Parse command line options
OPTS=$(getopt -o hi:t:rof: --long help,input:,type:,recursive,overwriteoriginal,fuzz: -n "$PROGNAME" -- "$@")

if [ $? != 0 ]; then 
    echo "Failed parsing options." >&2 
    exit 9 
fi

eval set -- "$OPTS"

# Initialize variables
INPUT=""
TYPE=""
RECURSIVE="false"
OVERWRITE="false"
FUZZ="0"  # Default: exact white only

# Parse arguments
while true; do
    case "$1" in
        -h | --help ) 
            print_halp
            exit 0 
            ;;
        -i | --input ) 
            check_space_in_opt_arg "$1" "$2"
            INPUT="$2"
            shift 2
            ;;
        -t | --type ) 
            check_space_in_opt_arg "$1" "$2"
            TYPE=$(validate_extension "$2")
            shift 2
            ;;
        -r | --recursive ) 
            RECURSIVE="true"
            shift
            ;;
        -o | --overwriteoriginal ) 
            OVERWRITE="true"
            shift
            ;;
        -f | --fuzz ) 
            check_space_in_opt_arg "$1" "$2"
            validate_fuzz "$2"
            FUZZ="$2"
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

# Check dependencies
check_dependencies

# Validate mutual exclusivity of input and type options
if [ -n "$INPUT" ] && [ -n "$TYPE" ]; then
    echo "ERROR: Cannot use both --input and --type options simultaneously"
    echo "Use one or the other, Batman. Maybe Rachel could make that work. If only."
    exit 10
fi

if [ -z "$INPUT" ] && [ -z "$TYPE" ]; then
    echo "ERROR: Must specify either --input or --type option"
    echo "Run with -h to see usage help."
    exit 11
fi

# Validate recursive with type only
if [ "$RECURSIVE" = "true" ] && [ -n "$INPUT" ]; then
    echo "ERROR: --recursive option can only be used with --type, not with --input"
    exit 12
fi

# Build array of files to process
declare -a FILES_TO_PROCESS

if [ -n "$INPUT" ]; then
    build_file_array "file" "$INPUT" "$RECURSIVE" FILES_TO_PROCESS
else
    build_file_array "type" "$TYPE" "$RECURSIVE" FILES_TO_PROCESS
fi

# Process files
if [ ${#FILES_TO_PROCESS[@]} -eq 0 ]; then
    echo "No files to process. Exiting."
    exit 13
fi

echo "Found ${#FILES_TO_PROCESS[@]} file(s) to process"
echo "Fuzz factor: $FUZZ%"
echo "----------------------------------------"

SUCCESS_COUNT=0
FAIL_COUNT=0

for file in "${FILES_TO_PROCESS[@]}"; do
    if process_image "$file" "$OVERWRITE" "$FUZZ"; then
        ((SUCCESS_COUNT++))
    else
        ((FAIL_COUNT++))
    fi
done

echo "----------------------------------------"
echo "Processing complete: $SUCCESS_COUNT succeeded, $FAIL_COUNT failed"

if [ $FAIL_COUNT -gt 0 ]; then
    exit 14
fi

exit 0