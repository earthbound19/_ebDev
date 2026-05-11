#!/bin/bash
# DESCRIPTION
# Creates a directory tree with stub files and rename_excludes.txt files to test the
# exclude functionality of renameAllTypeByMetadata.sh and renameByMetadata.sh.
#
# Files are created with random timestamps (1 hour to 1 week ago) to test metadata
# fallback behavior and timestamp-based renaming.
#
# DEPENDENCIES
# touch, stat, date, find
#
# USAGE
print_help() {
    cat << EOF
$PROGNAME - Creates test environment for rename exclude testing

Usage: $PROGNAME [OPTIONS]

OPTIONS:
    -d, --directory DIR     Target directory name (default: exclude_test_YYYYMMDD_HHMMSS)
    -h, --help              Show this help

EXAMPLES:
    $PROGNAME                               # Creates directory with auto-generated name
    $PROGNAME --directory my_test_env       # Creates my_test_env directory

NOTES:
    - Creates root-level rename_excludes.txt for global excludes
    - Creates subdir2/rename_excludes.txt for local excludes
    - All files get random timestamps (1 hour to 1 week ago)
    - Tests both upward and downward cascade of exclude files
    - See script source for exact directory structure
EOF
}

# CODE
PROGNAME=$(basename "$0")
TEST_ROOT="exclude_test_$(date +%Y%m%d_%H%M%S)"

# Function to create file with random timestamp between 1 hour and 1 week ago
create_file_with_random_date() {
    local file="$1"
    
    # Generate random seconds between 3600 (1 hour) and 604800 (1 week)
    local random_seconds=$(( RANDOM % 604800 + 3600 ))
    
    # Calculate target date
    local target_date=$(date -d "-$random_seconds seconds" "+%Y%m%d%H%M.%S" 2>/dev/null)
    
    # Fallback for systems where date -d doesn't work (like MSYS2/Windows)
    if [ $? -ne 0 ]; then
        # On MSYS2/Windows, use this format
        target_date=$(date --date="-${random_seconds} seconds" "+%Y%m%d%H%M.%S" 2>/dev/null)
    fi
    
    # Create file with that timestamp
    touch -t "$target_date" "$file" 2>/dev/null
    
    # Verify and report
    if [ -f "$file" ]; then
        local file_date=$(stat -c "%y" "$file" 2>/dev/null || stat -f "%Sm" "$file" 2>/dev/null)
        echo "  Created: $file (timestamp: $file_date)"
    else
        # Fallback: just create with current time
        touch "$file"
        echo "  Created: $file (fallback to current time)"
    fi
}

echo "Creating test environment in: $TEST_ROOT"
echo "Files will have random timestamps (1 hour to 1 week ago)"
echo ""

# Create directory structure
mkdir -p "$TEST_ROOT/subdir1"
mkdir -p "$TEST_ROOT/subdir2"

# Create exclude file at root
cat > "$TEST_ROOT/rename_excludes.txt" << 'EOF'
# Root-level excludes - applies to entire tree
global_secret.jpg
another_global_secret.png
EOF

# Create exclude file in subdir2
cat > "$TEST_ROOT/subdir2/rename_excludes.txt" << 'EOF'
# Subdir2-level excludes - applies to entire tree
local_secret.jpg
subdir2_special.gif
EOF

# Create stub files at root level
create_file_with_random_date "$TEST_ROOT/global_secret.jpg"
create_file_with_random_date "$TEST_ROOT/another_global_secret.png"
create_file_with_random_date "$TEST_ROOT/normal_file_01.jpg"
create_file_with_random_date "$TEST_ROOT/normal_file_02.jpg"
create_file_with_random_date "$TEST_ROOT/normal_file_01.png"
create_file_with_random_date "$TEST_ROOT/unrelated.txt"

# Create stub files in subdir1
create_file_with_random_date "$TEST_ROOT/subdir1/global_secret.jpg"
create_file_with_random_date "$TEST_ROOT/subdir1/normal_file_03.jpg"
create_file_with_random_date "$TEST_ROOT/subdir1/normal_file_04.jpg"
create_file_with_random_date "$TEST_ROOT/subdir1/local_secret.jpg"

# Create stub files in subdir2
create_file_with_random_date "$TEST_ROOT/subdir2/local_secret.jpg"
create_file_with_random_date "$TEST_ROOT/subdir2/subdir2_special.gif"
create_file_with_random_date "$TEST_ROOT/subdir2/normal_file_05.jpg"
create_file_with_random_date "$TEST_ROOT/subdir2/normal_file_06.jpg"

# Create some files with no metadata (touch already gives them no exif metadata)
create_file_with_random_date "$TEST_ROOT/subdir1/no_metadata_01.jpg"
create_file_with_random_date "$TEST_ROOT/subdir2/no_metadata_02.jpg"

echo ""
echo "Test environment created at: $TEST_ROOT"
echo ""
echo "Directory structure with random timestamps:"
find "$TEST_ROOT" -type f \( -name "*.txt" -o -name "*.jpg" -o -name "*.png" -o -name "*.gif" \) | sort | while read f; do
    rel_path="${f#$TEST_ROOT/}"
    timestamp=$(stat -c "%y" "$f" 2>/dev/null | cut -d'.' -f1 || stat -f "%Sm" "$f" 2>/dev/null)
    printf "  %-40s (%s)\n" "$rel_path" "$timestamp"
done
echo ""
echo "Exclude files contents:"
echo ""
echo "=== $TEST_ROOT/rename_excludes.txt ==="
cat "$TEST_ROOT/rename_excludes.txt"
echo ""
echo "=== $TEST_ROOT/subdir2/rename_excludes.txt ==="
cat "$TEST_ROOT/subdir2/rename_excludes.txt"
echo ""
echo "Expected behavior when running from $TEST_ROOT with -t jpg:"
echo "  - All .jpg files EXCEPT those named 'global_secret.jpg' and 'local_secret.jpg' should be renamed"
echo "  - global_secret.jpg in root and subdir1 should be skipped"
echo "  - local_secret.jpg in subdir1 and subdir2 should be skipped"
echo "  - Files should be renamed to random timestamps (metadata will be read first, then filesystem dates)"
echo ""
echo "To test:"
echo "  cd $TEST_ROOT"
echo "  renameAllTypeByMetadata.sh -t jpg -s -m0.8"
echo "  renameAllTypeByMetadata.sh -t png -s -m0.8"
echo "  renameAllTypeByMetadata.sh -t gif -s -m0.8"
echo ""
echo " -- and for ease on Windows open a voidtools Everything search view of the folder root (with all files and directories under it) to observe renames and protection of renames."