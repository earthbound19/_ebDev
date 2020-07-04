# DESCRIPTION: invokes the potrace utility to convert all black and white .bmp images (in the directory in which this script is invoked) to convert them to .svg vector images.

# DEPENDENCIES: potrace.

# USAGE: ensure that this script and potrace are both in your $PATH, and open a terminal in the directory of .bmp images. Invoke this script by name from the terminal. WARNING: depending on whether the relevant code line is commented out, this will delete the original .bmp images! NOTES: It will not trace a bmp image if the target svg file already exists. To retrace, delete the target svg file, and invoke this script again. Also, the script considers white a background color and black the line/trace area color.


# CODE
imgs=$(gfind . -iname \*.bmp)
for element in "${imgs[@]}"
do
	imgFileNoExt=`echo $element | sed 's/\(.*\)\..\{1,4\}/\1/g'`
	if ! [ -a $imgFileNoExt.svg ]
	then
	echo tracing $element . . .
	# original command:
	# potrace -n -s --group -r 24 -C \#000000 --fillcolor \#ffffff $element
		# Variations for different image types/preferences; also:
		# POTRACE OPTIONS REFERENCE:
		# -a = angle threshold (1 means widest angle, 0 means most acute--really no--angle); -O = optimization threshold (0 will optimize less, 1 will optimize most); r = resolution (dots per inch)?
		# potrace -n -s --group -r 72 -u 5 -t 4 -a 10 -O 10 -C \#000000 --fillcolor \#ffffff $element
		# potrace -s -t 2 -a 0.73 -r 150 -O 0.71 -C \#000000 --fillcolor \#ffffff $element
		potrace -s -t 12 -a 0.88 -r 150 -O 0.86 -C \#000000 --fillcolor \#ffffff $element
		# potrace -s -t 4 -a 0.84 -r 150 -O 0.347 -C \#000000 --fillcolor \#ffffff $element
	fi
# ! --------
# OPTIONAL--COMMENT OUT IF YOU DON'T WANT THE ORIGINAL IMAGE DELETED! :
# rm $element
# ! --------
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