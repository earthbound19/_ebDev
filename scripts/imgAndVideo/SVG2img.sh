#!/usr/bin/env bash
# DESCRIPTION
# Converts an SVG file to a raster image format (PNG by default) using CairoSVG.
# Produces crisp, sharp edges for pixel-art and monochrome SVGs without anti-aliasing artifacts, which is worth mentioning because a previous version of this script relied on imagemagick, which relied on rsvg-convert by default, did NOT produce sharp SVGs at larger scales. This does :) Also it renders the longer side of an SVG to the length you provide, maintaining aspect.

# DEPENDENCIES
#   CairoSVG and its dependencies must be installed. On Windows with MSYS2:
#
#   1. Install GTK+ runtime (required by CairoSVG):
#        pacman -S mingw-w64-x86_64-gtk3
#
#   2. Install CairoSVG via pip:
#        pip install cairosvg
#
#   3. Ensure the GTK bin directory is in your PATH:
#        export PATH="/c/msys64/mingw64/bin:$PATH"
#      Or add C:\msys64\mingw64\bin to your Windows PATH permanently.
#
#   Alternative install methods:
#     - winget: winget install --id=tschoonj.GTKForWindows -e
#     - Linux: sudo apt install python3-cairosvg  (or equivalent)
#     - macOS: brew install cairosvg
#
#   Verify installation:
#        cairosvg --version

# USAGE
PROGNAME=$(basename "$0")

print_help() {
    cat <<EOF
Usage: $PROGNAME --input-file <file.svg> [--longest-side-px <pixels>] [--target-image-format <format>] [--background-color <color>] [--help]

Short form:
$PROGNAME -i <file.svg> [-l <pixels>] [-f <format>] [-c <color>] [-h]

Required:
  -i, --input-file <file>       SVG file to convert

Options:
  -l, --longest-side-px <px>    Longest side in pixels (default: 4280)
  -f, --target-image-format <f> Output format: png, jpg, etc. (default: png)
  -c, --background-color <c>    Optional: Background color. Special values:
                                'transparent' or 'none' -> transparent background
                                'default-opaque' -> #39383bff (opaque dark
								purlish-gray)
                                Hex: RRGGBB, RRGGBBAA, #RRGGBB, #RRGGBBAA
								Hex values accepted with or without # prefix
                                Anything else passed directly to CairoSVG's
                                -b/--background.
  -h, --help                    Show this help

Examples:
  $PROGNAME -i diagram.svg
  $PROGNAME -i logo.svg -l 2000 -f png -c transparent
  $PROGNAME -i icon.svg -c default-opaque
  $PROGNAME -i graph.svg -c "#2266ff"
  $PROGNAME -i plot.svg -c white
EOF
}

# PREVIOUSLY, the usage was positional parameters; if you have something calling this script and returning errors about wrong data or types, you may need to update the positional parameters to use the named switches below:
# - $1 the SVG file name to create an image from (e.g., in.svg) -- NOW -i <file> OR --input-file <file>
# - $2 OPTIONAL. Longest side in pixels for rendered output image. Default was 4280 if not given (though an echo incorrectly said 7680). -- NOW -l <pixels> OR --longest-side-px <pixels>
# - $3 OPTIONAL. Target file format e.g. png or jpg -- default was jpg if not given (though code defaulted to png). NOW defaults to png. -- NOW -f <format> OR --target-image-format <format>
# - $4 OPTIONAL. Background color. Accepted 6-digit hex (no #) for opaque background, or fell back to hardcoded #39383b if invalid. Previously, erroneously no alpha support? -- NOW -c <color> OR --background-color <color> (supports 'transparent', 'none', 'default-opaque', hex with/without #, 6/8 digits, CSS names, or anything CairoSVG accepts)
#
# e.g. WHAT WAS (positional)
#    SVG2img.sh in.svg 4280 png ffffff
# -- IS NOW (named switches)
#    SVG2img.sh --input-file in.svg --longest-side-px 4280 --target-image-format png --background-color ffffff
# -- OR USING SHORT FORM
#    SVG2img.sh -i in.svg -l 4280 -f png -c ffffff
# -- SPECIAL CASES IN NEW VERSION:
#    Transparent background (was only possible by omitting $4):
#       SVG2img.sh -i in.svg -c transparent
#       SVG2img.sh -i in.svg -c none
#    Default opaque background #39383bff (replaces old hardcoded fallback):
#       SVG2img.sh -i in.svg -c default-opaque
#    8-digit hex with alpha channel (not previously supported):
#       SVG2img.sh -i in.svg -c ffffff80
#       SVG2img.sh -i in.svg -c "#ffffff80"

# CODE
# TO DO
# - Add an rnd bg color option?
# - Or rnd background choice from a hexplt file?

# ==== START SET GLOBALS
# Defaults
inputFile=""
longestSide="4280"
imgFormat="png"
bgColor=""

