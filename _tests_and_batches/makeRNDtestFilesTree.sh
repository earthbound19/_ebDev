#!/bin/bash
# DESCRIPTION
# makeRNDtestFilesTree.sh - Makes random test file tree with exclude files for testing cascade behavior
#
# Makes a directory tree of randomly named folders and subfolders, and random files of certain types.
# Optionally adds rename_excludes.txt files at random depths to test both upward and downward cascade
# of exclude patterns. The result random directory tree is in a subfolder named testFiles.
# The script deletes that directory tree and re-creates it on each run.
#
# DEPENDENCIES
# find, shuf, tr, fold, bc, seq
#
# USAGE
# Run with an optional parameter:
# - $1 OPTIONAL. Any string (such as 'POLSDERF'), which will cause the script to allow terminal-unfriendly 
#   characters in file names. If omitted, the character set used to generate file names is a-km-z2-9 
#   (which excludes characters that can be confused for each other such as lowercase L and 1).
#
# EXAMPLES:
#    makeRNDtestFilesTree.sh                    # Without terminal-unfriendly characters
#    makeRNDtestFilesTree.sh POLSDERF           # With terminal-unfriendly characters
#    makeRNDtestFilesTree.sh --no-exclude-files # Skip adding renameByMetadata.sh exclude files
#
# NOTES
# - To alter the characteristics of the randomly generated directory tree, see the global variables 
#   immediately under the "CODE" comment.
# - This script makes multiple randomly named files of given types with the same base file name.
# - Exclude files test both upward and downward cascade behavior for renameByMetadata.sh
#
# SCRIPTS THIS IS DESIGNED TO CREATE TEST DATA FOR:
#    renameByMetadata.sh
#    renameAllTypeByMetadata.sh

# CODE
PROGNAME=$(basename "$0")

# Parse arguments
NO_EXCLUDE_FILES=false
if [ "$1" == "--no-exclude-files" ]; then
    NO_EXCLUDE_FILES=true
    shift
fi

if [ "$1" ]; then includeTerminalUnfriendlyCharacters="True"; fi

howManyBaseDirectories=$(shuf -i 2-5 -n 1)
subfolderDepth=3
lengthRangeOfNames='3-8'
# Note that even if you give it 0 for the low range, it will still make at least 1 (limitation of how I'm using 'seq') :
rangeOfRNDfilesPerFolder='1-4'
fileTypesToMake='png tif cgp hexplt mp4 avi JPG MP4 MOV CR2'
rndSTR=''

# ALTERS the global variable rndSTR:
set_rndSTR () {
    rndLen=$(shuf -i $lengthRangeOfNames -n 1)
    if [ "$includeTerminalUnfriendlyCharacters" == "True" ]
    then
        rndSTR=$(cat /dev/urandom | tr -dc "a-km-z2-9'@=~!#$%^&()+[{]};.,-" | fold -w $rndLen | head -n 1)
    else
        rndSTR=$(cat /dev/urandom | tr -dc "a-km-z2-9" | fold -w $rndLen | head -n 1)
    fi
}

# Create file with random timestamp between 1 hour and 1 week ago
create_file_with_random_date() {
    local file="$1"
    
    # Generate random seconds between 3600 (1 hour) and 604800 (1 week)
    local random_seconds=$(( RANDOM % 604800 + 3600 ))
    
    # Calculate target date
    local target_date=$(date -d "-$random_seconds seconds" "+%Y%m%d%H%M.%S" 2>/dev/null)
    
    # Fallback for systems where date -d doesn't work (like MSYS2/Windows)
    if [ $? -ne 0 ]; then
        target_date=$(date --date="-${random_seconds} seconds" "+%Y%m%d%H%M.%S" 2>/dev/null)
    fi
    
    # Create file with that timestamp
    touch -t "$target_date" "$file" 2>/dev/null
    
    # Fallback: just create with current time if touch -t fails
    if [ $? -ne 0 ]; then
        touch "$file"
    fi
}

