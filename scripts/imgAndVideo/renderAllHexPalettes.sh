# DESCRIPTION
# Runs renderHexPalette.py for every .hexplt file in the path (non-recursive) from which this script is run. Result: all hex palette files in the current path are rendered. Also optionally recurses to render all palettes in all subdirectories.
# WRITTEN BY a large language model with user guidance and modeling after the now legacy script renderAllHexPalettes.sh, which is now deprecated, as this script calls a much faster script than what that called.

# DEPENDENCIES
# - renderHexPalette.py (the Python palette renderer)
# - getFullPathToFile.sh (utility to locate scripts in PATH)
# - Python 3 with Pillow installed (see renderHexPalette.py dependencies)

# USAGE
# Run with these parameters; see NOTES for circumstances in which switches are passed to the script this calls or not, and this assumes the called script still has these options; refer to it to be certain:
#   OPTIONAL. -r, --recurse          Recursively search subdirectories for .hexplt files
#   OPTIONAL. --                     Separator: options after this double dash ('--') are passed directly to renderHexPalette.py
#   [RENDERER_OPTIONS]     Any options for renderHexPalette.py (see that script's documentation)
#
# BEHAVIOR
#   If -- is present:   Options before -- are for this script, options after -- go to the renderer
#   If -- is absent:    -r/--recurse are consumed by this script, all other arguments go to the renderer
#
# EXAMPLES
#   renderAllHexPalettesPy.sh                     # current dir only, default renderer settings
#   renderAllHexPalettesPy.sh -r                  # recursive, default renderer settings
#   renderAllHexPalettesPy.sh --recurse -t 300    # recursive, 300px tiles (-- not needed)
#   renderAllHexPalettesPy.sh -r -- -t 300        # same as above, but explicit about separator
#   renderAllHexPalettesPy.sh -s -c 5             # no recursion, shuffle, 5 columns
#   renderAllHexPalettesPy.sh -- -r 3             # no recursion, pass -r (rows) to renderer
#
# NOTES
#   - The -- separator is optional. Without it, -r and --recurse are the ONLY arguments
#     consumed by this script; all other arguments (including -t, -s, -c, etc.) are passed
#     directly to renderHexPalette.py.
#   - Use -- when you need to pass -r or --recurse to the renderer (for the rows parameter),
#     or when you want to be explicit about which arguments belong to which script.


# CODE
function print_halp {
	echo "Runs renderHexPalette.py for all .hexplt files in the current path."
	echo ""
	echo "USAGE:"
	echo "  renderAllHexPalettesPy.sh [OPTIONS] [--] [RENDERER_OPTIONS]"
	echo ""
	echo "OPTIONS:"
	echo "  -r, --recurse    Recursively search subdirectories for .hexplt files"
	echo "  -h, --help       Show this help message"
	echo ""
	echo "RENDERER_OPTIONS are passed directly to renderHexPalette.py:"
	echo "  -t, --tile-size EDGE_LEN    Tile edge length in pixels (default: 250)"
	echo "  -s, --shuffle                Shuffle colors before rendering"
	echo "  -c, --columns COLS           Number of columns"
	echo "  -r, --rows ROWS              Number of rows"
	echo "  -o, --output OUTPUT_FILE     Output PNG file path"
	echo "  --empty-color COLOR_HEX      Color for empty tiles (default: #919191)"
	echo ""
	echo "EXAMPLES:"
	echo "  renderAllHexPalettesPy.sh                    # current dir only"
	echo "  renderAllHexPalettesPy.sh -r                 # recursive"
	echo "  renderAllHexPalettesPy.sh --recurse -t 300   # recursive, 300px tiles"
	echo "  renderAllHexPalettesPy.sh -s -c 5            # shuffle, 5 columns (no recursion)"
	echo "  renderAllHexPalettesPy.sh -- -r 3            # rows=3 (no recursion)"
}

# Print help and exit if -h or --help is found
for arg in "$@"; do
	if [ "$arg" == "-h" ] || [ "$arg" == "--help" ]; then
		print_halp
		exit 0
	fi
done

# Parse arguments manually
script_options=()
renderer_options=()
found_separator=false
skip_next=false

for ((i=1; i<=$#; i++)); do
    if [ "$skip_next" = true ]; then
        skip_next=false
        continue
    fi
    
    arg="${!i}"
    
    if [ "$found_separator" = true ]; then
        renderer_options+=("$arg")
    elif [ "$arg" == "--" ]; then
        found_separator=true
    else
        case $arg in
            -r|--recurse)
                script_options+=("$arg")
                ;;
            *)
                renderer_options+=("$arg")
                ;;
        esac
    fi
done

# Parse script options
do_recurse=false
for opt in "${script_options[@]}"; do
	case $opt in
		-r|--recurse)
			do_recurse=true
			;;
	esac
done

# Get the path to the Python render script
pathToScript=$(getFullPathToFile.sh renderHexPalette.py)
if [ "$pathToScript" == "" ]
then
	echo "!---------------------------------------------------------------!"
	echo "Could not find renderHexPalette.py in PATH. Please ensure it is"
	echo "in your PATH or adjust the script. Exit."
	echo "!---------------------------------------------------------------!"
	exit 1
fi
echo "Using render script at: $pathToScript"

# Find hexplt files based on recursion setting
if [ "$do_recurse" = true ]
then
	# Recursive search through subdirectories
	hexpltFilesArray=( $(find . -type f -iname \*.hexplt -printf "%P\n" | sort) )
	echo "Searching recursively for .hexplt files..."
else
	# Search only current directory
	hexpltFilesArray=( $(find . -maxdepth 1 -type f -iname \*.hexplt -printf "%P\n" | sort) )
	echo "Searching current directory only for .hexplt files..."
fi

# Print renderer options for clarity
if [ ${#renderer_options[@]} -gt 0 ]; then
	echo "Renderer parameters: ${renderer_options[@]}"
else
	echo "Renderer parameters: (using defaults)"
fi

# Check if any files were found
if [ ${#hexpltFilesArray[@]} -eq 0 ]; then
	echo "No .hexplt files found."
	exit 0
fi

echo "Found ${#hexpltFilesArray[@]} palette files to render."
echo ""

# Loop through all found hexplt files
for hexpltFileName in ${hexpltFilesArray[@]}
do	
	# Progress feedback and command log print
	renderCommand="python \"$pathToScript\" \"$hexpltFileName\" ${renderer_options[@]}"
	echo "Rendering: $hexpltFileName"
	
	# Run the actual render command
	eval $renderCommand
	
	# Print separator for readability when processing many files
	echo ""
done

echo "DONE. Rendered ${#hexpltFilesArray[@]} palette files."