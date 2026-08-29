#!/usr/bin/env bash
# DESCRIPTION
# Creates a uniform color image (color swatch) of specified dimensions, via
# GraphicsMagick, named <imageDimensions>_sRGB_<color>_swatch.png. Capable of
# creating fully transparent png images also. Can optionally keep multiple
# outputs with sequential numbering when the target file already exists.

# DEPENDENCIES
# imagemagick in your PATH, grep.

# USAGE
#   uniformFillColorImage.sh [OPTIONS]
#   See --help for full documentation.

# KEYWORDS
# solid fill, uniform fill, uniform color, uniform


# CODE
set -euo pipefail

PROGNAME=$(basename "$0")

print_help() {
    cat <<EOF
$PROGNAME - Creates a uniform color image (color swatch)

Usage: $PROGNAME [OPTIONS]

Creates a uniform color image of specified dimensions, filled with the
specified sRGB color (with alpha). Can optionally keep multiple outputs
with sequential numbering when the target file already exists.

OPTIONS:
  -d, --dimensions DIMENSIONS   Image dimensions in format NxN 
                                (e.g., 1200x800, 4000x4000)
                                Default: 5240x3166

  -c, --hex-color-code COLOR    sRGB hex color in format rrggbb (6 digits) or
                                rrggbbaa (8 digits). May be prefixed with #.
                                If 6 digits, opacity from -o or default ff is used.
                                Default: f800fc (magenta)

  -o, --opacity OPACITY         Override opacity. Accepts:
                                - 2 hex digits (00-ff), or
                                - Integer 0-255 (converted to hex)
                                Default: ff (fully opaque)

  -k, --keep-outputs-as-incrementally-numbered  
                                When target file exists, create numbered
                                versions instead of warning/exiting.
                                First run creates base file, subsequent
                                runs create _000001.png, _000002.png, etc.

  -h, --help                    Show this help message

EXAMPLES:
  $PROGNAME                                    # Use defaults
  $PROGNAME -d 1920x1080 -c ff0000            # Opaque red
  $PROGNAME -d 1920x1080 -c "#049862ff"       # With # prefix
  $PROGNAME -d 1920x1080 -c 049862 -o 204     # 80% opacity
  $PROGNAME -d 1920x1080 -o 128               # Default color, 50% opacity
  $PROGNAME -d 5240x2620 -c f800fcff -k       # With keep flag

NOTES:
  - Target files are named: {dimensions}_sRGB_{color}.png
  - With -k: {dimensions}_sRGB_{color}_{6digit}.png
  - Max incremental files: 999,999 (6 digits)
  - Will not clobber existing files (unless -k)
EOF
}

# === GLOBAL DEFAULTS ===
imageResolution="5240x3166"		# 1.655:1, best medium-hugorious-average-widish-aspected image size. If your goal is that but you want a 2:1 aspect, use 5240x2620
imageColor="f800fc"		# This is magenta, which with default opacity ff becomes f800fcff. If I used black, photoshop incorrectly interprets it as opaque black but IrfanView correctly interprets it as transparent. I don't know if that's a bug with Photoshop, or ImageMagick, or both.
imageOpacity="ff"		# Default opacity: fully opaque
keepOutputs=false

# === PARSE ARGUMENTS ===
OPTS=$(getopt -o hd:c:o:k --long help,dimensions:,hex-color-code:,opacity:,keep-outputs-as-incrementally-numbered -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -h|--help) print_help; exit 0 ;;
        -d|--dimensions) 
            # Validate dimensions format
            if ! echo "$2" | grep -q "^[0-9]\{1,\}[Xx][0-9]\{1,\}$"; then
                echo "ERROR: provided dimensions parameter ($2) doesn't meet format requirement nXn (numbers (pixels across), X or x, and numbers (pixels down), without any space in between). Exit." >&2
                exit 1
            fi
            imageResolution="$2"
            shift 2 
            ;;
        -c|--hex-color-code)
            # Strip # prefix if present
            clean_color=$(echo "$2" | sed 's/^#//')
            # Validate and store the color portion
            if ! echo "$clean_color" | grep -i -q "^[0-9a-f]\{6,8\}$"; then
                echo "ERROR: provided sRGB hex color pattern ($2) doesn't match requirement. Must be 6 or 8 hex digits (with optional # prefix). Example: 049862 or 049862ff or #049862ff." >&2
                exit 2
            fi
            # Extract first 6 digits as color, ignore any existing opacity
            imageColor=$(echo "$clean_color" | cut -c1-6)
            shift 2
            ;;
        -o|--opacity)
            # Validate and convert opacity
            opacity_input="$2"
            # Check if it's 2 hex digits
            if echo "$opacity_input" | grep -i -q "^[0-9a-f]\{2\}$"; then
                # It's hex, use as-is (lowercase)
                imageOpacity=$(echo "$opacity_input" | tr '[:upper:]' '[:lower:]')
            # Check if it's a decimal integer 0-255
            elif echo "$opacity_input" | grep -q "^[0-9]\{1,3\}$" && [ "$opacity_input" -ge 0 ] && [ "$opacity_input" -le 255 ]; then
                # Convert decimal to hex (2 digits, lowercase)
                imageOpacity=$(printf "%02x" "$opacity_input")
            else
                echo "ERROR: provided opacity value ($opacity_input) must be either 2 hex digits (00-ff) or an integer 0-255." >&2
                exit 3
            fi
            shift 2
            ;;
        -k|--keep-outputs-as-incrementally-numbered)
            keepOutputs=true
            shift
            ;;
        --) shift; break ;;
        *) echo "Internal error!" >&2; exit 1 ;;
    esac
