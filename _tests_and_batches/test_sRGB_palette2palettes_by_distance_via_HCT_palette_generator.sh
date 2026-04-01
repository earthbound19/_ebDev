# DESCRIPTION
# Test harness for perceptual color palette generation and splitting.
# Generates a test palette using perceptual_distance_HCT_palette_generator.py,
# then splits it using sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py.
# Can run a single test or a comprehensive test battery.
#
# DEPENDENCIES
#   - perceptual_distance_HCT_palette_generator.py (in PATH or same directory as this script)
#   - sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py (in PATH or same directory)
#   - renderAllHexPalettesPy.sh (optional, for visual verification)
#
# USAGE
#   ./test_sRGB_palette2palettes_by_distance_via_HCT_palette_generator.sh [options]
#
# Options:
#   -n, --num-palettes N    Number of output palettes from splitter (default: 5)
#   -c, --colors N          Number of colors to generate (default: 280)
#   -m, --min-size M        Minimum colors per palette for splitter (default: 2)
#   -o, --output-dir DIR    Output directory (default: ./_palette_test)
#   -s, --seed SEED         Random seed for reproducibility
#   -t, --test-battery      Run comprehensive test battery
#   -h, --help              Show this help message
#
# ENVIRONMENT VARIABLE CONTRACT
#   The generator script (perceptual_distance_HCT_palette_generator.py) with --stdin
#   outputs export statements for:
#     GENERATED_PALETTE: absolute path to the generated palette file
#     GENERATED_PALETTE_COUNT: number of palettes generated (always 1 in this context)
#     GENERATED_PALETTE_COLORS: total colors in the generated palette
#
#   The test script sources these variables to:
#     1. Locate the generated palette file for the splitter
#     2. Report color count to the user
#     3. Verify the palette file exists before splitting
#
#   The splitter script (sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py)
#   does not use environment variables directly; it takes file paths as arguments.
#
# OUTPUT FILES
#   All files are written directly to the specified output directory:
#   - perceptual_gradient_*.hexplt        Source palette from generator
#   - split_palette_*.hexplt              Split palettes from splitter
#   - *.png                               Rendered visualizations (if renderer available)
#   - test_output.log                      Log from test run (battery mode only)
#
# EXAMPLES:
#   # Run a single test with default parameters
#   ./test_sRGB_palette2palettes_by_distance_via_HCT_palette_generator.sh
#
#   # Run a specific test with custom parameters
#   ./test_sRGB_palette2palettes_by_distance_via_HCT_palette_generator.sh -n 8 -c 200 -m 3 -s 42
#
#   # Run the full test battery
#   ./test_sRGB_palette2palettes_by_distance_via_HCT_palette_generator.sh --test-battery


# CODE
set -e

# Get the directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"

# Default values
NUM_PALETTES=5
GEN_COLORS=280
MIN_SIZE=2
OUTPUT_DIR="./_palette_test"
SEED=""
RUN_TEST_BATTERY=false

# Check for optional renderer
RENDER_SCRIPT_AVAILABLE=false
if command -v renderAllHexPalettesPy.sh >/dev/null 2>&1; then
    RENDER_SCRIPT_AVAILABLE=true
    echo "Found renderAllHexPalettesPy.sh in PATH - visual verification enabled"
