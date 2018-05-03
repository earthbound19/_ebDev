# DESCRIPTION
# Optimizes an svg input file (writing the result to <originalFileName>_opt.svg) including color code conversion suited for random recoloring via BWsvgRandomColorFill.sh.

# DEPENDENCIES
# A nodejs install with the svgo (svgomg) package installed.

# USAGE
# First examine and if you wish to copy the file .svgo.yml in this distribution over the .svgo.yml file that comes with svgo. Among other things it preserves path IDs and long hex color form.
# Invoke this script with one parameter $1 (required), being the name of the svg file for which you want an ~_opt.svg file produced in the same directory; e.g.:
# thisScript.sh inputFile.svg
# NOTE that the CLIopts variables, if you uncomment them, override the .svgo.yml config file.
# ALSO NOTE that this may misbehave when invoked via cygwin. I've at times found that if I copy and paste the printed command to a cmd prompt, it works ok . . . except the result displays wonky in Internet Explorer and inkscape. :(

fileNameNoExt=${1%.}

# CLIopts="--enable=convertColors --enable=collapseGroups --disable=convertPathData"

SVGOcommand="svgo -i $1 --pretty $CLIopts -o "$fileNameNoExt"_opt.svg"
echo Running command\:
echo $SVGOcommand
echo . . .
$SVGOcommand

# OPTIONAL and DANGER: will toast original file--comment out if you do not want that! :
rm $1 && mv "$fileNameNoExt"_opt.svg $1


# SVGO CLI OPTIONS NOTES
# -i input.svg -o output.svg
# -p precision; want 3 decimal points
# --pretty
# ? --multipass
# --config=CONFIG : Config file or JSON string to extend or replace default

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