done

# === BUILD FINAL COLOR ===
fullColor="${imageColor}${imageOpacity}"

# Validate the final 8-digit color (should always be valid given validations above)
if ! echo "$fullColor" | grep -i -q "^[0-9a-f]\{8\}$"; then
    echo "ERROR: final color construction resulted in invalid color: $fullColor. Please check your inputs." >&2
    exit 4
fi

# === FUNCTION TO FIND NEXT AVAILABLE NUMBER ===
find_next_number() {
    local base_name="$1"
    local highest=0
    
    # Check if base file exists
    if [ -e "${base_name}.png" ]; then
        # Base file exists, so we need to find highest numbered file
        # Look for files matching pattern: basename_XXXXXX.png
        local numbered_files=$(ls -1 "${base_name}"_[0-9][0-9][0-9][0-9][0-9][0-9].png 2>/dev/null || true)
        
        if [ -n "$numbered_files" ]; then
            # Extract numbers and find the highest
            for file in $numbered_files; do
                # Extract the 6-digit number between the last underscore and .png
                local num=$(echo "$file" | grep -o "_[0-9]\{6\}\.png$" | grep -o "[0-9]\{6\}")
                if [ -n "$num" ]; then
                    # Strip leading zeros and convert to decimal explicitly
                    num_dec=$((10#$num))
                    if [ "$num_dec" -gt "$highest" ]; then
                        highest=$num_dec
                    fi
                fi
            done
            # Return next number (highest + 1)
            printf "%06d" $((highest + 1))
        else
            # Base exists but no numbered files yet, start at 1
            echo "000001"
        fi
    else
        # Base doesn't exist, return empty to signal create base
        echo ""
    fi
}

# === TARGET FILE NAME ===
targetBaseName="${imageResolution}_sRGB_${fullColor}"

# Check if -k flag is set
if [ "$keepOutputs" = true ]; then
    # Check for existing files and determine next number
    next_num=$(find_next_number "$targetBaseName")
    
    if [ -z "$next_num" ]; then
        # No base file exists, create it
        targetFileName="${targetBaseName}.png"
        if [ ! -e "$targetFileName" ]; then
            echo "Running command:"
            echo "magick convert -size $imageResolution xc:#$fullColor $targetFileName"
            magick convert -size "$imageResolution" "xc:#$fullColor" "$targetFileName"
            echo "Created target image $targetFileName."
        else
            echo "Target image $targetFileName already exists; will not clobber. If you want to re-create it, rename or delete the existing image and run this script again."
        fi
    else
        # Base file exists, create numbered version
        targetFileName="${targetBaseName}_${next_num}.png"
        # Double-check the numbered file doesn't already exist (race condition safety)
        if [ ! -e "$targetFileName" ]; then
            echo "Running command:"
            echo "magick convert -size $imageResolution xc:#$fullColor $targetFileName"
            magick convert -size "$imageResolution" "xc:#$fullColor" "$targetFileName"
            echo "Created target image $targetFileName."
        else
            echo "Target image $targetFileName already exists; will not clobber. If you want to re-create it, rename or delete the existing image and run this script again."
        fi
    fi
else
    # No -k flag: original behavior - create base file if it doesn't exist
    targetFileName="${targetBaseName}.png"
    if [ ! -e "$targetFileName" ]; then
        echo "Running command:"
        echo "magick convert -size $imageResolution xc:#$fullColor $targetFileName"
        magick convert -size "$imageResolution" "xc:#$fullColor" "$targetFileName"
        echo "Created target image $targetFileName."
    else
        echo "Target image $targetFileName already exists; will not clobber. If you want to re-create it, rename or delete the existing image and run this script again."
    fi
fi