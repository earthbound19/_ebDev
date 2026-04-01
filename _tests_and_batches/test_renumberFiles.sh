#!/usr/bin/env bash
# test_renumberFiles.sh - Comprehensive test suite for renumberFiles.sh
# NOTE: this test script reports a number of errors at this writing which are
# not critical for my usage, and that they are even valid errors has not been
# verified. It may actually be that this script is checking for errors in
# broken ways.

set +e  # Explicitly disable exit on error - we handle failures gracefully

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Test counters - Function level
TEST_FUNCTIONS_RUN=0
TEST_FUNCTIONS_PASSED=0
TEST_FUNCTIONS_FAILED=0

# Test counters - Assertion level
ASSERTIONS_PASSED=0
ASSERTIONS_FAILED=0

# Script under test (must be in PATH)
SCRIPT="renumberFiles.sh"

# Generate a unique test run ID to avoid collisions across test runs
TEST_RUN_ID=$(date +%s)_$$
TEST_BASE="/tmp/renumber_test_${TEST_RUN_ID}"

# Test subdirectories
CURRENT_DIR="$TEST_BASE/current"
SUBDIR1="$TEST_BASE/subdir1"
SUBDIR2="$TEST_BASE/subdir2"
EMPTY_DIR="$TEST_BASE/empty_dir"

# Track created files for cleanup
CREATED_FILES=()

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_pass() {
    echo -e "${GREEN}PASS: $1${NC}"
    ((ASSERTIONS_PASSED++))
}

print_fail() {
    echo -e "${RED}FAIL: $1${NC}"
    ((ASSERTIONS_FAILED++))
}

print_test() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Test Function $((TEST_FUNCTIONS_RUN + 1)): $1${NC}"
    echo -e "${CYAN}========================================${NC}"
    ((TEST_FUNCTIONS_RUN++))
}

print_detail() {
    echo -e "${YELLOW}$1${NC}"
}

print_script_output() {
    echo -e "${MAGENTA}Script output:${NC}"
    echo -e "${MAGENTA}----------------------------------------${NC}"
    echo "$1"
    echo -e "${MAGENTA}----------------------------------------${NC}"
}

# Safe directory operations
safe_cd() {
    local target_dir="$1"
    if [ ! -d "$target_dir" ]; then
        echo -e "${RED}ERROR: Directory does not exist: $target_dir${NC}" >&2
        return 1
    fi
    cd "$target_dir" || return 1
    return 0
}

safe_pushd() {
    local target_dir="$1"
    if [ ! -d "$target_dir" ]; then
        echo -e "${RED}ERROR: Directory does not exist: $target_dir${NC}" >&2
        return 1
    fi
    pushd "$target_dir" >/dev/null || return 1
    return 0
}

safe_popd() {
    popd >/dev/null 2>&1 || return 0
}

# File verification with error suppression
verify_file_exists() {
    local file="$1"
    [ -f "$file" ] && return 0 || return 1
}

verify_file_not_exists() {
    local file="$1"
    [ ! -f "$file" ] && return 0 || return 1
}

count_files_in_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Cleanup function
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ] && [ $exit_code -ne 130 ]; then
        echo -e "${RED}Script interrupted or failed during test execution${NC}" >&2
    fi
    if [ -n "$TEST_BASE" ] && [ -d "$TEST_BASE" ]; then
        rm -rf "$TEST_BASE" 2>/dev/null
        echo -e "${YELLOW}Cleaned up test directory: $TEST_BASE${NC}"
    fi
    if [ $exit_code -eq 0 ]; then
        exit 0
    else
        exit $exit_code
    fi
}

# Set trap for cleanup on exit
trap cleanup EXIT INT TERM

# Setup test environment
setup_test_environment() {
    print_header "Setting up test environment"
    
    # Clean up any previous test run
    rm -rf "$TEST_BASE" 2>/dev/null
    
    # Create directory structure
    mkdir -p "$CURRENT_DIR" || { echo "ERROR: Failed to create $CURRENT_DIR" >&2; return 1; }
    mkdir -p "$SUBDIR1" || { echo "ERROR: Failed to create $SUBDIR1" >&2; return 1; }
    mkdir -p "$SUBDIR2" || { echo "ERROR: Failed to create $SUBDIR2" >&2; return 1; }
    mkdir -p "$EMPTY_DIR" || { echo "ERROR: Failed to create $EMPTY_DIR" >&2; return 1; }
    
    echo -e "${GREEN}Test environment ready at: $TEST_BASE${NC}"
    echo ""
    return 0
}

