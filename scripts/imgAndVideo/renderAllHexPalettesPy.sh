# DESCRIPTION
# Runs renderHexPalette.py for every .hexplt file in the path (non-recursive) from which this script is run. Result: all hex palette files in the current path are rendered. Also optionally recurses to render all palettes in all subdirectories.
# WRITTEN BY a large language model with user guidance and modeling after the now legacy script renderAllHexPalettes.sh, which is now deprecated, as this script calls a much faster script than what that called.

# DEPENDENCIES
# - renderHexPalette.py (the Python palette renderer)
# - getFullPathToFile.sh (utility to locate scripts in PATH)
# - Python 3 with Pillow installed (see renderHexPalette.py dependencies)

# USAGE
# Run with these parameters:
#   -r, --recurse          Recursively search subdirectories for .hexplt files (must appear before --)
#   --                     Separator: options after this are passed directly to renderHexPalette.py
#   [RENDERER_OPTIONS]     Any options for renderHexPalette.py (see that script's documentation)
#
# EXAMPLES
# To render all palettes in the current directory only:
#    renderAllHexPalettesPy.sh
# To recurse into all subdirectories:
#    renderAllHexPalettesPy.sh -r
# To recurse and also set tile size to 300px:
#    renderAllHexPalettesPy.sh -r -- -t 300
# To render with shuffle and 5 columns (no recursion):
#    renderAllHexPalettesPy.sh -- -s -c 5
# To render with rows=3 (note: -r after -- is passed to renderer as rows parameter):
#    renderAllHexPalettesPy.sh -- -r 3
#
# NOTES
# - The -- separator is important: options before it are for this script, options after it go to renderHexPalette.py
# - This allows clean handling of parameter collisions (like -r meaning either "recurse" or "rows")
# - The Python renderer is fast enough that no cooldown period is needed, even with thousands of palettes.

# CODE

function print_halp {
	echo "Runs renderHexPalette.py for all .hexplt files in the current path."
	echo ""
	echo "USAGE:"
	echo "  renderAllHexPalettesPy.sh [OPTIONS] -- [RENDERER_OPTIONS]"
	echo ""
	echo "OPTIONS (must appear before --):"
	echo "  -r, --recurse    Recursively search subdirectories for .hexplt files"
	echo "  -h, --help       Show this help message"
	echo ""
	echo "RENDERER_OPTIONS (after --) are passed directly to renderHexPalette.py:"
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
	echo "  renderAllHexPalettesPy.sh -r -- -t 300       # recursive, 300px tiles"
	echo "  renderAllHexPalettesPy.sh -- -s -c 5         # shuffle, 5 columns"
	echo "  renderAllHexPalettesPy.sh -- -r 3            # rows=3 (no recursion)"
}

# Print help and exit if -h or --help is found (even without --)
for arg in "$@"; do
	if [ "$arg" == "-h" ] || [ "$arg" == "--help" ]; then
		print_halp
		exit 0
	fi
done

# Find the position of -- separator
separator_pos=-1
for i in "${!@}"; do
	if [ "${!i}" == "--" ]; then
		separator_pos=$i
		break
	fi
done

# Extract script options (before --) and renderer options (after --)
script_options=()
renderer_options=()

if [ $separator_pos -eq -1 ]; then
	# No -- found: all args are for the renderer
	renderer_options=("$@")
else
	# Split at --
	for ((i=0; i<$separator_pos; i++)); do
		script_options+=("${!i}")
	done
	for ((i=$separator_pos+1; i<$#; i++)); do
		renderer_options+=("${!i}")
	done
fi

# Parse script options
do_recurse=false
for opt in "${script_options[@]}"; do
	case $opt in
		-r|--recurse)
			do_recurse=true
			;;
		*)
			echo "Warning: Unknown script option: $opt (ignored)"
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
	echo "► Rendering: $hexpltFileName"
	
	# Run the actual render command
	eval $renderCommand
	
	# Print separator for readability when processing many files
	echo ""
done

echo "DONE. Rendered ${#hexpltFilesArray[@]} palette files."