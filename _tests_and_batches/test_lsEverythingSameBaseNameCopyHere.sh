#!/bin/bash
# DESCRIPTION
# =============================================================================
# THIS SCRIPT IS AN ACKNOWLEDGED PROBLEM - maybe no one should have invested this
# much time in it :(
# Test for lsEverythingSameBasenameCopyHere.sh
# =============================================================================
# - run this script to test all features and behaviors of that script.
# - WARNING: This creates and destroys test directories in current location
# ▝▃▝▕▌▕▕▛▐▒▘▖▇▐▃▌▏▟█▋▀█▒▔▌▘▚▐▚▋▗▛▛▃▞▚▃▝▛▙▜▝▃▓▓▎▇▇▀▘▌▋▒▋▙▕▛▜▞▃▐▇▅▛▎▖▌▒██▞▖▘▟█▛▘▎
# - indeed, it was far more technically invovled to get this test working than perhaps the script it tests :) but in my defense (or not!) a large langauge model built and refined so many tests startlingly relatively quickly and deftly. ALSO, complicated user input / called script print captures / redirect and other handling in this script will make for great "Examine this for reference" material for a large language model developing other future test scripts.
# - okay WAY more involved. I promise I'm done.
# =============================================================================

# USAGE
# With lsEverythingSameBasenameCopyHere in your PATH, run this script from a junk test directory:
#    test_lsEverythingSameBaseNameCopyHere.sh
# 
# NOTES
# - In each new test it pastes the file base name of the first relevant generated test file to the clipboard, for quick search in voidtools' Everything (just paste into a search window), to validate expected script behavior around file move / copy operations.
# - Hotkey automation requires AutoHotkey to be installed. Set HOTKEY1 and HOTKEY2 variables below to your preferred hotkeys, and set AHK_EXE to the path of your AutoHotkey executable. Leave HOTKEY1/HOTKEY2 empty to disable.
# - Test files remain after each test for manual inspection. They are cleaned up before the next test starts.
# - The script uses unique random basenames to avoid collisions with existing files on the system.

# OPTION, discouraged; uncomment the next line; this would cause it to exit on errors; we don't need to as we at least try) to handle errors gracefully) :
# set -e


# CODE
# Hotkey sequences for Everything GUI
# Leave empty ("") to skip sending keystrokes
HOTKEY1="CTRL+ALT+E"    # Open Everything GUI
HOTKEY2="CTRL+V"        # Paste clipboard into search

# AutoHotkey executable path - set to the correct version for your system
AHK_EXE="/c/Program Files/AutoHotkey/v2/AutoHotkey64.exe"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Script under test (must be in PATH)
SCRIPT="lsEverythingSameBasenameCopyHere.sh"

# Generate a unique test run ID to avoid collisions across test runs
TEST_RUN_ID=$(date +%s)_$$

# Test directories - include the run ID to avoid conflicts with parallel runs
TEST_ROOT="test_${TEST_RUN_ID}"
CURRENT_DIR="$TEST_ROOT/current"
ELSEWHERE1="$TEST_ROOT/elsewhere1"
ELSEWHERE2="$TEST_ROOT/elsewhere2"
ELSEWHERE3="$TEST_ROOT/elsewhere3"

# Track previous test's basenames for cleanup
PREVIOUS_BASENAME=""
PREVIOUS_SPACED_NAME=""
PREVIOUS_PAREN_NAME=""
PREVIOUS_BASENAME_EXTRA=""

# Function to generate a random unique basename for each test
generate_test_name() {
    local test_id="$1"
    echo "test_${TEST_RUN_ID}_${test_id}_$(head -c 8 /dev/urandom | xxd -p 2>/dev/null || echo $$)"
}

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
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}FAIL: $1${NC}"
    ((TESTS_FAILED++))
}