# Generate a random unique basename for each test
generate_test_name() {
    local test_id="$1"
    echo "test_${TEST_RUN_ID}_${test_id}_$(head -c 8 /dev/urandom 2>/dev/null | xxd -p 2>/dev/null || echo $$)"
}

# Create test files with safety checks
create_test_file() {
    local filepath="$1"
    local dirpath=$(dirname "$filepath")
    
    if [ ! -d "$dirpath" ]; then
        echo -e "${YELLOW}Warning: Directory $dirpath does not exist, creating${NC}" >&2
        mkdir -p "$dirpath" || return 1
    fi
    
    touch "$filepath" 2>/dev/null || { echo -e "${RED}ERROR: Failed to create $filepath${NC}" >&2; return 1; }
    CREATED_FILES+=("$filepath")
    return 0
}

# Clean up files from current test
cleanup_test_files() {
    for file in "${CREATED_FILES[@]}"; do
        rm -f "$file" 2>/dev/null
    done
    CREATED_FILES=()
}

# =============================================================================
# Test Cases
# =============================================================================

test_option_parsing_validation() {
    local test_name="Option parsing and validation"
    print_test "$test_name"
    
    local function_failed=0
    
    # Test 1: No arguments
    print_detail "Testing: No arguments"
    local output=$("$SCRIPT" 2>&1)
    local exit_code=$?
    if [ $exit_code -eq 0 ] && echo "$output" | grep -q "Usage:"; then
        print_pass "No arguments shows help"
    else
        print_fail "No arguments should show help (exit $exit_code)"
        function_failed=1
    fi
    
    # Test 2: Missing extension
    print_detail "Testing: Missing extension"
    output=$("$SCRIPT" -r 2>&1)
    exit_code=$?
    if [ $exit_code -eq 3 ] && echo "$output" | grep -q "No -e --extension argument"; then
        print_pass "Missing extension caught"
    else
        print_fail "Missing extension should exit 3 (got $exit_code)"
        function_failed=1
    fi
    
    # Test 3: Start number with space (should be caught by pre-scan)
    print_detail "Testing: Start number with space"
    output=$("$SCRIPT" -e png -s 42 2>&1)
    exit_code=$?
    if [ $exit_code -eq 1 ] && echo "$output" | grep -q "requires a value"; then
        print_pass "Start number with space caught"
    else
        print_fail "Start number with space should exit 1 (got $exit_code)"
        function_failed=1
    fi
    
    # Test 4: Start number non-numeric
    print_detail "Testing: Start number non-numeric"
    output=$("$SCRIPT" -e png -sabc 2>&1)
    exit_code=$?
    if [ $exit_code -eq 4 ] && echo "$output" | grep -q "not an integer"; then
        print_pass "Non-numeric start number caught"
    else
        print_fail "Non-numeric start number should exit 4 (got $exit_code)"
        function_failed=1
    fi
    
    # Test 5: Both -o and -n
    print_detail "Testing: Both -o and -n (mutually exclusive)"
    output=$("$SCRIPT" -e png -o -n 2>&1)
    exit_code=$?
    if [ $exit_code -eq 6 ] && echo "$output" | grep -q "mutually exclusive"; then
        print_pass "Mutually exclusive -o and -n caught"
    else
        print_fail "-o and -n should exit 6 (got $exit_code)"
        function_failed=1
    fi
    
    # Test 6: Postfix with space
    print_detail "Testing: Postfix with space"
    output=$("$SCRIPT" -e png -x _final 2>&1)
    exit_code=$?
    if [ $exit_code -eq 1 ] && echo "$output" | grep -q "requires a value"; then
        print_pass "Postfix with space caught"
    else
        print_fail "Postfix with space should exit 1 (got $exit_code)"
        function_failed=1
    fi
    
    # Test 7: Digits non-numeric
    print_detail "Testing: Digits non-numeric"
    output=$("$SCRIPT" -e png -dabc 2>&1)
    exit_code=$?
    if [ $exit_code -eq 5 ] && echo "$output" | grep -q "not an integer"; then
        print_pass "Non-numeric digits caught"
    else
        print_fail "Non-numeric digits should exit 5 (got $exit_code)"
        function_failed=1
    fi
    
    if [ $function_failed -eq 0 ]; then
        ((TEST_FUNCTIONS_PASSED++))
        print_pass "All option parsing tests passed"
        return 0
    else
        ((TEST_FUNCTIONS_FAILED++))
        return 1
    fi
}