# Parse options
OPTS=$(getopt -o hi:l:f:c: --long help,input-file:,longest-side-px:,target-image-format:,background-color: -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -i|--input-file)
            inputFile="$2"
            shift 2
            ;;
        -l|--longest-side-px)
            longestSide="$2"
            shift 2
            ;;
        -f|--target-image-format)
            imgFormat="$2"
            shift 2
            ;;
        -c|--background-color)
            if [ -z "$2" ]; then
                echo "ERROR: --background-color/-c requires a value." >&2
                exit 4
            fi
            bgColor="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error during option parsing" >&2
            exit 1
            ;;
    esac
done

# Validate required input
if [ -z "$inputFile" ]; then
    echo "ERROR: --input-file/-i is required." >&2
    print_help
    exit 1
fi

if [ ! -f "$inputFile" ]; then
    echo "ERROR: Input file not found: $inputFile" >&2
    exit 1
fi

# Extract filename without extension
svgFilenameNoExtension="${inputFile%.*}"

# Validate longestSide is a positive integer
if ! [[ "$longestSide" =~ ^[0-9]+$ ]] || [ "$longestSide" -lt 1 ]; then
    echo "ERROR: --longest-side-px must be a positive integer. Got: $longestSide" >&2
    exit 1
fi

# Build CairoSVG background color value
bgColorValue=""
if [ -z "$bgColor" ]; then
    # Omitted -> transparent
    bgColorValue="transparent"
else
    case "$bgColor" in
        transparent|none)
            bgColorValue="transparent"
            ;;
        default-opaque)
            bgColorValue="#39383bff"
            ;;
        *)
            # Check if it's a hex value (with or without #, 6 or 8 digits)
            strippedHex="${bgColor#\#}"
            if [[ "$strippedHex" =~ ^[0-9a-fA-F]{6}$ ]]; then
                # 6-digit hex -> add ff for opacity (fully opaque)
                bgColorValue="#${strippedHex}ff"
            elif [[ "$strippedHex" =~ ^[0-9a-fA-F]{8}$ ]]; then
                # 8-digit hex -> keep as-is
                bgColorValue="#${strippedHex}"
            else
                # Pass through as-is (CSS names like "white", "red", etc.)
                bgColorValue="$bgColor"
            fi
            ;;
    esac
fi
# ==== END SET GLOBALS

# Check if output already exists
outputFile="${svgFilenameNoExtension}.${imgFormat}"
if [ -a "$outputFile" ]; then
    echo "Target already exists: $outputFile — will not render."
    exit 0
fi

# Check if CairoSVG is available
if ! command -v cairosvg &> /dev/null; then
    echo "ERROR: cairosvg not found. Please install dependencies:" >&2
    echo "  pacman -S mingw-w64-x86_64-gtk3" >&2
    echo "  pip install cairosvg" >&2
    echo "  export PATH=\"/c/msys64/mingw64/bin:\$PATH\"" >&2
    exit 1
fi

# Detect SVG aspect ratio using Python's standard library
read -r svgWidth svgHeight <<< $(python << EOF
import xml.etree.ElementTree as ET

try:
    tree = ET.parse("$inputFile")
    root = tree.getroot()
    
    width = None
    height = None
    
    if 'width' in root.attrib:
        width = root.get('width')
    if 'height' in root.attrib:
        height = root.get('height')
    
    if (width is None or height is None) and 'viewBox' in root.attrib:
        viewBox = root.get('viewBox')
        if viewBox:
            parts = viewBox.split()
            if len(parts) == 4:
                min_x, min_y, vb_width, vb_height = parts
                if width is None:
                    width = vb_width
                if height is None:
                    height = vb_height
    
    if width is None:
        width = "100"
    if height is None:
        height = "100"
    
    width_num = float(''.join(c for c in str(width) if c.isdigit() or c == '.' or c == '-'))
    height_num = float(''.join(c for c in str(height) if c.isdigit() or c == '.' or c == '-'))
    
    if width_num < 0:
        width_num = 100
    if height_num < 0:
        height_num = 100
    
    print(f"{width_num} {height_num}")
    
except Exception as e:
    print("100 100")
EOF
)

# Perform conversion using CairoSVG with proper aspect ratio
echo "Rendering: $inputFile -> $outputFile (longest side: ${longestSide}px)"

# Determine which dimension to constrain based on original aspect ratio
if [ ${svgWidth%.*} -gt ${svgHeight%.*} ]; then
    # Width is larger (landscape or square) - constrain by width
    echo "SVG is landscape (${svgWidth} > ${svgHeight}), constraining by width"
    cairosvg \
        "$inputFile" \
        --output-width "$longestSide" \
        -b "$bgColorValue" \
        --output "$outputFile"
else
    # Height is larger (portrait) - constrain by height
    echo "SVG is portrait (${svgHeight} > ${svgWidth}), constraining by height"
    cairosvg \
        "$inputFile" \
        --output-height "$longestSide" \
        -b "$bgColorValue" \
        --output "$outputFile"
fi

if [ $? -eq 0 ]; then
    echo "Success: $outputFile"
    exit 0
else
    echo "ERROR: Conversion failed for $inputFile" >&2
    exit 1
fi