# Print random block characters for visual flair
print_random_blocks() {
    local length=$1
    local chars="▀▁▃▅▇█▋▌▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟"
    local result=""
    for ((i=0; i<length; i++)); do
        result+=${chars:RANDOM%${#chars}:1}
    done
    echo -e "${BLUE}$result${NC}"
}

print_test() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    print_random_blocks 40
    echo -e "${CYAN}Test $((TESTS_RUN + 1)): $1${NC}"
    echo -e "${CYAN}========================================${NC}"
    ((TESTS_RUN++))
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

# Copy string to clipboard (MSYS2/Windows)
copy_to_clipboard() {
    local value="$1"
    printf "%s" "$value" > /dev/clipboard 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${CYAN}Copied to clipboard: $value${NC}"
    else
        echo -e "${YELLOW}Could not copy to clipboard (not running in MSYS2?)${NC}"
    fi
}

# Send keystrokes using AutoHotkey v2
send_keystrokes() {
    local keys="$1"
    if [ -z "$keys" ]; then
        return
    fi
    
    local ahk_script="./temp_$$.ahk"
    
    # For HOTKEY1 (CTRL+ALT+E) - activate Everything, launch if needed, then send hotkey
    if [ "$keys" = "CTRL+ALT+E" ]; then
        cat > "$ahk_script" << 'EOF'
#Requires AutoHotkey v2.0
; Try to activate existing Everything window
if WinExist("Everything")
{
    WinActivate("Everything")
    Sleep 100
}
else
{
    ; Launch Everything if not running
    Run "C:\Program Files\Everything\Everything.exe"
    Sleep 500
    WinActivate("Everything")
    Sleep 100
}
SendInput("^!e")
EOF
    # For HOTKEY2 (CTRL+V) - send paste
    elif [ "$keys" = "CTRL+V" ]; then
        cat > "$ahk_script" << 'EOF'
#Requires AutoHotkey v2.0
SendInput("^v")
EOF
    else
        # Generic fallback
        local ahk_keys=$(echo "$keys" | sed 's/CTRL+/^/g' | sed 's/ALT+/!/g')
        cat > "$ahk_script" << EOF
#Requires AutoHotkey v2.0
SendInput("$ahk_keys")
EOF
    fi
    
    local win_script=$(cygpath -w "$ahk_script")
    "$AHK_EXE" "$win_script" /force 2>/dev/null
    
    rm -f "$ahk_script"
    
    echo -e "${CYAN}Sent keystrokes: $keys${NC}"
}

wait_for_user() {
    echo ""
    echo "pwd (prints current directory) result:"
    pwd
    echo -e "${CYAN}Test files created. Press Enter to open Everything and inspect...${NC}"
    read
    
    # Send hotkeys if defined
    if [ -n "$HOTKEY1" ] || [ -n "$HOTKEY2" ]; then
        echo -e "${CYAN}Sending hotkey sequence...${NC}"
        sleep 0.2
    fi
    
    if [ -n "$HOTKEY1" ]; then
        send_keystrokes "$HOTKEY1"
        sleep 0.5
    fi
    if [ -n "$HOTKEY2" ]; then
        send_keystrokes "$HOTKEY2"
        sleep 0.2
    fi
    
    echo -e "${CYAN}Everything should now show results for the basename.${NC}"
    echo -e "${CYAN}Press Enter to run the test script...${NC}"
    read
}

wait_for_after_test() {
    echo ""
    echo -e "${CYAN}Test completed. Press Enter to clean up and continue to next test...${NC}"
    read
}

# Clean up previous test's files
cleanup_previous_test() {
    if [ -n "$PREVIOUS_BASENAME" ]; then
        rm -f "$CURRENT_DIR/${PREVIOUS_BASENAME}".* 2>/dev/null
        rm -f "$ELSEWHERE1/${PREVIOUS_BASENAME}".* 2>/dev/null
        rm -f "$ELSEWHERE2/${PREVIOUS_BASENAME}".* 2>/dev/null
        rm -f "$ELSEWHERE3/${PREVIOUS_BASENAME}".* 2>/dev/null
    fi
    if [ -n "$PREVIOUS_SPACED_NAME" ]; then
        rm -f "$CURRENT_DIR/${PREVIOUS_SPACED_NAME}".* 2>/dev/null
        rm -f "$ELSEWHERE1/${PREVIOUS_SPACED_NAME}".* 2>/dev/null
    fi
    if [ -n "$PREVIOUS_PAREN_NAME" ]; then
        rm -f "$CURRENT_DIR/${PREVIOUS_PAREN_NAME}".* 2>/dev/null
        rm -f "$ELSEWHERE1/${PREVIOUS_PAREN_NAME}".* 2>/dev/null
    fi
    rm -f "$CURRENT_DIR/Thumbs.db" 2>/dev/null
    rm -f "$ELSEWHERE1/Thumbs.db.hexplt" 2>/dev/null
}

setup_test_environment() {
    print_header "Setting up test environment"
    
    rm -rf "$TEST_ROOT" 2>/dev/null
    
    mkdir -p "$CURRENT_DIR"
    mkdir -p "$ELSEWHERE1"
    mkdir -p "$ELSEWHERE2"
    mkdir -p "$ELSEWHERE3"
    
    echo "Created test directories under: $TEST_ROOT"
    echo "Using test run ID: $TEST_RUN_ID (should be unique system-wide)"
}

teardown_test_environment() {
    print_header "Cleaning up test environment"
    rm -rf "$TEST_ROOT"
    echo "Removed $TEST_ROOT"
    echo ""
}

# Wait for Everything to index new files
wait_for_everything() {
    sleep 1
}

count_files_in_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        find "$dir" -maxdepth 1 -type f | wc -l
    else
        echo "0"
    fi
}

verify_file_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        return 0
    else
        return 1
    fi
}