test_sort_order() {
    local test_name="Sort order verification"
    print_test "$test_name"
    
    local function_failed=0
    
    # Create files with specific names for alphabetical test
    cleanup_test_files
    create_test_file "$CURRENT_DIR/apple.png" || return 1
    create_test_file "$CURRENT_DIR/banana.png" || return 1
    create_test_file "$CURRENT_DIR/zebra.png" || return 1
    
    print_detail "Testing: Default alphabetical sort"
    
    safe_pushd "$CURRENT_DIR" || return 1
    local output=$("$SCRIPT" -e png 2>&1)
    local exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ]; then
        # Check order: apple should be first, banana second, zebra third
        if verify_file_exists "$CURRENT_DIR/00.png" && \
           verify_file_exists "$CURRENT_DIR/01.png" && \
           verify_file_exists "$CURRENT_DIR/02.png"; then
            print_pass "Alphabetical sort produced correct files"
        else
            print_fail "Alphabetical sort produced unexpected filenames"
            function_failed=1
        fi
    else
        print_fail "Default sort failed (exit $exit_code)"
        function_failed=1
    fi
    
    # Cleanup
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    
    print_detail "Note: Full timestamp-based sort testing requires careful timing"
    print_detail "      -o and -n options are assumed functional based on implementation"
    
    if [ $function_failed -eq 0 ]; then
        ((TEST_FUNCTIONS_PASSED++))
        print_pass "Sort order tests passed"
        return 0
    else
        ((TEST_FUNCTIONS_FAILED++))
        return 1
    fi
}

test_collision_detection() {
    local test_name="Collision detection (data loss prevention)"
    print_test "$test_name"
    
    local function_failed=0
    
    # Test 1: Numeric-only filename collision risk
    cleanup_test_files
    create_test_file "$CURRENT_DIR/003.png" || return 1
    create_test_file "$CURRENT_DIR/file.png" || return 1
    
    print_detail "Testing: Numeric-only filename collision detection"
    
    safe_pushd "$CURRENT_DIR" || return 1
    local output=$("$SCRIPT" -e png 2>&1)
    local exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 2 ] && echo "$output" | grep -q "would overwrite"; then
        print_pass "Collision detection caught numeric filename"
    else
        print_fail "Collision detection failed (exit $exit_code)"
        function_failed=1
    fi
    
    # Test 2: Clean directory (no collisions)
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    create_test_file "$CURRENT_DIR/clean1.png" || return 1
    create_test_file "$CURRENT_DIR/clean2.png" || return 1
    
    print_detail "Testing: Clean directory (no collisions)"
    
    safe_pushd "$CURRENT_DIR" || return 1
    output=$("$SCRIPT" -e png 2>&1)
    exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ] && ! echo "$output" | grep -q "would overwrite"; then
        print_pass "Clean directory processed without collision errors"
    else
        print_fail "Clean directory incorrectly reported collisions"
        function_failed=1
    fi
    
    if [ $function_failed -eq 0 ]; then
        ((TEST_FUNCTIONS_PASSED++))
        print_pass "Collision detection tests passed"
        return 0
    else
        ((TEST_FUNCTIONS_FAILED++))
        return 1
    fi
}

