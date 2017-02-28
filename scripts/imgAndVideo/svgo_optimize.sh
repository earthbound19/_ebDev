# DESCRIPTION
# Optimizes an svg input file (writing the result to <originalFileName>_opt.svg) including color code conversion suited for random recoloring via BWsvgRandomColorFill.sh.

# DEPENDENCIES
# A nodejs install with the svgo package installed, and the svgo_config.json file in the same directory as this script. Also svgo_BWsvgRandomColorFill_target_config.js in the same directory as this script?

# INSTALLATION
# 1) install the prerequisites ;) 
# EITHER overwrite convertColors.js with the contents of svgo_config.json or, if you can (I couldn't), get svgo to recognize this as a legitimate config file. The only changes from the default config at this writing are:
	# shorthex: false,
	# shortname: false

# USAGE
# REQUIRES one parameter $1, being the name of the svg file for which you want an ~_opt.svg file produced in the same directory; e.g.:
# thisScript.sh inputFile.svg


# ==== GLOBALS
fileNameNoExt=`echo $1 | sed 's/\(.*\)\.svg/\1/g'`
		# echo fileNameNoExt val is\: $fileNameNoExt
# I wish I had thought of this trick to get an executable or script path into a variable long ago! ; another project is going to use paletteFile=`which flam3-palettes.xml` :
# TO DO: make the following detected and automatically parametrically changed;
# ALSO TO DO: use a cross-platform tool instead of cygpath to figure this.
				# AT THE MOMENT, FAIL; dunno why; maybe it needs the config file to be in the same path as convertColors.js from the svgo package?
				# configFileName='convertColors_noShortHex.js'
				# OS=WINDOWS
				# if [[ $OS == "WINDOWS" ]]
				# then
					# OS_SVGO_CONFIG_FILE_FULL_PATH=`which $configFileName`		# this produces a full path and file name result.
				# cp $OS_SVGO_CONFIG_FILE_FULL_PATH ./
				# fi
				# WANT TO MAKE THIS WORK: --config=""$configFileName" e.g. :
				# svgoCLIopts="--disable=mergePaths --enable=removeRasterImages --disable=convertShapeToPath --config=$configFileName"
svgoCLIopts="--disable=mergePaths --enable=removeRasterImages --disable=convertShapeToPath"
# ==== END GLOBALS

SVGOcommand="svgo -i $1 -p 3 --pretty $svgoCLIopts -o "$fileNameNoExt"_opt.svg"
echo Running command\:
echo $SVGOcommand
echo . . .
$SVGOcommand

# rm ./$configFileName

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