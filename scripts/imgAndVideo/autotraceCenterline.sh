# DESCRIPTION
# Wrapper that invokes autotrace.exe with custom parameters to retrieve (or attempt to retrieve) centerline paths from raster art of e.g. lines.

# USAGE
# Invoke with one parameter $1, being a .bmp bitmap (or other supported format?) to trace. Result will be found as $1_centerline.svg

# autotrace --centerline --despeckle-level=4 --remove-adjacent-corners --output-file="$1"_centerline.svg --output-format=svg $1
# OR:
autotrace --centerline --output-file="$1"_centerline.svg --output-format=svg $1
# The resultant .svg file doesn't display in modern browsers unless I resave it via inkscape, with this command:
inkscape -f "$1"_centerline.svg -l "$1"_centerline.svg

echo DONE. Input file "$1" traced to "$1"_centerline.svg. Unless\/until I find another fix\, I recommend you open that file in Inkscape\, make a trivial change and re-save it\, or it may not e.g. render in a modern browser.