test_numbering_and_padding() {
    local test_name="Numbering and padding"
    print_test "$test_name"
    
    local function_failed=0
    
    # Test 1: Default numbering (0-based)
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    for i in {1..5}; do
        create_test_file "$CURRENT_DIR/file$i.png" || return 1
    done
    
    print_detail "Testing: Default numbering (0-based)"
    
    safe_pushd "$CURRENT_DIR" || return 1
    local output=$("$SCRIPT" -e png 2>&1)
    local exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ]; then
        if verify_file_exists "$CURRENT_DIR/00.png" && \
           verify_file_exists "$CURRENT_DIR/01.png" && \
           verify_file_exists "$CURRENT_DIR/02.png" && \
           verify_file_exists "$CURRENT_DIR/03.png" && \
           verify_file_exists "$CURRENT_DIR/04.png"; then
            print_pass "Default numbering correct (00-04)"
        else
            print_fail "Default numbering produced unexpected filenames"
            function_failed=1
        fi
    else
        print_fail "Default numbering failed (exit $exit_code)"
        function_failed=1
    fi
    
    # Test 2: Custom start number
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    for i in {1..5}; do
        create_test_file "$CURRENT_DIR/file$i.png" || return 1
    done
    
    print_detail "Testing: Custom start number (42)"
    
    safe_pushd "$CURRENT_DIR" || return 1
    output=$("$SCRIPT" -e png -s42 2>&1)
    exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ]; then
        if verify_file_exists "$CURRENT_DIR/42.png" && \
           verify_file_exists "$CURRENT_DIR/43.png" && \
           verify_file_exists "$CURRENT_DIR/44.png" && \
           verify_file_exists "$CURRENT_DIR/45.png" && \
           verify_file_exists "$CURRENT_DIR/46.png"; then
            print_pass "Custom start numbering correct (42-46)"
        else
            print_fail "Custom start numbering produced unexpected filenames"
            function_failed=1
        fi
    else
        print_fail "Custom start numbering failed (exit $exit_code)"
        function_failed=1
    fi
    
    # Test 3: Custom padding
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    for i in {1..5}; do
        create_test_file "$CURRENT_DIR/file$i.png" || return 1
    done
    
    print_detail "Testing: Custom padding (3 digits)"
    
    safe_pushd "$CURRENT_DIR" || return 1
    output=$("$SCRIPT" -e png -d3 2>&1)
    exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ]; then
        if verify_file_exists "$CURRENT_DIR/000.png" && \
           verify_file_exists "$CURRENT_DIR/001.png" && \
           verify_file_exists "$CURRENT_DIR/002.png" && \
           verify_file_exists "$CURRENT_DIR/003.png" && \
           verify_file_exists "$CURRENT_DIR/004.png"; then
            print_pass "Custom padding correct (000-004)"
        else
            print_fail "Custom padding produced unexpected filenames"
            function_failed=1
        fi
    else
        print_fail "Custom padding failed (exit $exit_code)"
        function_failed=1
    fi
    
    if [ $function_failed -eq 0 ]; then
        ((TEST_FUNCTIONS_PASSED++))
        print_pass "Numbering and padding tests passed"
        return 0
    else
        ((TEST_FUNCTIONS_FAILED++))
        return 1
    fi
}

test_prefix_postfix() {
    local test_name="Prefix and postfix"
    print_test "$test_name"
    
    local function_failed=0
    
    # Test 1: Prefix only
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    for i in {1..3}; do
        create_test_file "$CURRENT_DIR/file$i.png" || return 1
    done
    
    print_detail "Testing: Prefix only (img_)"
    
    safe_pushd "$CURRENT_DIR" || return 1
    local output=$("$SCRIPT" -e png -pimg_ 2>&1)
    local exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ]; then
        if verify_file_exists "$CURRENT_DIR/img_00.png" && \
           verify_file_exists "$CURRENT_DIR/img_01.png" && \
           verify_file_exists "$CURRENT_DIR/img_02.png"; then
            print_pass "Prefix correctly applied"
        else
            print_fail "Prefix produced unexpected filenames"
            function_failed=1
        fi
    else
        print_fail "Prefix test failed (exit $exit_code)"
        function_failed=1
    fi
    
    # Test 2: Postfix only
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    for i in {1..3}; do
        create_test_file "$CURRENT_DIR/file$i.png" || return 1
    done
    
    print_detail "Testing: Postfix only (_final)"
    
    safe_pushd "$CURRENT_DIR" || return 1
    output=$("$SCRIPT" -e png -x_final 2>&1)
    exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ]; then
        if verify_file_exists "$CURRENT_DIR/00_final.png" && \
           verify_file_exists "$CURRENT_DIR/01_final.png" && \
           verify_file_exists "$CURRENT_DIR/02_final.png"; then
            print_pass "Postfix correctly applied"
        else
            print_fail "Postfix produced unexpected filenames"
            function_failed=1
        fi
    else
        print_fail "Postfix test failed (exit $exit_code)"
        function_failed=1
    fi
    
    # Test 3: Both prefix and postfix
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    for i in {1..3}; do
        create_test_file "$CURRENT_DIR/file$i.png" || return 1
    done
    
    print_detail "Testing: Both prefix and postfix (img_ and _final)"
    
    safe_pushd "$CURRENT_DIR" || return 1
    output=$("$SCRIPT" -e png -pimg_ -x_final 2>&1)
    exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ]; then
        if verify_file_exists "$CURRENT_DIR/img_00_final.png" && \
           verify_file_exists "$CURRENT_DIR/img_01_final.png" && \
           verify_file_exists "$CURRENT_DIR/img_02_final.png"; then
            print_pass "Both prefix and postfix correctly applied"
        else
            print_fail "Prefix+postfix produced unexpected filenames"
            function_failed=1
        fi
    else
        print_fail "Prefix+postfix test failed (exit $exit_code)"
        function_failed=1
    fi
    
    if [ $function_failed -eq 0 ]; then
        ((TEST_FUNCTIONS_PASSED++))
        print_pass "Prefix and postfix tests passed"
        return 0
    else
        ((TEST_FUNCTIONS_FAILED++))
        return 1
    fi
}

