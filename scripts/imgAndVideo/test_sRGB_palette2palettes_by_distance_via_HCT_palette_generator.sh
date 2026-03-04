# DESCRIPTION
# Generates a large test palette and splits it via another script which attempts to split a palette via perceptual distance.
#
# USAGE
#   ./test_sRGB_palette2palettes_by_distance_via_HCT_palette_generator.sh [options]
#
# Options:
#   -n, --num-palettes N    Number of output palettes from splitter (default: 5)
#   -c, --colors N          Number of colors to generate (default: 280)
#   -m, --min-size M        Minimum colors per palette for splitter (default: 2)
#   -o, --output-dir DIR    Output directory (default: ./_palette2palettes_by_distance_HCT_test)
#   -s, --seed SEED         Random seed for reproducibility
#   -h, --help              Show this help message
#
# ENVIRONMENT VARIABLE CONTRACT:
#   generator --stdin exports:
#     GENERATED_PALETTE: absolute path to the generated palette file
#     GENERATED_PALETTE_COUNT: always 1 (single palette)
#     GENERATED_PALETTE_COLORS: total colors generated (default 280)
#
#   The splitter script reads GENERATED_PALETTE as input and creates N output files.
#
# EXAMPLES:
#   # Generate 280 colors, split into 5 palettes, of minimums size 2 colors each; the defaults:
#   ./test_sRGB_palette2palettes_by_distance_via_HCT_palette_generator.sh
#
#   # Generate 500 colors, split into 8 palettes with min 3 each
#   ./test_sRGB_palette2palettes_by_distance_via_HCT_palette_generator.sh -n 8 -c 500 -m 3
#
#   # For consistent testability you can always generate the same palette by using a seed -s <integer number> :
#   ./test_sRGB_palette2palettes_by_distance_via_HCT_palette_generator.sh -s 42 -o ./test_run


# CODE
set -e  # Exit on error

# Default values
NUM_PALETTES=5
GEN_COLORS=280
MIN_SIZE=2
OUTPUT_DIR="./_palette2palettes_by_distance_HCT_test"
SEED=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--num-palettes)
            NUM_PALETTES="$2"
            shift 2
            ;;
        -c|--colors)
            GEN_COLORS="$2"
            shift 2
            ;;
        -m|--min-size)
            MIN_SIZE="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -s|--seed)
            SEED="$2"
            shift 2
            ;;
        -h|--help)
            head -n 30 "$0" | tail -n +2 | sed 's/^# //'
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "========================================="
echo "Step 1: Generating $GEN_COLORS test colors..."

# Get full paths to scripts - using command -v for safety
GENERATOR_SCRIPT=$(command -v perceptual_distance_HCT_palette_generator.py || echo "./perceptual_distance_HCT_palette_generator.py")
SPLITTER_SCRIPT=$(command -v sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py || echo "./sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py")

# If scripts not in PATH, look in current directory
if [[ ! -f "$GENERATOR_SCRIPT" ]]; then
    GENERATOR_SCRIPT="$(dirname "$0")/perceptual_distance_HCT_palette_generator.py"
fi
if [[ ! -f "$SPLITTER_SCRIPT" ]]; then
    SPLITTER_SCRIPT="$(dirname "$0")/sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py"
fi

echo "Generator: $GENERATOR_SCRIPT"
echo "Splitter:  $SPLITTER_SCRIPT"

# Create output directory (relative to current working directory)
mkdir -p "$OUTPUT_DIR"
echo "Output directory: $(cd "$OUTPUT_DIR" && pwd)"

# Build generator command
GEN_CMD=("python" "$GENERATOR_SCRIPT" "--stdin" "-n" "1" "-c" "$GEN_COLORS" "-o" "$OUTPUT_DIR")
if [ -n "$SEED" ]; then
    GEN_CMD+=("-s" "$SEED")
fi

# Run generator and capture output directly
echo "Running: ${GEN_CMD[@]}"
GEN_OUTPUT=$( "${GEN_CMD[@]}" )

# Source the captured output
source /dev/stdin <<<"$GEN_OUTPUT"

# Verify we got the environment variables
if [ -z "$GENERATED_PALETTE" ]; then
    echo "Failed to get GENERATED_PALETTE from generator"
    exit 1
fi

# Convert Windows path to Unix path if in MSYS2/MINGW
if command -v cygpath >/dev/null 2>&1; then
    GENERATED_PALETTE=$(cygpath -u "$GENERATED_PALETTE")
fi

echo "Generated palette: $GENERATED_PALETTE"
echo "   Colors: $GENERATED_PALETTE_COLORS"

# Verify the palette file exists
if [ ! -f "$GENERATED_PALETTE" ]; then
    echo " Palette file does not exist: $GENERATED_PALETTE"
    exit 1
fi

echo ""
echo "Step 2: Splitting into $NUM_PALETTES perceptual palettes..."

# Build splitter command
SPLIT_CMD=("python" "$SPLITTER_SCRIPT" "-i" "$GENERATED_PALETTE" "-n" "$NUM_PALETTES" "-m" "$MIN_SIZE" "-o" "$OUTPUT_DIR/split" "-f" "raw")

echo "Running: ${SPLIT_CMD[@]}"
"${SPLIT_CMD[@]}"

echo ""
echo "DONE."
echo "Generated palette: $GENERATED_PALETTE"
echo "Split palettes:"
ls -la "$OUTPUT_DIR"/split_*.hexplt 2>/dev/null || echo "   (no split palettes found)"
echo "========================================="