printf "\n~\nTest random folder tree generation in progress . . .\n~\n"
# wipe test files subdir tree:
if [ -a testFiles ]; then
    rm -rf testFiles
fi
mkdir testFiles

cd testFiles

# Array to track all directories created
declare -a all_directories=()

# make new test files subdir tree:
for i in $(seq 1 $howManyBaseDirectories)
do
    set_rndSTR
    subDirName="$rndSTR"
    set_rndSTR
    subDirName="$subDirName""$rndSTR"
    mkdir -p "$subDirName"
    all_directories+=("$subDirName")
done

nSubDirs=$(echo "scale=0; $howManyBaseDirectories / 2" | bc)
# get random selection of directories and make random subdirectories in them, $subfolderDepth times:
for i in $(seq 1 $subfolderDepth)
do
    subsetOfDirectories=$(find . -type d -printf '%P\n' 2>/dev/null | shuf | head -n $nSubDirs)
    # Make randomly named subdirectories in those:
    for directoryName in ${subsetOfDirectories[@]}
    do
        set_rndSTR
        subDirName="$rndSTR"
        set_rndSTR
        subDirName="$subDirName""$rndSTR"
        mkdir -p "$directoryName/$subDirName"
        all_directories+=("$directoryName/$subDirName")
    done
done

printf "\n~\nTest random files generation in progress . . .\n~\n"
# populate the new random test files tree with random files:
for directory in "${all_directories[@]}"
do
    howManyFilesToCreate=$(shuf -i $rangeOfRNDfilesPerFolder -n 1)
    for i in $(seq 0 $howManyFilesToCreate)
    do
        # construct random file base name which may include a number of spaces or underscores
        set_rndSTR
        constructedFileName="$rndSTR"
        numSpacesOrUnderscoresInFiles=$(shuf -i 0-3 -n 1)
        # randomly choose a space or underscore inter-word character, or no character
        spaceOrNot=$(shuf -i 0-1 -n 1)
        spaceChar=
        if [ $spaceOrNot == 1 ]
        then
            spaceChar=$(cat /dev/urandom | tr -dc "_ " | fold -w 1 | head -n 1)
        fi
        for j in $(seq 0 $numSpacesOrUnderscoresInFiles)
        do
            set_rndSTR
            constructedFileName="$constructedFileName""$spaceChar""$rndSTR"
        done
        # make files of multiple types with that same base name
        for fileType in ${fileTypesToMake[@]}
        do
            create_file_with_random_date "$directory/$constructedFileName.$fileType"
        done
    done
done