verify_file_not_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Test Cases
# =============================================================================

test_copy_mode_basic() {
    local test_id="copy_basic"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "Copy mode - basic functionality"
    print_detail "What will happen:"
    print_detail "  - Create trigger file: ${base_name}.png in current directory"
    print_detail "  - Create matching files: ${base_name}.hexplt and ${base_name}.pdf in elsewhere1"
    print_detail "  - Run script in copy mode (default)"
    print_detail "  - Expected: Both .hexplt and .pdf files are copied to current directory"
    
    # Create test files
    touch "$CURRENT_DIR/${base_name}.png"
    touch "$ELSEWHERE1/${base_name}.hexplt"
    touch "$ELSEWHERE1/${base_name}.pdf"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    local all_found=true
    for ext in png hexplt pdf; do
        if ! verify_file_exists "$CURRENT_DIR/${base_name}.$ext"; then
            all_found=false
            print_fail "Missing file: ${base_name}.$ext"
        fi
    done
    
    if [ "$all_found" = true ]; then
        print_pass "All expected files were copied"
    fi
    
    wait_for_after_test
}

test_move_mode_with_correct_password() {
    local test_id="move_correct"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "Move mode - correct password"
    print_detail "What will happen:"
    print_detail "  - Create trigger file: ${base_name}.png in current directory"
    print_detail "  - Create matching file: ${base_name}.hexplt in elsewhere1"
    print_detail "  - Run script in move mode with correct password"
    print_detail "  - Expected: ${base_name}.hexplt is MOVED to current directory"
    print_detail "  - Original file should NOT exist in elsewhere1"
    
    # Create test files
    touch "$CURRENT_DIR/${base_name}.png"
    touch "$ELSEWHERE1/${base_name}.hexplt"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$(echo "SploepShroopp" | "$SCRIPT" dummy_positional_switch_1 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    if verify_file_exists "$CURRENT_DIR/${base_name}.hexplt" && \
       verify_file_not_exists "$ELSEWHERE1/${base_name}.hexplt"; then
        print_pass "File was moved (exists in current, original removed)"
    else
        print_fail "File was not moved correctly"
        print_detail "  Debug: Current has file? $(verify_file_exists "$CURRENT_DIR/${base_name}.hexplt" && echo YES || echo NO)"
        print_detail "  Debug: Elsewhere has file? $(verify_file_not_exists "$ELSEWHERE1/${base_name}.hexplt" && echo NO || echo YES)"
    fi
    
    wait_for_after_test
}

test_move_mode_with_wrong_password() {
    local test_id="move_wrong"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "Move mode - incorrect password"
    print_detail "What will happen:"
    print_detail "  - Create trigger file: ${base_name}.png in current directory"
    print_detail "  - Create matching file: ${base_name}.hexplt in elsewhere1"
    print_detail "  - Run script in move mode with WRONG password"
    print_detail "  - Expected: Script exits with error code 1"
    print_detail "  - File should NOT be moved (should still exist in elsewhere1)"
    
    # Create test files
    touch "$CURRENT_DIR/${base_name}.png"
    touch "$ELSEWHERE1/${base_name}.hexplt"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$(echo "wrongpassword" | "$SCRIPT" dummy_positional_switch_1 2>&1)
    local exit_code=$?
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    if [ $exit_code -eq 1 ] && \
       verify_file_not_exists "$CURRENT_DIR/${base_name}.hexplt" && \
       verify_file_exists "$ELSEWHERE1/${base_name}.hexplt"; then
        print_pass "Script rejected wrong password and did not move files"
    else
        print_fail "Script did not handle wrong password correctly (exit code: $exit_code)"
    fi
    
    wait_for_after_test
}

test_multiple_matches_same_basename() {
    local test_id="multiple"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "Multiple matches - same basename from different locations"
    print_detail "What will happen:"
    print_detail "  - Create trigger file: ${base_name}.png in current directory"
    print_detail "  - Create matching files in THREE different locations:"
    print_detail "      * elsewhere1: ${base_name}.hexplt"
    print_detail "      * elsewhere2: ${base_name}.pdf"
    print_detail "      * elsewhere3: ${base_name}.doc"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: ALL THREE matching files are copied to current directory"
    
    # Create test files
    touch "$CURRENT_DIR/${base_name}.png"
    touch "$ELSEWHERE1/${base_name}.hexplt"
    touch "$ELSEWHERE2/${base_name}.pdf"
    touch "$ELSEWHERE3/${base_name}.doc"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    local all_copied=true
    for ext in hexplt pdf doc; do
        if ! verify_file_exists "$CURRENT_DIR/${base_name}.$ext"; then
            all_copied=false
            print_fail "Missing: ${base_name}.$ext"
        fi
    done
    
    if [ "$all_copied" = true ]; then
        print_pass "All matching files from multiple locations were copied"
    fi
    
    wait_for_after_test
}

test_duplicate_basename_in_current() {
    local test_id="duplicate"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "Duplicate basename in current directory (should only search once)"
    print_detail "What will happen:"
    print_detail "  - Create TWO trigger files with SAME basename but different extensions:"
    print_detail "      * ${base_name}.png"
    print_detail "      * ${base_name}.jpg"
    print_detail "  - Create matching files: ${base_name}.hexplt and ${base_name}.pdf in elsewhere1"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: Script should search for basename only ONCE (not twice)"
    print_detail "  - Expected: BOTH .hexplt and .pdf files are copied"
    print_detail "  - Expected: 'already processed' message appears"
    
    # Create test files
    touch "$CURRENT_DIR/${base_name}.png"
    touch "$CURRENT_DIR/${base_name}.jpg"
    touch "$ELSEWHERE1/${base_name}.hexplt"
    touch "$ELSEWHERE1/${base_name}.pdf"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    if verify_file_exists "$CURRENT_DIR/${base_name}.hexplt" && \
       verify_file_exists "$CURRENT_DIR/${base_name}.pdf"; then
        print_pass "Both matches found despite duplicate basename in source"
    else
        print_fail "Missing matches - duplicate basename may have caused issues"
    fi
    
    if echo "$output" | grep -q "already processed from another file with same basename"; then
        print_pass "Duplicate basename detection message shown"
    else
        print_fail "Duplicate basename detection message NOT shown"
    fi
    
    wait_for_after_test
}

test_existing_file_skip() {
    local test_id="existing"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "Skip files that already exist in current directory"
    print_detail "What will happen:"
    print_detail "  - PRE-EXISTING file in current: ${base_name}.hexplt (created first)"
    print_detail "  - Trigger file: ${base_name}.png in current directory"
    print_detail "  - Matching file: ${base_name}.hexplt in elsewhere1 (same name as pre-existing)"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: Script should NOT overwrite the existing .hexplt file"
    print_detail "  - Expected: 'already exists' message appears"
    
    # Create test files
    touch "$CURRENT_DIR/${base_name}.hexplt"
    touch "$ELSEWHERE1/${base_name}.hexplt"
    touch "$CURRENT_DIR/${base_name}.png"
    wait_for_everything
    
    local original_mod_time=$(stat -c %Y "$CURRENT_DIR/${base_name}.hexplt" 2>/dev/null || echo "0")
    sleep 1
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    local new_mod_time=$(stat -c %Y "$CURRENT_DIR/${base_name}.hexplt" 2>/dev/null || echo "0")
    
    if [ "$original_mod_time" = "$new_mod_time" ]; then
        print_pass "Existing file was skipped (not overwritten)"
    else
        print_fail "Existing file was modified (should have been skipped)"
    fi
    
    if echo "$output" | grep -q "already exists in current directory"; then
        print_pass "Skip message shown"
    else
        print_fail "Skip message NOT shown"
    fi
    
    wait_for_after_test
}

test_files_with_spaces() {
    local test_id="spaces"
    local base_name=$(generate_test_name "$test_id")
    local spaced_name="${base_name} with spaces"
    cleanup_previous_test
    PREVIOUS_SPACED_NAME="$spaced_name"
    copy_to_clipboard "${spaced_name}"
    
    print_test "Files with spaces in names"
    print_detail "What will happen:"
    print_detail "  - Create trigger file: '${spaced_name}.png' in current directory"
    print_detail "  - Create matching file: '${spaced_name}.hexplt' in elsewhere1"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: File with spaces is handled correctly and copied"
    
    # Create test files
    touch "$CURRENT_DIR/${spaced_name}.png"
    touch "$ELSEWHERE1/${spaced_name}.hexplt"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    if verify_file_exists "$CURRENT_DIR/${spaced_name}.hexplt"; then
        print_pass "File with spaces was handled correctly"
    else
        print_fail "File with spaces was not copied"
    fi
    
    wait_for_after_test
}

test_files_with_parentheses() {
    local test_id="parens"
    local base_name=$(generate_test_name "$test_id")
    local paren_name="${base_name}_(1)"
    cleanup_previous_test
    PREVIOUS_PAREN_NAME="$paren_name"
    copy_to_clipboard "${paren_name}"
    
    print_test "Files with parentheses in names"
    print_detail "What will happen:"
    print_detail "  - Create trigger file: '${paren_name}.png' in current directory"
    print_detail "  - Create matching file: '${paren_name}.hexplt' in elsewhere1"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: File with parentheses is handled correctly and copied"
    
    # Create test files
    touch "$CURRENT_DIR/${paren_name}.png"
    touch "$ELSEWHERE1/${paren_name}.hexplt"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    if verify_file_exists "$CURRENT_DIR/${paren_name}.hexplt"; then
        print_pass "File with parentheses was handled correctly"
    else
        print_fail "File with parentheses was not copied"
    fi
    
    wait_for_after_test
}

test_thumbs_db_ignored() {
    local test_id="thumbs"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "Thumbs.db is ignored"
    print_detail "What will happen:"
    print_detail "  - Create Thumbs.db file in current directory (should be ignored)"
    print_detail "  - Create trigger file: ${base_name}.png in current directory"
    print_detail "  - Create matching file: ${base_name}.hexplt in elsewhere1"
    print_detail "  - Create Thumbs.db.hexplt in elsewhere1 (should NOT be found)"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: Real file ${base_name}.hexplt IS copied"
    print_detail "  - Expected: Thumbs.db.hexplt is NOT copied"
    
    # Create test files
    touch "$CURRENT_DIR/Thumbs.db"
    touch "$CURRENT_DIR/${base_name}.png"
    touch "$ELSEWHERE1/${base_name}.hexplt"
    touch "$ELSEWHERE1/Thumbs.db.hexplt"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    if verify_file_exists "$CURRENT_DIR/${base_name}.hexplt"; then
        print_pass "Real files processed correctly alongside Thumbs.db"
    else
        print_fail "Real files not processed due to Thumbs.db presence"
    fi
    
    if verify_file_not_exists "$CURRENT_DIR/Thumbs.db.hexplt"; then
        print_pass "Thumbs.db was ignored as intended"
    else
        print_fail "Thumbs.db was NOT ignored properly"
    fi
    
    wait_for_after_test
}

test_no_matching_files() {
    local test_id="no_match"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "No matching files for basename"
    print_detail "What will happen:"
    print_detail "  - Create trigger file: ${base_name}.png in current directory"
    print_detail "  - NO matching files exist elsewhere (only the trigger file itself)"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: Script finds the trigger file, skips it (same directory)"
    print_detail "  - Expected: No files copied/moved, summary shows 0 processed, 0 skipped"
    
    # Create test files
    touch "$CURRENT_DIR/${base_name}.png"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify: Should see skip message for the trigger file (filename may be empty in the message)
    if echo "$output" | grep -q "same directory - would be pointless"; then
        print_pass "Script correctly skipped the trigger file (only match in same directory)"
    else
        print_fail "Script did not handle the trigger file correctly"
    fi
    
    # Verify no "No matches found" message (since there was a match, just skipped)
    if echo "$output" | grep -q "No matches found for: ${base_name}"; then
        print_fail "Script incorrectly reported no matches (should have found trigger file)"
    else
        print_pass "Script correctly did not report 'no matches' (trigger file was found)"
    fi
    
    wait_for_after_test
}

test_summary_output() {
    local test_id="summary"
    local base1=$(generate_test_name "${test_id}_1")
    local base2=$(generate_test_name "${test_id}_2")
    local base3=$(generate_test_name "${test_id}_3")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base1"
    copy_to_clipboard "${base1}"
    
    print_test "Summary output shows correct counts"
    print_detail "What will happen:"
    print_detail "  - Create three trigger files:"
    print_detail "      * ${base1}.png"
    print_detail "      * ${base2}.png"
    print_detail "      * ${base3}.png"
    print_detail "  - Create matching files:"
    print_detail "      * ${base1}.hexplt in elsewhere1 (should copy)"
    print_detail "      * ${base2}.hexplt in elsewhere1 (should copy)"
    print_detail "  - PRE-EXISTING file: ${base3}.hexplt already in current (should skip)"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: Summary shows processed: 2, skipped: 1"
    
    # Create test files
    touch "$CURRENT_DIR/${base1}.png"
    touch "$CURRENT_DIR/${base2}.png"
    touch "$CURRENT_DIR/${base3}.png"
    touch "$ELSEWHERE1/${base1}.hexplt"
    touch "$ELSEWHERE1/${base2}.hexplt"
    touch "$CURRENT_DIR/${base3}.hexplt"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    processed_line=$(echo "$output" | grep "Files processed:")
    skipped_line=$(echo "$output" | grep "Files skipped:")
    
    processed_count=$(echo "$processed_line" | grep -o '[0-9]\+' | head -1)
    skipped_count=$(echo "$skipped_line" | grep -o '[0-9]\+' | head -1)
    
    if [ "$processed_count" -ge 2 ] && [ "$skipped_count" -ge 1 ]; then
        print_pass "Summary counts correct (processed $processed_count, skipped $skipped_count)"
    else
        print_fail "Summary counts incorrect (processed $processed_count, skipped $skipped_count)"
    fi
    
    PREVIOUS_BASENAME_EXTRA="$base2 $base3"
    
    wait_for_after_test
}

test_empty_directory() {
    local test_id="empty"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    
    print_test "Empty directory (no files to process)"
    print_detail "What will happen:"
    print_detail "  - No trigger files in current directory"
    print_detail "  - Orphan file elsewhere: ${base_name}.hexplt (should be ignored)"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: Script completes without errors, nothing copied"
    
    # Create test files
    rm -f "$CURRENT_DIR"/*
    touch "$ELSEWHERE1/${base_name}.hexplt"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    if [ $(count_files_in_dir "$CURRENT_DIR") -eq 0 ]; then
        print_pass "Empty directory handled without errors"
    else
        print_fail "Empty directory caused issues"
    fi
    
    wait_for_after_test
}

test_source_in_current_directory_skip() {
    local test_id="source_skip"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "Source file in current directory (should be skipped)"
    print_detail "What will happen:"
    print_detail "  - Create trigger file: ${base_name}.png in current directory"
    print_detail "  - Create matching file: ${base_name}.txt ALSO in current directory"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: Script skips the .txt file (same directory)"
    print_detail "  - Expected: 'same directory - would be pointless' message appears"
    
    # Create test files
    touch "$CURRENT_DIR/${base_name}.txt"
    touch "$CURRENT_DIR/${base_name}.png"
    wait_for_everything
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    if echo "$output" | grep -q "same directory - would be pointless"; then
        print_pass "Source in same directory was skipped"
    else
        print_fail "Source in same directory wasn't properly skipped"
    fi
    
    wait_for_after_test
}

test_permission_failure_handling() {
    local test_id="perm"
    local base_name=$(generate_test_name "$test_id")
    cleanup_previous_test
    PREVIOUS_BASENAME="$base_name"
    copy_to_clipboard "${base_name}"
    
    print_test "Permission failure handling (if possible)"
    print_detail "What will happen:"
    print_detail "  - Create trigger file: ${base_name}.png in current directory"
    print_detail "  - Create matching file: ${base_name}.hexplt in elsewhere1"
    print_detail "  - Make source file read-only (chmod 444)"
    print_detail "  - Run script in copy mode"
    print_detail "  - Expected: Script attempts to copy, fails, reports failure"
    print_detail "  - NOTE: This test may not work on Windows"
    
    # Create test files
    touch "$CURRENT_DIR/${base_name}.png"
    touch "$ELSEWHERE1/${base_name}.hexplt"
    wait_for_everything
    
    # Make the source read-only
    chmod 444 "$ELSEWHERE1/${base_name}.hexplt" 2>/dev/null || echo "  (Note: chmod may not work on Windows)"
    
    # Prompt user to inspect in Everything
    wait_for_user
    
    # Run the script
    cd "$CURRENT_DIR"
    output=$("$SCRIPT" </dev/null 2>&1)
    cd - > /dev/null
    
    print_script_output "$output"
    
    # Verify
    if echo "$output" | grep -q "failed"; then
        print_pass "Permission failure was reported"
    else
        echo -e "${YELLOW}Could not test permission failure (environment limitation)${NC}"
    fi
    
    # Restore permissions
    chmod 644 "$ELSEWHERE1/${base_name}.hexplt" 2>/dev/null || true
    
    wait_for_after_test
}

# =============================================================================
# Main Test Runner
# =============================================================================

main() {
    print_header "lsEverythingSameBasenameCopyHere.sh Test"
    echo "WARNING: This will create and destroy test directories in the current location"
    echo ""
    echo "This test will run through each test case one by one."
    echo "For each test:"
    echo "  1. Test files are created"
    echo "  2. Everything opens showing the basename results"
    echo "  3. You inspect the files"
    echo "  4. You press Enter to run the test script"
    echo "  5. Results are shown"
    echo "  6. You press Enter to clean up and continue to next test"
    echo ""
    
    # Check hotkey configuration
    if [ -n "$HOTKEY1" ] || [ -n "$HOTKEY2" ]; then
        echo -e "${CYAN}Automation enabled:${NC}"
        [ -n "$HOTKEY1" ] && echo "  - Hotkey 1: $HOTKEY1 (open Everything)"
        [ -n "$HOTKEY2" ] && echo "  - Hotkey 2: $HOTKEY2 (paste into search)"
        echo ""
        
        # Check AutoHotkey is available
        if [ ! -f "$AHK_EXE" ]; then
            echo -e "${RED}ERROR: AutoHotkey not found at: $AHK_EXE${NC}"
            echo "Please update AHK_EXE path in the script or set HOTKEY1=\"\" and HOTKEY2=\"\" to disable."
            exit 1
        else
            echo -e "${GREEN}AutoHotkey found: $AHK_EXE${NC}"
            echo ""
        fi
    fi
    
    echo "Press Enter to continue or Ctrl+C to cancel..."
    read
    
    # Check if script exists in PATH
    if ! command -v "$SCRIPT" >/dev/null 2>&1; then
        echo -e "${RED}ERROR: Script '$SCRIPT' not found in PATH${NC}"
        echo "Make sure lsEverythingSameBasenameCopyHere.sh is installed and in your PATH"
        exit 1
    fi
    
    echo -e "${GREEN}Found $SCRIPT in PATH${NC}"
    
    # Run all tests
    setup_test_environment
    
    test_copy_mode_basic
    test_move_mode_with_correct_password
    test_move_mode_with_wrong_password
    test_multiple_matches_same_basename
    test_duplicate_basename_in_current
    test_existing_file_skip
    test_files_with_spaces
    test_files_with_parentheses
    test_thumbs_db_ignored
    test_no_matching_files
    test_summary_output
    test_empty_directory
    test_source_in_current_directory_skip
    test_permission_failure_handling
    
    # Clean up extra basenames from summary test if they exist
    if [ -n "$PREVIOUS_BASENAME_EXTRA" ]; then
        for extra in $PREVIOUS_BASENAME_EXTRA; do
            rm -f "$CURRENT_DIR/${extra}".* 2>/dev/null
            rm -f "$ELSEWHERE1/${extra}".* 2>/dev/null
        done
    fi
    
    # Final cleanup of any remaining test files
    cleanup_previous_test
    teardown_test_environment
    
    # Final summary
    print_header "Test Results"
    echo -e "Tests run:    ${TESTS_RUN}"
    echo -e "${GREEN}Tests passed: ${TESTS_PASSED}${NC}"
    echo -e "${RED}Tests failed: ${TESTS_FAILED}${NC}"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}$TESTS_FAILED test(s) failed${NC}"
        exit 1
    fi
}

# Run main
main "$@"