# DESCRIPTION
# Wrapper that runs autotrace.exe with custom parameters to retrieve (or attempt to retrieve) centerline paths from raster art of e.g. lines. Result will be found as `<input_file_base_name>_centerline.svg`.

# USAGE
# Run with these parameters:
# - $1 a .bmp bitmap (or other supported format?) file name to trace.
# Example:
#    autotraceCenterline.sh input.bmp


# CODE
# Example command:
#    autotrace --centerline --despeckle-level=4 --remove-adjacent-corners --output-file="$1"_centerline.svg --output-format=svg $1
# Another example:
#    autotrace --centerline --output-file="$1"_centerline.svg --output-format=svg $1
# The resultant .svg file doesn't display in modern browsers unless I resave it via inkscape, with this command:
inkscape -f "$1"_centerline.svg -l "$1"_centerline.svg

echo DONE. Input file "$1" traced to "$1"_centerline.svg. Unless\/until I find another fix\, I recommend you open that file in Inkscape\, make a trivial change and re-save it\, or it may not e.g. render in a modern browser.