# Add random exclude files to test cascade behavior
if [ "$NO_EXCLUDE_FILES" = false ]; then
    printf "\n~\nAdding random exclude files to test cascade behavior . . .\n~\n"
    
    # Collect all directories for random selection
    dir_list=()
    while IFS= read -r dir; do
        dir_list+=("$dir")
    done < <(find . -type d 2>/dev/null | sed 's|^\./||' | grep -v '^\.$')
    
    # Randomly select 20-40% of directories to receive exclude files
    num_exclude_dirs=$(echo "scale=0; ${#dir_list[@]} * (20 + RANDOM % 21) / 100" | bc)
    [ "$num_exclude_dirs" -lt 1 ] && num_exclude_dirs=1
    
    printf "Adding exclude files to %d of %d directories\n" "$num_exclude_dirs" "${#dir_list[@]}"
    
    # Shuffle directory list and take first num_exclude_dirs
    shuffled_dirs=($(printf "%s\n" "${dir_list[@]}" | shuf))
    exclude_dirs=("${shuffled_dirs[@]:0:$num_exclude_dirs}")
    
    # For each selected directory, create a rename_excludes.txt with random files from that directory
    for exclude_dir in "${exclude_dirs[@]}"; do
        exclude_file="$exclude_dir/rename_excludes.txt"
        
        # Find all files in this directory (not subdirectories)
        mapfile -t files_in_dir < <(find "$exclude_dir" -maxdepth 1 -type f 2>/dev/null | sed 's|.*/||' | grep -v "rename_excludes.txt" | head -5)
        
        if [ ${#files_in_dir[@]} -gt 0 ]; then
            # Randomly select 1-3 files to exclude
            num_to_exclude=$((RANDOM % 3 + 1))
            [ "$num_to_exclude" -gt ${#files_in_dir[@]} ] && num_to_exclude=${#files_in_dir[@]}
            
            selected_files=($(printf "%s\n" "${files_in_dir[@]}" | shuf | head -$num_to_exclude))
            
            # Write exclude file with header comment
            {
                echo "# Exclude file at depth: $(echo "$exclude_dir" | tr -cd '/' | wc -c) levels deep"
                echo "# This exclude applies to: $exclude_dir and ALL children (downward cascade)"
                echo "# Files listed here should be skipped in this directory and ALL subdirectories"
                echo ""
                for selected_file in "${selected_files[@]}"; do
                    echo "$selected_file"
                done
            } > "$exclude_file"
            
            printf "  Created exclude file: %s (excluding %d file(s))\n" "$exclude_file" "$num_to_exclude"
        fi
    done
    
    # Also add a root-level exclude file that excludes some generated filenames
    root_exclude_file="rename_excludes.txt"
    
    # Pick 3 random files from different depths to exclude globally
    {
        echo "# ROOT-LEVEL EXCLUDE FILE - Affects ENTIRE TREE"
        echo "# Files listed here will be excluded regardless of their location"
        echo "# This tests UPWARD cascade (parent affects children)"
        echo ""
    } > "$root_exclude_file"
    
    find . -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | shuf | head -5 | while read -r file; do
        basename_file=$(basename "$file")
        echo "$basename_file  # From: $file"
    done >> "$root_exclude_file"
    
    printf "\n  Created root exclude file: %s\n" "$root_exclude_file"
    
    # Create a special downward cascade test: exclude a file in a mid-level directory
    mid_depth_dirs=()
    for dir in "${dir_list[@]}"; do
        depth=$(echo "$dir" | tr -cd '/' | wc -c)
        if [ "$depth" -ge 2 ] && [ "$depth" -le 3 ]; then
            mid_depth_dirs+=("$dir")
        fi
    done
    
    if [ ${#mid_depth_dirs[@]} -gt 0 ]; then
        test_dir="${mid_depth_dirs[0]}"
        test_exclude_file="$test_dir/rename_excludes.txt"
        
        # Create a test file in a child directory to verify downward cascade
        child_dir=$(find "$test_dir" -mindepth 1 -type d 2>/dev/null | head -1)
        if [ -n "$child_dir" ]; then
            # Create a file with a distinctive name that will be excluded
            touch "$child_dir/downward_cascade_test.jpg"
            echo "downward_cascade_test.jpg" >> "$test_exclude_file"
            printf "  Added downward cascade test: %s excludes downward_cascade_test.jpg in %s\n" "$test_exclude_file" "$child_dir"
        else
            echo "downward_cascade_test.jpg" >> "$test_exclude_file"
            printf "  Added downward cascade test: %s excludes downward_cascade_test.jpg\n" "$test_exclude_file"
        fi
    fi
fi

cd ..

printf "\n~\nDONE. Random folder and files tree is in the testFiles directory.\n~\n"

# Print summary
if [ "$NO_EXCLUDE_FILES" = false ]; then
    printf "\nExclude file summary:\n"
    printf "==================\n"
    find testFiles -name "rename_excludes.txt" -type f 2>/dev/null | while read -r f; do
        rel_path="${f#testFiles/}"
        depth=$(echo "$rel_path" | tr -cd '/' | wc -c)
        printf "  %s (depth: %d)\n" "$rel_path" "$depth"
    done
    printf "\n"
    printf "To test cascade behavior:\n"
    printf "  1. cd testFiles\n"
    printf "  2. renameAllTypeByMetadata.sh -t jpg -s -m0.8 --dry-run\n"
    printf "  3. Check which files were skipped\n"
    printf "  4. Verify parent excludes affect children (downward)\n"
    printf "  5. Verify root excludes affect all files (upward from root)\n"
fi

printf "\n~\n"