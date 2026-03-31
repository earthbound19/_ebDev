# DESCRIPTION
# Runs a Processing sketch $1 from the command line. Designed for Processing 4.3.4 (last version with processing-java.exe) For newer Processing versions, you may need to adjust the PROCESSING_CMD path

# USAGE
# With this script in you PATH, run with these parameters:
# - $1 REQUIRED. The path to the folder containing your Processing sketch, e..g "C:\Users\me\Documents\Processing\ImageBomber"
# For example, to run a sketch named ImageBomber.pde which is in a folder of the same name, at "C:\Users\me\Documents\Processing\ImageBomber\ImageBomber.pde", run:
#    runProcessingScript.sh "/c/Users/me/Documents/Processing/ImageBomber"
# If this script is not in your path, run it from the directory it is in, like:
#    ./runProcessingScript.sh "/c/Users/me/Documents/Processing/ImageBomber"
# NOTES
# - You may get a path error if you don't surround the path parameter $1 in single or double quote marks.
# - Depending on your version of Processing, you may need to hack the variable PROCESSING_CMD to the full path of processing.exe somewhere else. And it may have to be processing-jave.exe and you may have to hack this script in that case to not use the `cli` switch with Processing, which is how it's told to run in CLI mode for versions 4.3 and up, re: https://discourse.processing.org/t/how-do-i-run-processing-through-a-terminal/46746


# CODE
if [ "$1" ]; then SKETCH_PATH=$1; else printf "\nNo parameter \$1 (full path to Processing sketch folder) passed to script. Exit."; exit 1; fi

# Hard-coded path to Processing executable - CHANGE THIS to match your installation
PROCESSING_CMD="/c/Program Files/Processing/processing.exe"
# PROCESSING_CMD="/c/Program Files/Processing/app/processing.exe"  # Alternative location

# Check if Processing executable exists
if [[ ! -f "$PROCESSING_CMD" ]]; then
    echo "ERROR: Processing executable not found at: $PROCESSING_CMD"
    echo ""
    echo "Please update the PROCESSING_CMD variable in this script to point to"
    echo "your processing.exe location. Common locations:"
    echo "  - C:\\Program Files\\Processing\\processing.exe"
    echo "  - C:\\Program Files\\Processing\\app\\processing.exe"
	echo "You may need to make other changes, depending. See comments in this script."
    exit 1
fi

# OPTIONAL. Test if the processing exe responds to the cli command correctly; uncomment the following block if you want to do this:
#"$PROCESSING_CMD" cli --help > /dev/null 2>&1
#if [[ $? -ne 0 ]]; then
#    echo "ERROR: 'processing.exe cli' command failed."
#    echo ""
#    echo "This suggests either:"
#    echo "  1. You're using Processing version older than 4.4.3 (which doesn't support 'cli')"
#    echo "  2. The Processing installation is corrupted"
#    echo ""
#    echo "For older versions, use processing-java.exe instead (Tools → Install 'processing-java')"
#    exit 2
#fi

# Convert to Windows path if needed (MSYS2 handles this, but just in case)
SKETCH_PATH=$(cygpath -w "$SKETCH_PATH" 2>/dev/null || echo "$SKETCH_PATH")

echo "Running sketch: $SKETCH_PATH"
echo "Using: $PROCESSING_CMD cli --sketch=\"$SKETCH_PATH\" --run"
echo ""

"$PROCESSING_CMD" cli --sketch="$SKETCH_PATH" --run