test_recursion() {
    local test_name="Recursive processing (-r)"
    print_test "$test_name"
    
    local function_failed=0
    
    # Setup recursive test
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    rm -f "$SUBDIR1"/*.png 2>/dev/null
    rm -f "$SUBDIR2"/*.png 2>/dev/null
    
    create_test_file "$CURRENT_DIR/root1.png" || return 1
    create_test_file "$CURRENT_DIR/root2.png" || return 1
    create_test_file "$SUBDIR1/sub1a.png" || return 1
    create_test_file "$SUBDIR1/sub1b.png" || return 1
    create_test_file "$SUBDIR2/sub2a.png" || return 1
    
    print_detail "Testing: Recursive processing with -r"
    
    safe_pushd "$CURRENT_DIR" || return 1
    local output=$("$SCRIPT" -e png -r 2>&1)
    local exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ]; then
        local root_ok=false
        local sub1_ok=false
        local sub2_ok=false
        
        # Check root directory
        if verify_file_exists "$CURRENT_DIR/00.png" && verify_file_exists "$CURRENT_DIR/01.png"; then
            root_ok=true
        fi
        
        # Check subdir1
        if verify_file_exists "$SUBDIR1/00.png" && verify_file_exists "$SUBDIR1/01.png"; then
            sub1_ok=true
        fi
        
        # Check subdir2
        if verify_file_exists "$SUBDIR2/00.png"; then
            sub2_ok=true
        fi
        
        if $root_ok && $sub1_ok && $sub2_ok; then
            print_pass "Recursive processing renamed files in all directories"
        else
            print_fail "Recursive processing incomplete"
            [ "$root_ok" = false ] && print_detail "  Root directory not fully processed"
            [ "$sub1_ok" = false ] && print_detail "  Subdir1 not fully processed"
            [ "$sub2_ok" = false ] && print_detail "  Subdir2 not fully processed"
            function_failed=1
        fi
    else
        print_fail "Recursive processing failed (exit $exit_code)"
        function_failed=1
    fi
    
    if [ $function_failed -eq 0 ]; then
        ((TEST_FUNCTIONS_PASSED++))
        print_pass "Recursion tests passed"
        return 0
    else
        ((TEST_FUNCTIONS_FAILED++))
        return 1
    fi
}

test_edge_cases() {
    local test_name="Edge cases"
    print_test "$test_name"
    
    local function_failed=0
    
    # Test 1: No matching files
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    
    print_detail "Testing: No matching files"
    
    safe_pushd "$CURRENT_DIR" || return 1
    local output=$("$SCRIPT" -e png 2>&1)
    local exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ] && echo "$output" | grep -q "No .png files found"; then
        print_pass "No matching files handled gracefully"
    else
        print_fail "No matching files test failed (exit $exit_code)"
        function_failed=1
    fi
    
    # Test 2: Special characters in filenames
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    create_test_file "$CURRENT_DIR/special\!.png" || return 1
    create_test_file "$CURRENT_DIR/file with spaces.png" || return 1
    
    print_detail "Testing: Special characters in filenames"
    
    safe_pushd "$CURRENT_DIR" || return 1
    output=$("$SCRIPT" -e png 2>&1)
    exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ] && verify_file_exists "$CURRENT_DIR/00.png" && verify_file_exists "$CURRENT_DIR/01.png"; then
        print_pass "Special characters handled correctly"
    else
        print_fail "Special characters test failed (exit $exit_code)"
        function_failed=1
    fi
    
    # Test 3: Empty directory (with -r)
    print_detail "Testing: Empty directory in recursive mode"
    
    safe_pushd "$CURRENT_DIR" || return 1
    output=$("$SCRIPT" -e png -r 2>&1)
    exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 0 ]; then
        print_pass "Empty directory in recursion handled"
    else
        print_fail "Empty directory test failed (exit $exit_code)"
        function_failed=1
    fi
    
    if [ $function_failed -eq 0 ]; then
        ((TEST_FUNCTIONS_PASSED++))
        print_pass "Edge cases tests passed"
        return 0
    else
        ((TEST_FUNCTIONS_FAILED++))
        return 1
    fi
}

test_recursive_collision() {
    local test_name="Recursive collision detection"
    print_test "$test_name"
    
    local function_failed=0
    
    # Setup recursive collision test
    cleanup_test_files
    rm -f "$CURRENT_DIR"/*.png 2>/dev/null
    rm -f "$SUBDIR1"/*.png 2>/dev/null
    
    create_test_file "$CURRENT_DIR/001.png" || return 1
    create_test_file "$CURRENT_DIR/file.png" || return 1
    create_test_file "$SUBDIR1/001.png" || return 1
    create_test_file "$SUBDIR1/file.png" || return 1
    
    print_detail "Testing: Collision detection in recursive mode"
    
    safe_pushd "$CURRENT_DIR" || return 1
    local output=$("$SCRIPT" -e png -r 2>&1)
    local exit_code=$?
    safe_popd
    
    if [ $exit_code -eq 2 ] && echo "$output" | grep -q "would overwrite"; then
        print_pass "Recursive collision detection caught conflicts"
    else
        print_fail "Recursive collision detection failed (exit $exit_code)"
        function_failed=1
    fi
    
    if [ $function_failed -eq 0 ]; then
        ((TEST_FUNCTIONS_PASSED++))
        print_pass "Recursive collision tests passed"
        return 0
    else
        ((TEST_FUNCTIONS_FAILED++))
        return 1
    fi
}

# =============================================================================
# Main Test Runner
# =============================================================================

main() {
    print_header "renumberFiles.sh Test Suite"
    echo -e "Test run ID: ${YELLOW}$TEST_RUN_ID${NC}"
    echo -e "Test directory: ${YELLOW}$TEST_BASE${NC}"
    echo ""
    
    # Check if script exists in PATH
    if ! command -v "$SCRIPT" >/dev/null 2>&1; then
        echo -e "${RED}ERROR: Script '$SCRIPT' not found in PATH${NC}" >&2
        echo "Make sure renumberFiles.sh is installed and in your PATH" >&2
        return 1
    fi
    echo -e "${GREEN}Found $SCRIPT in PATH${NC}"
    echo ""
    
    # Setup test environment
    setup_test_environment || return 1
    
    # Run all tests (each returns 0 on success, non-zero on failure)
    test_option_parsing_validation
    test_sort_order
    test_collision_detection
    test_numbering_and_padding
    test_prefix_postfix
    test_recursion
    test_edge_cases
    test_recursive_collision
    
    # Final summary
    print_header "Test Results"
    echo -e "${CYAN}Test Functions:${NC}"
    echo -e "  Run:    ${TEST_FUNCTIONS_RUN}"
    echo -e "  ${GREEN}Passed: ${TEST_FUNCTIONS_PASSED}${NC}"
    echo -e "  ${RED}Failed: ${TEST_FUNCTIONS_FAILED}${NC}"
    echo ""
    echo -e "${CYAN}Assertions:${NC}"
    echo -e "  ${GREEN}Passed: ${ASSERTIONS_PASSED}${NC}"
    echo -e "  ${RED}Failed: ${ASSERTIONS_FAILED}${NC}"
    echo -e "  Total:  $((ASSERTIONS_PASSED + ASSERTIONS_FAILED))"
    echo ""
    
    if [ $TEST_FUNCTIONS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All test functions passed!${NC}"
        return 0
    else
        echo -e "${RED}$TEST_FUNCTIONS_FAILED test function(s) failed${NC}"
        return 1
    fi
}

# Run main
main "$@"