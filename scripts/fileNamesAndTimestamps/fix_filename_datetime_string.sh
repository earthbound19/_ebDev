# DESCRIPTION
# Fixes up all filenames in the current directory which have a less desired very specific datetime
# string format in the file name, with a better (ISO 8601 standard-inspired) one. I have (hopefully
# _had_ scripting tools etc. that got me files with a datetime stamp embedded in file names, after
# this less desirable format:
#
#    YYYY_MM_DD__HH_MM_SS[sss]
#
# (sometimes the seconds are microseconds that go past two digits)
# -- where what I really want is:
#
#    2026-08-04_07-58-02
# This script fixes that when run against a directory (or possibly also subdirectories) of such files.

# DEPENDENCIES
# Bash (developed on MSYS2 / Windows)

# USAGE
# - ARCHIVE intended files in (for example) a .7z file to repair before running this script to rename them. Then run with these optional parameters:
# --live-run causes the script to do an actual rename. Without this it will do a dry run and preview changes via stdout print feedback.
# --recursive causes the script to operate on files in subdirectories also. Untested. Recommend not doing; work on a folder at a time for safety and easier review.
# - if renames succeed, destroy the backup archive. If they don't succeed, you can restore from the archive and do an approach fix attempt.
# NOTES
# Some text files etchave metadata about these wrongly named files; in that case you can do a notepad++ search-replace of this regex, to make the metadata match the corrected file names:
#  SEARCH:
#    ([0-9]{4})(_)([0-9]{2})(_)([0-9]{2})(__)([0-9]{2})(_)([0-9]{2})(_)([0-9]{2,}
#  REPLACE:
#    $1-$3-$5_$7-$9-$11


# CODE
set -euo pipefail

LIVE_RUN=false
RECURSIVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --live-run) LIVE_RUN=true ;;
        --recursive) RECURSIVE=true ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift--
done

if [ "$RECURSIVE" = true ]; then
    FIND_CMD="find . -type f"
else
    FIND_CMD="find . -maxdepth 1 -type f"
fi

$FIND_CMD -print0 | while IFS= read -r -d '' file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    
    if [[ $base =~ ^(.*)([0-9]{4})(_)([0-9]{2})(_)([0-9]{2})(__)([0-9]{2})(_)([0-9]{2})(_)([0-9]{2,})(.*)$ ]]; then
        newbase="${BASH_REMATCH[1]}${BASH_REMATCH[2]}-${BASH_REMATCH[4]}-${BASH_REMATCH[6]}_${BASH_REMATCH[8]}-${BASH_REMATCH[10]}-${BASH_REMATCH[12]}${BASH_REMATCH[13]}"
        
        if [ "$base" != "$newbase" ]; then
            if [ "$LIVE_RUN" = true ]; then
                if [ -e "$dir/$newbase" ]; then
                    echo "ERROR: Target exists: $dir/$newbase" >&2
                    continue
                fi
                mv -- "$file" "$dir/$newbase"
                echo "Renamed: $base -> $newbase"
            else
                echo "[DRY RUN] $base -> $newbase"
            fi
        fi
    fi
done