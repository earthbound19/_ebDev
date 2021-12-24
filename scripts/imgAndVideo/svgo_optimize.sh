# DESCRIPTION
# Optimizes an svg input file (writing the result to `<original_file_base_name>_opt.svg`) including color code conversion suited for random recoloring via `SVGrandomColorReplace.sh`.

# DEPENDENCIES
# A `nodejs` install with the `svgo` (svgomg) package installed.

# USAGE
# - First examine the file `.svgo.yml` in this distribution, and if you wish to, copy it over the `.svgo.yml` file that comes with `svgo`. Among other things it preserves path IDs and long hex color form. UPDATE: that will need to change; the newest version of SVGO doesn't use yaml config anymore, it uses .js. For now, you're forced to either use the default config or update the yaml to the newest js and figure out how/where to copy that/use that. RE: https://github.com/svg/svgo/releases/tag/v2.0.0
# - Run this script with one parameter $1 (required), being the name of the svg file for which you want an ~_opt.svg file produced in the same directory; e.g.:
#    svgo_optimize.sh inputFile.svg
# NOTES
# - This may misbehave when run via `Cygwin`. I've at times found that if I copy and paste the printed command to a cmd prompt, it works OK . . . except the result displays wonky in Internet Explorer and inkscape.


# CODE
fileNameNoExt=${1%.*}
renderTargetFile="$fileNameNoExt"_opt.svg
# Other CLI options; NOTE 2021-12-18: CLI --enable and --disable items are no longer available in SVGO. You must now follow a more difficult javascript-object-as-strings syntax to configure those, it seems, from something I read; so the following needs update if you use it:
# CLIopts="--enable=convertColors --enable=collapseGroups --disable=convertPathData"
SVGOcommand="svgo -i $1 --pretty $CLIopts -o $renderTargetFile"
echo Running command\:
echo $SVGOcommand
echo . . .
$SVGOcommand

echo "DONE. Result file is $renderTargetFile."

# OPTIONAL and DANGER: will toast original file and replace it with the converted one; comment out if you do not want that! :
# rm $1 && mv "$fileNameNoExt"_opt.svg $1


# SVGO CLI OPTIONS NOTES
# -i input.svg -o output.svg
# -p precision; want 3 decimal points
# --pretty
# ? --multipass
# --config=CONFIG : Config file to extend or replace default

# SVGO USAGE
# svgo [OPTIONS] [ARGS]
# Options:
  # -h, --help : Help
  # -v, --version : Version
  # -i INPUT, --input=INPUT : Input file, "-" for STDIN
  # -s STRING, --string=STRING : Input SVG data string
  # -f FOLDER, --folder=FOLDER : Input folder, optimize and rewrite all *.svg files
  # -o OUTPUT, --output=OUTPUT : Output file or folder (by default the same as the input), "-" for STDOUT
  # -p PRECISION, --precision=PRECISION : Set number of digits in the fractional part, overrides plugins params
  # --config=CONFIG : Config file or JSON string to extend or replace default
  # --disable=DISABLE : Disable plugin by name
  # --enable=ENABLE : Enable plugin by name