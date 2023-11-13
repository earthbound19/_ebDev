# DESCRIPTION
# Prints interpolated colors from sRGB color $1 to $2 in steps $3, using Python inline CLI call with `coloraide` library, through any supported colors space (default HCT). Re: https://facelessuser.github.io/coloraide/colors/hct/ -- this is a wrapper for code in that page. For more pigment mixing-like gradients via HCT, this may be preferable to okLab / `get_color_gradient_OKLAB.js`.

# DEPENDENCIES
# Python installed and in your PATH, with the following supporting coloraide libraries installed, and a bash environment that will run this script
# To install the supporting coloraide libraries, run:
#    pip install coloraide
#    pip install coloraide_extras

# USAGE
# Run with these parameters:
# - $1 REQUIRED. Start color, as sRGB hex color code, e.g. '#feff06' (a bright medium yellow)
# - $2 REQUIRED. End color also as sRGB hex color code, e.g. '#00a6fe' (a medium light sky or robin-egg medium blue)
# - $3 REQUIRED. Number of colors to obtain via interpolation, e.g. 11
# - $4 OPTIONAL. Color space to interpolate through to obtain colors, for example 'hct', 'oklab', 'okhsl', or 'srgb' etc. Defaults to HCT (as 'hct') if omitted.
# For example, to obtain and print a gradient from '#feff06' to '#00a6fe' of 11 colors in default hct space, run:
#    interpolateTwoSRGBColors_coloraide.sh '#feff06' '#00a6fe' 11
# To do the same and interpolate in okHSL space, run:
#    interpolateTwoSRGBColors_coloraide.sh '#feff06' '#00a6fe' 11 okhsl
# NOTES
# - To try a lot of colorspace overrides written to .hexplt files named after them, look for bash code comments below that accomplish that in a for loop, and uncomment them (they start with a comment of "dev test hack").
# - You can output in a colorspace other than sRGB with the library this script uses; you would need to hack this script (not supported presently).


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (start color, as sRGB hex color code, e.g. '#feff06') passed to script. Exit."; exit 1; else startColor=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (end color, as sRGB hex color code, e.g. '#00a6fe') passed to script. Exit."; exit 2; else endColor=$2; fi
if [ ! "$3" ]; then printf "\nNo parameter \$3 (number of colors to obtain for gradient) passed to script. Exit."; exit 3; else nColors=$3; fi
if [ "$4" ]; then colorspaceKey="$4"; else colorspaceKey='hct'; fi

# dev test hack; comment out in production; was to sample interpolation in different color spaces:
# spaces=(
# cmyk
# hct
# okhsl
# okhsv
# oklab
# orgb
# ryb
# srgb
# ucs
# xyb
# xyz-d65
# xyz-d50
# )

# for colorspaceKey in ${spaces[@]}
# do
# Yes, I am actually passing a lot of comments to a Python call, to explain the code on revisiting:
python -c "
# reference:
# sRGB color convert from/to hex: https://facelessuser.github.io/coloraide/colors/srgb/
# interpolate through any supported space: https://facelessuser.github.io/coloraide/interpolation/
# setup for any convert space, or convert through any space: https://github.com/facelessuser/coloraide-extras

# CODE
# We can import things so that it's specifically set up to convert in a given space:
# from coloraide import Color as Base
# from coloraide.spaces.hct import HCT
# class Color(Base): ...
# Color.register(HCT())

# OR, strongly preferred for flexibility, and done here: set it up to convert in ANY supported space:
from coloraide_extras.everything import ColorAll as Color

# create sRGB color objects from hex codes
startColor = Color(\"$startColor\")
endColor = Color(\"$endColor\")

# I don't like this, but it works and I wasn't parsing these somehow correctly otherwise:
nColors = $nColors

	#UNUSED REFERENCE: use of hct for direct value create:
	# thing = Color('hct', [27.41, 113.36, 53.237], 1)
	# print(thing)
	#PRIOR, DEPRECATED, nearly equivalently functional method (produced *very slighlty different colors* sometimes;
	#here only for reference, skip on ahead to the AKTUL METHOD comment:
	#interpolate them through HCT space, OR okHSV, or ANY supported space; just change the value assigned to space='<color space name>':
	#i = Color.interpolate([startColor, endColor], space=\"$colorspaceKey\")
	# NOTE that we do ($nColors - 1) here because the interpolation starts with the start color but does not end with the end color; if we want the end color..
	#lerp = [i(x / nColors).to_string() for x in range($nColors - 1)]
	#for element in lerp:
	#    sRGBcolor = Color(element).convert('srgb').to_string(hex=True)
	#    print(sRGBcolor)
	# .. manually print the end color we want:
	#print(\"$endColor\")

# re: https://facelessuser.github.io/coloraide/interpolation/
colors = Color.steps(
	[\"$startColor\", \"$endColor\"],
	steps=$nColors,
	space=\"$colorspaceKey\",
	out_space='srgb'
)

for color in colors:
	print(color.to_string(hex=True))
" \
# > "$colorspaceKey"_test_interpolation.hexplt
# done