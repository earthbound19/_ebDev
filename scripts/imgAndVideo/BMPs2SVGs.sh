# DESCRIPTION
# Runs the potrace utility to convert all black and white .bmp images (in the directory in which this script is run) to .svg vector images.

# DEPENDENCIES
# potrace.

# USAGE
# Run without any parameter to use the default preset, which does moderate corner preservation:
#    BMPs2SVGs.sh
# $1 OPTIONAL. Or run it with a preset parameter for $1; see the $PRESET case block for presets in the code; use any one of them -- and you can define new ones too! :
#    BMPs2SVGs.sh smooth       # Best for organic/curvy/blob shapes
#    BMPs2SVGs.sh sharp        # Best for fine detail/sharp angles
#    BMPs2SVGs.sh verysharp    # Aggressive corner preservation
#    BMPs2SVGs.sh detailed     # Minimal optimization, preserves fine features
# NOTES
# - The script considers white the background color and black the line/trace area color.
# - It will not trace a bmp image if the target svg file already exists.
# - To retrace, delete the target svg file, and run this script again.


# CODE
# Preset selection based on first argument
PRESET="${1:-default}"

# original command:
# potrace -n -s --group -r 24 -C \#000000 --fillcolor \#ffffff $element
# Variations for different image types/preferences; also:
# BRIEF POTRACE OPTIONS REFERENCE:
# -a = angle threshold (1 means widest angle, 0 means most acute--really no--angle); -O = optimization threshold (0 will optimize less, 1 will optimize most); r = resolution (dots per inch)
case "$PRESET" in
    smooth)
        echo "Using SMOOTH preset (best for blobs/curves)"
        POTRACE_PRESET=(-r 72 -u 5 -t 4 -a 1.6 -O 0.54 -C '#000000')
        ;;
    sharp)
        echo "Using SHARP preset (best for fine detail/angles)"
        POTRACE_PRESET=(-t 2 -a 0.73 -r 150 -O 0.71 -C '#000000')
        ;;
    verysharp)
        echo "Using VERY SHARP preset (aggressive corner preservation)"
        POTRACE_PRESET=(-t 7 -a 0.64 -r 150 -O 0.78 -C '#000000')
        ;;
    detailed)
        echo "Using DETAILED preset (minimal optimization)"
        POTRACE_PRESET=(-t 4 -a 0.84 -r 150 -O 0.347 -C '#000000')
        ;;
    default)
        echo "Using DEFAULT preset (moderate corners)"
        POTRACE_PRESET=(-t 7 -a 0.88 -r 150 -O 0.45 -C '#000000')
        ;;
esac

imgs=($(find . -maxdepth 1 -iname \*.bmp))
for element in "${imgs[@]}"
do
	imgFileNoExt=${element%.*}
	if [ ! -f $imgFileNoExt.svg ]
	then
	echo tracing $element . . .
	# "${POTRACE_PRESET[@]}" expands to each element as a separate quoted argument; adding "$element" after that adds the file name to each expansion; the terminal interprets each as a separate command to run:
	potrace -s --flat -z minority "${POTRACE_PRESET[@]}" "$element"
	fi
done

echo Traced all bmp files. Done.

# Abridged potrace reference; for details, refer to: http://potrace.sourceforge.net/potrace.1.html
# Usage: potrace [options] [filename...]
  # <filename>                 - an input file
 # -o, --output <filename>    - write all output to this file
 # --                         - end of options; 0 or more input filenames follow
# Backend selection:
 # -b, --backend <name>       - select backend by name
 # -e, --eps                  - EPS backend (encapsulated PostScript) (default)
 # -p, --postscript           - PostScript backend
 # -s, --svg                  - SVG backend (scalable vector graphics)
 # -g, --pgm                  - PGM backend (portable greymap)
 # -b pdf                     - PDF backend (portable document format)
 # -b pdfpage                 - fixed page-size PDF backend
 # -b dxf                     - DXF backend (drawing interchange format)
 # -b geojson                 - GeoJSON backend
 # -b gimppath                - Gimppath backend (GNU Gimp)
 # -b xfig                    - XFig backend
# Algorithm options:
 # -z, --turnpolicy <policy>  - how to resolve ambiguities in path decomposition
 # -t, --turdsize <n>         - suppress speckles of up to this size (default 2)
 # -a, --alphamax <n>         - corner threshold parameter (default 1)
 # -n, --longcurve            - turn off curve optimization
 # -O, --opttolerance <n>     - curve optimization tolerance (default 0.2)
 # -u, --unit <n>             - quantize output to 1/unit pixels (default 10)
 # -d, --debug <n>            - produce debugging output of type n (n=1,2,3)
# Scaling and placement options:
 # -P, --pagesize <format>    - page size (default is letter)
 # -W, --width <dim>          - width of output image
 # -H, --height <dim>         - height of output image
 # -r, --resolution <n>[x<n>] - resolution (in dpi) (dimension-based backends)
 # -x, --scale <n>[x<n>]      - scaling factor (pixel-based backends)
 # -S, --stretch <n>          - yresolution/xresolution
 # -A, --rotate <angle>       - rotate counterclockwise by angle
 # -M, --margin <dim>         - margin
 # -L, --leftmargin <dim>     - left margin
 # -R, --rightmargin <dim>    - right margin
 # -T, --topmargin <dim>      - top margin
 # -B, --bottommargin <dim>   - bottom margin
 # --tight                    - remove whitespace around the input image
# Color options, supported by some backends:
 # -C, --color #rrggbb        - set foreground color (default black)
 # --fillcolor #rrggbb        - set fill color (default transparent)
 # --opaque                   - make white shapes opaque
# SVG options:
 # --group                    - group related paths together
 # --flat                     - whole image as a single path
# Postscript/EPS/PDF options:
 # -c, --cleartext            - do not compress the output
 # -2, --level2               - use postscript level 2 compression (default)
 # -3, --level3               - use postscript level 3 compression
 # -q, --longcoding           - do not optimize for file size
# PGM options:
 # -G, --gamma <n>            - gamma value for anti-aliasing (default 2.2)
# Frontend options:
 # -k, --blacklevel <n>       - black/white cutoff in input file (default 0.5)
 # -i, --invert               - invert bitmap
# Progress bar options:
 # --progress                 - show progress bar
 # --tty <mode>               - progress bar rendering: vt100 or dumb

# Dimensions can have optional units, e.g. 6.5in, 15cm, 100pt.
# Default is inches (or pixels for pgm, dxf, and gimppath backends).
# Possible input file formats are: pnm (pbm, pgm, ppm), bmp.
# Backends are: eps, postscript, ps, pdf, pdfpage, svg, dxf, geojson, pgm, 
# gimppath, xfig.