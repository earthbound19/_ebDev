#!/usr/bin/env bash
# DESCRIPTION
# Converts an SVG file to a raster image format (PNG by default) using ImageMagick.

# USAGE
#   SVG2img.sh --input-file <file.svg> [--longest-side-px <pixels>] [--target-image-format <format>] [--background-color <color>] [--help]
#
# Short form:
#   SVG2img.sh -i <file.svg> [-l <pixels>] [-f <format>] [-c <color>] [-h]
#
# SWITCHES
#   -i, --input-file <file>       Required: SVG file to convert
#   -l, --longest-side-px <px>    Optional: Longest side in pixels (default: 4280)
#   -f, --target-image-format <f> Optional: Output format png/jpg/etc (default: png)
#   -c, --background-color <c>    Optional: Background color. Special values:
#                                 'transparent' or 'none' -> transparent background
#                                 'default-opaque' -> #39383bff (opaque dark purplish-gray)
#                                 Hex values accepted with or without # prefix
#                                 (6 or 8 digits). Anything else passed directly
#                                 to ImageMagick's -background.
#   -h, --help                    Show this help

# PREVIOUSLY, the usage was positional parameters; if you have something calling this script and returning errors about wrong data or types, you may need to update the positional parameters to use the named switches below:
# - $1 the SVG file name to create an image from (e.g., in.svg) -- NOW -i <file> OR --input-file <file>
# - $2 OPTIONAL. Longest side in pixels for rendered output image. Default was 4280 if not given (though an echo incorrectly said 7680). -- NOW -l <pixels> OR --longest-side-px <pixels>
# - $3 OPTIONAL. Target file format e.g. png or jpg -- default was jpg if not given (though code defaulted to png). NOW defaults to png. -- NOW -f <format> OR --target-image-format <format>
# - $4 OPTIONAL. Background color. Accepted 6-digit hex (no #) for opaque background, or fell back to hardcoded #39383b if invalid. Previously, erroneously no alpha support? -- NOW -c <color> OR --background-color <color> (supports 'transparent', 'none', 'default-opaque', hex with/without #, 6/8 digits, CSS names, or anything ImageMagick accepts)
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
PROGNAME=$(basename "$0")

print_help() {
    cat <<EOF
Usage: $PROGNAME -i <file.svg> [options]

Required:
  -i, --input-file <file>       SVG file to convert

Options:
  -l, --longest-side-px <px>    Longest side in pixels (default: 4280)
  -f, --target-image-format <f> Output format: png, jpg, etc. (default: png)
  -c, --background-color <c>    Background color. Special values:
                                'transparent' or 'none' = transparent
                                'default-opaque' = #39383bff
                                Hex: RRGGBB, RRGGBBAA, #RRGGBB, #RRGGBBAA
                                Anything else passed directly to ImageMagick's
								-background.
  -h, --help                    Show this help

Examples:
  $PROGNAME -i diagram.svg
  $PROGNAME -i logo.svg -l 2000 -f png -c transparent
  $PROGNAME -i icon.svg -c default-opaque
  $PROGNAME -i graph.svg -c "#2266ff"
  $PROGNAME -i plot.svg -c white
EOF
}

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
            # Check for empty value
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

# Build ImageMagick background parameter
backgroundColorParam=""
if [ -z "$bgColor" ]; then
    # Omitted -> transparent
    backgroundColorParam="-background none"
else
    case "$bgColor" in
        transparent|none)
            backgroundColorParam="-background none"
            ;;
        default-opaque)
            backgroundColorParam='-background "#39383bff"'
            ;;
        *)
            # Check if it's a hex value (with or without #, 6 or 8 digits)
            strippedHex="${bgColor#\#}"
            if [[ "$strippedHex" =~ ^[0-9a-fA-F]{6}$ ]] || [[ "$strippedHex" =~ ^[0-9a-fA-F]{8}$ ]]; then
                # Valid hex - ensure it starts with # for ImageMagick
                backgroundColorParam="-background \"#${strippedHex}\""
            else
                # Pass through as-is (CSS names, etc.)
                backgroundColorParam="-background \"$bgColor\""
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

# Perform conversion
echo "Rendering: $inputFile -> $outputFile (longest side: ${longestSide}px)"
eval magick $backgroundColorParam "$inputFile" -resize "${longestSide}x${longestSide}" "$outputFile"

if [ $? -eq 0 ]; then
    echo "Success: $outputFile"
    exit 0
else
    echo "ERROR: Conversion failed for $inputFile" >&2
    exit 1
fi