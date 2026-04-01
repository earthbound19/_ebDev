# DESCRIPTION
#   For all files in the current directory, iterates over them, identifies the
#   file name without the extension ("base name"), and copies all files that
#   Everything search engine (voidtools.com) finds elsewhere on the computer
#   which have that same base name but a different extension.
#
#   Example:
#     Current directory contains:
#       2_combo_05.png
#       2_combo_16.png
#
#     Everything finds elsewhere on the computer:
#       2_combo_05.hexplt
#       2_combo_16.hexplt
#
#     Result in current directory:
#       2_combo_05.png
#       2_combo_05.hexplt
#       2_combo_16.png
#       2_combo_16.hexplt
#
#   Does NOT overwrite existing files in the current directory.
#
# USAGE
#   Copy mode (default):
#     ./lsEverythingSameBasenameCopyHere.sh
#
#   Move mode (requires password):
#     ./lsEverythingSameBasenameCopyHere.sh any_param
#
# PARAMETERS
#   $1 - Optional. Any value triggers move mode. The script will prompt for
#        a case-sensitive password. If correct, files are MOVED instead of
#        copied. If incorrect, script exits with error.
#
# PASSWORD
#   Move mode password: SploepShroopp (case-sensitive)
#
# NOTES
#   - Requires Everything command-line tool "es.exe" to be installed and in PATH
#     (https://www.voidtools.com/support/everything/command_line_interface/)
#   - Designed for Windows/Cygwin/MSYS2 environments (uses cygpath)
#   - Skips duplicate basenames within the current directory to avoid redundant
#     searches (if both file.png and file.jpg exist, only searches for "file" once)
#   - When multiple files with the same basename exist elsewhere on the system,
#     the script processes ALL of them (not just the first)
#   - Files are skipped if they:
#       * Already exist in the current directory (prevents overwriting)
#       * Are located in the current directory (would copy/move to itself)
#   - Uses `cp -n` (no clobber) when in copy mode to prevent overwriting existing files
#   - Windows thumbnail database files (Thumbs.db) are ignored
#
# LIMITATIONS
#   - Designed exclusively for the probably rare pairing of MSYS2 (Windows) and voidtools Everything search engine, which is also at this writing exclusively and probably always a Windows tool.
#   - Does not handle file paths containing newline characters (extremely rare
#     on Windows and would require es.exe to support null-delimited output)
#   - Assumes cygpath is available for path conversion
#   - Case sensitivity in filenames follows Windows conventions (generally
#     case-insensitive, but the script treats them as case-sensitive)
#   - If copy/move operation fails (permissions, disk full, etc.), the script
#     continues with remaining files and reports the failure
#
# EXIT CODES
#   0 - Script completed successfully
#   1 - Move mode requested with incorrect password
#
# =============================================================================

# Determine operation mode
MOVE_MODE=false
if [ $# -gt 0 ]; then
    echo "Move mode requested. Please enter password:"
    read -s password
    if [ "$password" = "SploepShroopp" ]; then
        MOVE_MODE=true
        echo "Password correct. Will MOVE files instead of copying."
    else
        echo "ERROR: Incorrect password. Exiting."
        exit 1
    fi
fi

# Set the operation command based on mode
if [ "$MOVE_MODE" = true ]; then
    OPERATION_CMD="mv"
    OPERATION_VERB="Move"
else
    OPERATION_CMD="cp -n"
    OPERATION_VERB="Copy"
fi

# make an array of all filenames in the current directory
# Using null-delimited output to handle spaces and special chars,
# and filtering out empty lines
mapfile -t allFileNamesHere < <(find . -maxdepth 1 -type f -printf "%P\n" | grep -v '^$')
# DEBUG: show what's in the array
echo "DEBUG: allFileNamesHere = [${allFileNamesHere[@]}]" >&2

# set variable of current directory to check against:
currDir=$(pwd)

# Track processed basenames to avoid redundant searches
declare -A processedBasenames

# Counter for summary
totalProcessed=0
totalSkipped=0

# iterate over the array of file names, searching Everything for each file:
for fileName in "${allFileNamesHere[@]}"
do
    # ignore Windows thumbnail database files:
    if [ "$fileName" = "Thumbs.db" ]; then
        continue
    fi
    
    # get file name without extension:
    fileNameNoExt="${fileName%.*}"
    
    # Skip if we already processed this basename
    if [ -n "${processedBasenames[$fileNameNoExt]}" ]; then
        echo "Skipping $fileNameNoExt (already processed from another file with same basename)"
        continue
    fi
    processedBasenames[$fileNameNoExt]=1
    
    # the -a-d switch restricts results to files only (no folders)
    # Read all results into an array, handling possible spaces in paths
    everythingResults=$(es -a-d "$fileNameNoExt" 2>/dev/null | tr -d '\15\32')
    # DEBUG: show what es returned
    echo "DEBUG: es returned for '$fileNameNoExt': [$everythingResults]" >&2
	
    if [ -z "$everythingResults" ]; then
        echo "No matches found for: $fileNameNoExt"
        continue
    fi
    
    # Process each line separately to handle all matches
    while IFS= read -r found; do
        nixyPath=$(cygpath "$found")
        pathNoFileName="${nixyPath%\/*}"
        
        # if the path to the file is *different*, process it
        if [ "$pathNoFileName" != "$currDir" ]; then
            # get found file name without path
            fileNameNoPath="${nixyPath##*/}"
            
            # Check if target already exists in current directory
            if [ ! -f "$fileNameNoPath" ]; then
                echo "Processing: $fileNameNoPath (from $pathNoFileName)"
                $OPERATION_CMD "$nixyPath" . 2>/dev/null
                if [ $? -eq 0 ]; then
                    ((totalProcessed++))
                    echo "  $OPERATION_VERB successful"
                else
                    echo "  $OPERATION_VERB failed"
                    ((totalSkipped++))
                fi
            else
                echo "Skipping $fileNameNoPath (already exists in current directory)"
                ((totalSkipped++))
            fi
        else
            echo "Skipping $fileNameNoPath (same directory - would be pointless)"
            ((totalSkipped++))
        fi
    done <<< "$everythingResults"
done

echo ""
echo "=== Summary ==="
echo "Files processed: $totalProcessed"
echo "Files skipped: $totalSkipped"