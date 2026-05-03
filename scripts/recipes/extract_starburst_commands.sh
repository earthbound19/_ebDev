#!/usr/bin/env bash

# DESCRIPTION
# Scans SVG files for randomStarburstOrSpiky.py command strings, extracts
# the switch sets (excluding --seed), and generates a bash script that
# re-runs those commands with the original parameters.

# DEPENDENCIES
# - find (MSYS2)
# - grep, sed, sort, uniq (standard MSYS2 utilities)
# - randomStarburstOrSpiky.py must be in PATH when running the generated script

# USAGE
# Run with these parameters:
# - $1 (optional) any word/value - if provided, scans subdirectories recursively
#   If omitted, only scans current directory
# For example:
#    ./extract_starburst_commands.sh
# Or, to scan subdirectories:
#    ./extract_starburst_commands.sh --recursive
# Or:
#    ./extract_starburst_commands.sh any_value


# CODE
# Determine whether to scan subdirectories
if [ "$1" ]; then
    echo "INFO: Recursive subdirectory search enabled"
    # Find SVG files recursively - use null delimiter for safety
    filesList=()
    while IFS= read -r -d '' file; do
        filesList+=("$file")
    done < <(find . -type f -iname "*.svg" -print0)
else
    echo "INFO: Only scanning current directory (use any argument for recursive search)"
    # Find SVG files (non-recursive, current directory only)
    filesList=()
    while IFS= read -r -d '' file; do
        filesList+=("$file")
    done < <(find . -maxdepth 1 -type f -iname "*.svg" -printf "%P\0")
fi

if [ ${#filesList[@]} -eq 0 ]; then
    echo "ERROR: No SVG files found in the specified location(s)" >&2
    exit 1
fi

echo "INFO: Found ${#filesList[@]} SVG file(s) to scan"

# Array to store unique command switch strings
declare -a allSwitchSets=()
declare -A uniqueSwitchMap=()

# Extract command strings from SVG files
for svgFile in "${filesList[@]}"; do
	echo scanning $svgFile . . .
    # Read the entire file and replace newlines with spaces
    fileContent=$(cat "$svgFile" | tr '\n' ' ')
    
    # Extract content between <dc:description> and </dc:description>
    descriptionContent=$(echo "$fileContent" | sed -n 's/.*<dc:description>\(.*\)<\/dc:description>.*/\1/p')
    
    if [ -z "$descriptionContent" ]; then
        continue
    fi
    
    # Check if this description contains the python script reference
    if echo "$descriptionContent" | grep -q "python randomStarburstOrSpiky.py"; then
        # Extract everything after "python randomStarburstOrSpiky.py"
        switchString=$(echo "$descriptionContent" | sed -n 's/.*python randomStarburstOrSpiky.py \(.*\)/\1/p')
        
        if [ -n "$switchString" ]; then
            # Remove --seed and its value (handles both space and equals formats)
            switchString=$(echo "$switchString" | sed -E 's/--seed\s+[0-9]+//g')
            switchString=$(echo "$switchString" | sed -E 's/--seed=[0-9]+//g')
            # Clean up extra spaces
            switchString=$(echo "$switchString" | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
            
            if [ -n "$switchString" ] && [ -z "${uniqueSwitchMap["$switchString"]}" ]; then
                uniqueSwitchMap["$switchString"]=1
                allSwitchSets+=("$switchString")
            fi
        fi
    fi
done

if [ ${#allSwitchSets[@]} -eq 0 ]; then
    echo "ERROR: No randomStarburstOrSpiky.py command strings found in any SVG file" >&2
    exit 1
fi

echo "INFO: Found ${#allSwitchSets[@]} unique command switch set(s)"

# Generate timestamp for filename
timestamp=$(date +"%Y_%m_%d_%H_%M")
generatedScript="extracted_random_starburst_or_spiky_commands_${timestamp}.sh"

# Generate the bash script
cat > "$generatedScript" << 'EOF'
#!/usr/bin/env bash

# GENERATED SCRIPT
# This script re-runs randomStarburstOrSpiky.py with the exact parameters
# extracted from existing SVG files.

# Find the path to randomStarburstOrSpiky.py
pathToScript=$(command -v randomStarburstOrSpiky.py)

if [ -z "$pathToScript" ]; then
    echo "ERROR: randomStarburstOrSpiky.py not found in PATH" >&2
    echo "Please ensure the script is installed and accessible" >&2
    exit 1
fi

echo "INFO: Found randomStarburstOrSpiky.py at: $pathToScript"

# Array of command switch sets (each string contains switches and values)
switchSets=(
EOF

# Write each unique switch set to the generated script with proper escaping
for switchSet in "${allSwitchSets[@]}"; do
    printf "    %q\n" "$switchSet" >> "$generatedScript"
done

cat >> "$generatedScript" << 'EOF'
)

total=${#switchSets[@]}
echo "INFO: Will run $total command(s)"

# Execute each command
for i in "${!switchSets[@]}"; do
    switchSet="${switchSets[$i]}"
    echo ""
    echo "[$((i+1))/$total] Running: python $pathToScript $switchSet"
    
    # Execute the command
    if python "$pathToScript" $switchSet; then
        echo "Command $((i+1)) completed successfully"
    else
        echo "Command $((i+1)) failed with exit code $?" >&2
    fi
done

echo ""
echo "INFO: All commands processed"
EOF

# Make the generated script executable
chmod +x "$generatedScript"

echo "SUCCESS: Generated script: $generatedScript"
echo "Total unique command sets: ${#allSwitchSets[@]}"
echo ""
echo "To run the generated script:"
echo "    ./$generatedScript"
echo ""
echo "Extracted switch sets (without --seed):"
for switchSet in "${allSwitchSets[@]}"; do
    echo "  - $switchSet"
done