fi

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
        -t|--test-battery)
            RUN_TEST_BATTERY=true
            shift
            ;;
        -h|--help)
            head -n 40 "$0" | tail -n +2 | sed 's/^# //'
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Convert relative output directory to absolute path
if [[ ! "$OUTPUT_DIR" = /* ]]; then
    OUTPUT_DIR="$(pwd)/$OUTPUT_DIR"
fi

# Function to render palettes if script is available
render_palettes() {
    if [[ "$RENDER_SCRIPT_AVAILABLE" == "true" ]]; then
        echo "    Rendering palettes with renderAllHexPalettesPy.sh..."
        if (cd "$OUTPUT_DIR" && renderAllHexPalettesPy.sh) > /dev/null 2>&1; then
            echo "    Palettes rendered successfully"
        else
            echo "    Warning: Palette rendering had issues"
        fi
    fi
}

# Function to run a single test
run_test() {
    local n=$1
    local c=$2
    local m=$3
    local s=$4
    local desc="$5"
    
    echo ""
    echo "----------------------------------------------------------------"
    echo "TEST: $desc"
    echo "  $SCRIPT_PATH -n $n -c $c -m $m -s $s"
    echo "----------------------------------------------------------------"
    
    # Wipe the output directory clean
    if [[ -d "$OUTPUT_DIR" ]]; then
        rm -rf "$OUTPUT_DIR"
    fi
    mkdir -p "$OUTPUT_DIR"
    
    # Run the test with the given parameters using absolute path to script
    if "$SCRIPT_PATH" -n "$n" -c "$c" -m "$m" -s "$s" -o "$OUTPUT_DIR" > "$OUTPUT_DIR/test_output.log" 2>&1; then
        
        # Debug: List all files in output directory
        echo "    Files in output directory:"
        ls -la "$OUTPUT_DIR" | sed 's/^/      /'
        
        # Find source palette file
        local source_file=""
        if compgen -G "$OUTPUT_DIR/perceptual_gradient_*.hexplt" > /dev/null; then
            source_file=($(ls "$OUTPUT_DIR"/perceptual_gradient_*.hexplt 2>/dev/null))
            source_file="${source_file[0]}"
            echo "    Found source palette: $(basename "$source_file")"
        fi
        
        # Count colors in source palette
        local source_colors=0
        if [[ -n "$source_file" && -f "$source_file" ]]; then
            local source_array=($(grep -i -o '#[0-9a-f]\{6\}' "$source_file" 2>/dev/null || true))
            source_colors=${#source_array[@]}
            echo "    Source palette: $source_colors colors"
        fi
        
        # Find split palette files
        local split_files=()
        if compgen -G "$OUTPUT_DIR/split_palette_*.hexplt" > /dev/null; then
            while IFS= read -r -d '' file; do
                split_files+=("$file")
            done < <(find "$OUTPUT_DIR" -maxdepth 1 -name "split_palette_*.hexplt" -print0 2>/dev/null || true)
            echo "    Found ${#split_files[@]} split palette files matching split_palette_*.hexplt"
        fi
        
        if [[ ${#split_files[@]} -gt 0 ]]; then
            local actual_palettes=${#split_files[@]}
            local total_split_colors=0
            
            # Check each palette has at least m colors and sum colors
            local min_size_violation=false
            for file in "${split_files[@]}"; do
                if [[ -f "$file" ]]; then
                    # Get array of hex colors
                    local colors_array=($(grep -i -o '#[0-9a-f]\{6\}' "$file" 2>/dev/null || true))
                    local colors=${#colors_array[@]}
                    total_split_colors=$((total_split_colors + colors))
                    echo "      File $(basename "$file"): $colors colors"
                    if [[ $colors -lt $m ]]; then
                        min_size_violation=true
                        echo "  FAIL: Palette $(basename "$file") has only $colors colors (minimum $m)"
                    fi
                fi
            done
            
            # Verify total colors match source
            local colors_match=true
            if [[ $source_colors -ne $total_split_colors ]]; then
                colors_match=false
                echo "  FAIL: Color count mismatch! Source: $source_colors, Split total: $total_split_colors"
            fi
            
            # Render palettes for visual inspection
            render_palettes
            
            if [[ $actual_palettes -eq $n ]] && [[ "$min_size_violation" == "false" ]] && [[ "$colors_match" == "true" ]]; then
                echo "  PASS: Generated $actual_palettes palettes, all >= $m colors, all colors preserved"
                echo "  Output: $OUTPUT_DIR"
                return 0
            else
                if [[ $actual_palettes -ne $n ]]; then
                    echo "  FAIL: Expected $n palettes, got $actual_palettes"
                fi
                echo "  Output: $OUTPUT_DIR (examine for debugging)"
                return 1
            fi
        else
            echo "  FAIL: No split palette files generated"
            echo "  Output: $OUTPUT_DIR (examine for debugging)"
            echo "    Contents of $OUTPUT_DIR:"
            ls -la "$OUTPUT_DIR" | sed 's/^/      /'
            render_palettes
            return 1
        fi
    else
        # Check if this was an expected failure (insufficient colors)
        local required=$((n * m))
        if [[ $c -lt $required ]]; then
            echo "  PASS: Expected failure (need $required colors, have $c)"
            echo "  Output: $OUTPUT_DIR (error logged)"
            return 0
        else
            echo "  FAIL: Unexpected error"
            echo "  Output: $OUTPUT_DIR (examine for debugging)"
            if [[ -f "$OUTPUT_DIR/test_output.log" ]]; then
                echo "  Last few lines of output:"
                tail -5 "$OUTPUT_DIR/test_output.log" | sed 's/^/    /'
            else
                echo "  No log file was created - test may have failed very early"
            fi
            return 1
        fi
    fi
}

# If test battery mode, run all tests
if [[ "$RUN_TEST_BATTERY" == "true" ]]; then
    echo "========================================="
    echo "Perceptual Palette Test Battery"
    echo "========================================="
    echo "Output directory: $OUTPUT_DIR (wiped before each test)"
    echo ""
    
    PASS_COUNT=0
    FAIL_COUNT=0
    TOTAL_TESTS=0
    
    # Array to store test results for summary
    declare -a TEST_RESULTS
    
    # Basic functionality tests
    run_test 3 30 2 42 "Basic: 3 palettes, 30 colors, min 2" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Basic: 3-30-2-42"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Basic: 3-30-2-42"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 4 40 3 123 "Basic: 4 palettes, 40 colors, min 3" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Basic: 4-40-3-123"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Basic: 4-40-3-123"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 5 50 4 456 "Basic: 5 palettes, 50 colors, min 4" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Basic: 5-50-4-456"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Basic: 5-50-4-456"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    # Edge cases - minimum colors exactly meeting requirements
    run_test 3 6 2 789 "Edge: Exactly 2 per palette (6 colors)" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Edge: 3-6-2-789"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Edge: 3-6-2-789"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 4 12 3 101 "Edge: Exactly 3 per palette (12 colors)" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Edge: 4-12-3-101"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Edge: 4-12-3-101"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 5 25 5 202 "Edge: Exactly 5 per palette (25 colors)" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Edge: 5-25-5-202"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Edge: 5-25-5-202"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    # Edge cases - one color over minimum
    run_test 3 7 2 303 "Edge: One over min (7 colors)" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Edge: 3-7-2-303"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Edge: 3-7-2-303"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 4 13 3 404 "Edge: One over min (13 colors)" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Edge: 4-13-3-404"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Edge: 4-13-3-404"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 5 26 5 505 "Edge: One over min (26 colors)" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Edge: 5-26-5-505"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Edge: 5-26-5-505"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    # Stress tests - many palettes from few colors
    run_test 8 24 3 606 "Stress: 8 palettes, 24 colors, min 3" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Stress: 8-24-3-606"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Stress: 8-24-3-606"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 10 30 3 707 "Stress: 10 palettes, 30 colors, min 3" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Stress: 10-30-3-707"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Stress: 10-30-3-707"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 12 36 3 808 "Stress: 12 palettes, 36 colors, min 3" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Stress: 12-36-3-808"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Stress: 12-36-3-808"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    # Stress tests - many colors, many palettes
    run_test 10 200 5 909 "Stress: 10 palettes, 200 colors, min 5" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Stress: 10-200-5-909"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Stress: 10-200-5-909"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 15 300 4 1010 "Stress: 15 palettes, 300 colors, min 4" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Stress: 15-300-4-1010"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Stress: 15-300-4-1010"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 20 400 3 1111 "Stress: 20 palettes, 400 colors, min 3" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Stress: 20-400-3-1111"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Stress: 20-400-3-1111"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    # Extreme proportions - very few palettes, many colors
    run_test 2 200 10 1212 "Extreme: 2 palettes, 200 colors, min 10" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Extreme: 2-200-10-1212"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Extreme: 2-200-10-1212"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 3 300 20 1313 "Extreme: 3 palettes, 300 colors, min 20" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Extreme: 3-300-20-1313"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Extreme: 3-300-20-1313"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    # Multiple seeds for same parameters
    for seed in 1 2 3 4 5; do
        run_test 5 100 3 $seed "Seed variation: seed $seed" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Seed: 5-100-3-$seed"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Seed: 5-100-3-$seed"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
        echo "Press Enter to continue to next test..."; read
    done
    
    # Expected failures - insufficient colors
    run_test 5 9 2 1414 "Expected fail: Need 10 colors, have 9" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Expected fail: 5-9-2-1414"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Expected fail: 5-9-2-1414"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 3 5 2 1515 "Expected fail: Need 6 colors, have 5" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Expected fail: 3-5-2-1515"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Expected fail: 3-5-2-1515"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    run_test 4 7 2 1616 "Expected fail: Need 8 colors, have 7" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Expected fail: 4-7-2-1616"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Expected fail: 4-7-2-1616"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    # Performance test - very large palette
    run_test 8 1000 10 1717 "Performance: 8 palettes, 1000 colors, min 10" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Performance: 8-1000-10-1717"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Performance: 8-1000-10-1717"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    echo "Press Enter to continue to next test..."; read
    
    # The original problematic case
    run_test 5 280 2 42 "Original bug: 5 palettes, 280 colors, min 2" && { PASS_COUNT=$((PASS_COUNT+1)); TEST_RESULTS+=("PASS Original bug: 5-280-2-42"); } || { FAIL_COUNT=$((FAIL_COUNT+1)); TEST_RESULTS+=("FAIL Original bug: 5-280-2-42"); }; TOTAL_TESTS=$((TOTAL_TESTS+1))
    
    echo ""
    echo "========================================="
    echo "TEST BATTERY COMPLETE"
    echo "========================================="
    echo "Test results:"
    for result in "${TEST_RESULTS[@]}"; do
        echo "  $result"
    done
    echo "========================================="
    echo "Total tests: $TOTAL_TESTS"
    echo "Passed:      $PASS_COUNT"
    echo "Failed:      $FAIL_COUNT"
    echo "Output dir:  $OUTPUT_DIR (contains most recent test)"
    echo "========================================="
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "ALL TESTS PASSED"
        exit 0
    else
        echo "$FAIL_COUNT TESTS FAILED"
        exit 1
    fi
fi

# Normal single-test mode
echo "========================================="
echo "Step 1: Generating $GEN_COLORS test colors..."

# Create output directory first - using absolute path
mkdir -p "$OUTPUT_DIR"

# Locate required scripts - look in script directory first, then PATH
GENERATOR_SCRIPT="$SCRIPT_DIR/perceptual_distance_HCT_palette_generator.py"
if [[ ! -f "$GENERATOR_SCRIPT" ]]; then
    GENERATOR_SCRIPT=$(command -v perceptual_distance_HCT_palette_generator.py || echo "")
fi

SPLITTER_SCRIPT="$SCRIPT_DIR/sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py"
if [[ ! -f "$SPLITTER_SCRIPT" ]]; then
    SPLITTER_SCRIPT=$(command -v sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py || echo "")
fi

if [[ -z "$GENERATOR_SCRIPT" ]] || [[ ! -f "$GENERATOR_SCRIPT" ]]; then
    echo "Error: Cannot find perceptual_distance_HCT_palette_generator.py"
    exit 1
fi

if [[ -z "$SPLITTER_SCRIPT" ]] || [[ ! -f "$SPLITTER_SCRIPT" ]]; then
    echo "Error: Cannot find sRGB_palette2palettes_by_perceived_distance_Coloraide_HCT.py"
    exit 1
fi

echo "Generator: $GENERATOR_SCRIPT"
echo "Splitter:  $SPLITTER_SCRIPT"
echo "Output directory: $OUTPUT_DIR"

# Build generator command
GEN_CMD=("python" "$GENERATOR_SCRIPT" "--stdin" "-n" "1" "-c" "$GEN_COLORS" "-o" "$OUTPUT_DIR")
if [ -n "$SEED" ]; then
    GEN_CMD+=("-s" "$SEED")
fi

# Run generator and capture output
echo "Running: ${GEN_CMD[@]}"
GEN_OUTPUT=$( "${GEN_CMD[@]}" )

# Source the captured output to get environment variables
source /dev/stdin <<<"$GEN_OUTPUT"

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

if [ ! -f "$GENERATED_PALETTE" ]; then
    echo "Palette file does not exist: $GENERATED_PALETTE"
    exit 1
fi

echo ""
echo "Step 2: Splitting into $NUM_PALETTES perceptual palettes..."

# Build splitter command - use a base filename inside the output directory
SPLIT_BASE="$OUTPUT_DIR/split_palette.hexplt"
SPLIT_CMD=("python" "$SPLITTER_SCRIPT" "-i" "$GENERATED_PALETTE" "-n" "$NUM_PALETTES" "-m" "$MIN_SIZE" "-o" "$SPLIT_BASE" "-f" "raw")

echo "Running: ${SPLIT_CMD[@]}"
"${SPLIT_CMD[@]}"

# List what was created
echo ""
echo "Files created:"
ls -la "$OUTPUT_DIR" | sed 's/^/  /'

# Render palettes if available
if [[ "$RENDER_SCRIPT_AVAILABLE" == "true" ]]; then
    echo ""
    echo "Step 3: Rendering palettes for visual inspection..."
    if (cd "$OUTPUT_DIR" && renderAllHexPalettesPy.sh); then
        echo "Palettes rendered successfully"
    else
        echo "Warning: Palette rendering had issues"
    fi
fi

echo ""
echo "DONE."
echo "Generated palette: $GENERATED_PALETTE"
echo "Output directory: $OUTPUT_DIR"
echo "========================================="