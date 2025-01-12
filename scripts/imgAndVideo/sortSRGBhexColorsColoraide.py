# DESCRIPTION
# Sorts sRGB hex colors in file $1 by next nearest color within the palette, starting on color $2 (optional; default first color in list), in HCT color space, printing to stdout. Can be overriden with other sort options; see URL in USAGE

# DEPENDENCIES
# Python with coloraide_extras library installed (which I believe in turn installs coloraide as a dependency)

# USAGE
# Run from python with the full name of this script and these parameters:
# - -i | --inputfile REQUIRED. File name of source hexplt (sRGB hex color flat file list) to sort.
# - [-s | --startcolor] OPTIONAL. sRGB hex color code to begin sorting on, e.g. '#894a5e' or f800fc. If omitted, the first color in the source file is used. This may be a color that is not in the source list, e.g. black to start sort on the darkest found color, or white to start sort on the lightest/brightest found color -- even if black or white is not in the original list. Note that if you include a starting # hash/number/pound character with the value of this parameter, you may need to surround the value with single or double quotes -- so you may wish to just omit the leading #.
# - [-c | --colorspace] OPTIONAL. coloraide color space keyword to sort in, for example 'hct', 'ok', or '2000'. Defaults to 'hct' if omitted. See the `Name` field for various spaces listed as supported at https://facelessuser.github.io/coloraide/distance/
# - [-k | --keepduplicatecolors OPTIONAL. Keep duplicate colors. Default off (duplicate colors are eliminated).
# - [-w | --overwritesourcefile OPTIONAL. Overwrite source file with result. WARNING: this clobbers it (data loss of initial state). As this permanently alters the source file with no going back (including the possibility of emptying and failing to repopulate it if there's some error), use this option carefully. For example only use this option with disposable, backed up or version-controlled files. Also, with this option the result is not written to stdout, only written back over the source file.
# EXAMPLES
# All invocations of this script should be in this form:
#    python /path/to/thisScript/sortSRGBHexColorsColoraide.py <switch flags and values>
# -- but the examples only give the last part of that, for brevity:
# As one example, to sort a palette file named colors.hexplt in the default color space, and print the result to stdout, run:
#    sortSRGBHexColorsColoraide.py -i colors.hexplt
# To sort that starting on the color black (whether that color is in the palette or not), run:
#    sortSRGBHexColorsColoraide.py --inputfile colors.hexplt --startcolor 000000
# To sort that starting on the color black (whether that color is in the palette or not), and sort in oklab color space, run:
#    sortSRGBhexColorsColoraide.py -i colors.hexplt -s 000000 -c ok
# To do the same but sort on the default color (the first in the source file), omit the -s switch, so run:
#    sortSRGBhexColorsColoraide.py -i colors.hexplt -c ok
# To keep any duplicate colors, use -k:
#    sortSRGBhexColorsColoraide.py -i colors.hexplt -k
# To record the result to a file, redirect stdout:
#    sortSRGBhexColorsColoraide.py -i colors.hexplt -k > output.hexplt


# CODE
import argparse
import re
import sys
from coloraide_extras.everything import ColorAll as Color
from more_itertools import unique_everseen

# Function to parse command-line arguments
def parse_arguments():
    parser = argparse.ArgumentParser(description="Sort sRGB hex colors in a palette file.")
    parser.add_argument(
        "-i", "--inputfile", 
        required=True, 
        help="File name of source hexplt (sRGB hex color flat file list) to sort."
    )
    parser.add_argument(
        "-s", "--startcolor", 
        help="sRGB hex color code to begin sorting on (default: first color in the file)."
    )
    parser.add_argument(
        "-c", "--colorspace", 
        default="hct", 
        help="Color space keyword to sort in (default: hct)."
    )
    parser.add_argument(
        "-k", "--keepduplicatecolors", 
        action="store_true", 
        help="Keep duplicate colors (default: off)."
    )
    parser.add_argument(
        "-w", "--overwritesourcefile", 
        action="store_true", 
        help="Overwrite the source file with the result (default: off)."
    )
    return parser.parse_args()

# Function to load colors from the input file
def load_colors(filename):
    pattern = r"#[0-9a-fA-F]{6}"
    colors = []
    with open(filename, "r") as file_list:
        for line in file_list:
            matches = re.findall(pattern, line)  # Find all matches on the line
            colors.extend(match.lower() for match in matches)  # Add matches to the list
    return colors

# Function to validate and normalize the start color
def get_start_color(start_color, colors):
    if start_color:
        found = re.search(r"[0-9a-fA-F]{6}", start_color)
        if not found:
            raise ValueError(f"Invalid start color: {start_color}")
        return f"#{found.group(0).lower()}"
    return colors[0]

# Function to sort colors
def sort_colors(colors, start_color, colorspace):
    final_list = []
    if start_color in colors:
        final_list.append(start_color)
        colors.remove(start_color)

    while colors:
        nearest = Color(start_color).closest(colors, method=colorspace).to_string(hex=True)
        final_list.append(nearest)
        colors.remove(nearest)
        start_color = nearest

    return final_list

# Parse arguments
args = parse_arguments()

# Load colors from file
try:
    colors = load_colors(args.inputfile)
except FileNotFoundError:
    print(f"Error: File {args.inputfile} not found.")
    sys.exit(1)
except Exception as e:
    print(f"Error reading file: {e}")
    sys.exit(1)

if not colors:
    print("Error: No valid colors found in the file.")
    sys.exit(1)

# Get start color
try:
    start_color = get_start_color(args.startcolor, colors)
except ValueError as e:
    print(e)
    sys.exit(2)

# Sort colors
try:
    sorted_colors = sort_colors(colors, start_color, args.colorspace)
except Exception as e:
    print(f"Error during sorting: {e}")
    sys.exit(3)

# Remove duplicates if not keeping them
if not args.keepduplicatecolors:
    sorted_colors = list(unique_everseen(sorted_colors))

# Output result
if args.overwritesourcefile:
    try:
        with open(args.inputfile, "w") as file:
            file.writelines(f"{color}\n" for color in sorted_colors)
        print(f"File {args.inputfile} successfully overwritten.")
    except Exception as e:
        print(f"Error writing to file: {e}")
        sys.exit(4)
else:
    for color in sorted_colors:
        print(color)
