# DESCRIPTION
# Creates a .jpg (by default) file from an .svg file passed as parameter $1.

# USAGE
# Run with these parameters:
# - $1 The svg file name to create an image from e.g. in.svg
# - $2 OPTIONAL. Longest side in pixels for rendered output image. Default 4280 if not given.
# - $3 OPTIONAL. Target file format e.g. png or jpg -- default jpg if not given.
# - $4 A hex color code (format ffffff, no pound/hex symbol) which will be used to render the svg background (if it has a transparent background). If it does not match the regex [a-f0-9]{6} (you can pass anything as this parameter), a hard-coded hex color will be used. See the BACKGROUND COLOR OPTIONS comment to hack that. IF OMITTED, the background will be transparent.


# CODE
# TO DO
# - Add an rnd bg color option?
# - Or rnd background choice from a hexplt file?

# ==== START SET GLOBALS
# If parameter $1 not present, notify user and exit. Otherwise use it and continue.
if ! [ "$1" ]; then echo "No parameter \$1. Exit."; exit; else svgFileName=$1; svgFilenameNoExtension=${svgFileName%.*}; fi
# If no image size parameter, set default image size of 4280.
if ! [ "$2" ]; then IMGsize=4280; echo SET IMGsize to DEFAULT 7680; else IMGsize=$2; echo SET IMGsize to $2; fi
# If no image format parameter, set default image format of jpg.
if ! [ "$3" ]; then IMGformat=png; echo SET IMGformat to DEFAULT png; else IMGformat=$3; echo SET IMGformat to $3; fi
# If no $4), set bg transparent, otherwise, if $4, check if matches [a-z0-9]{6}, and if that, use that; if not that, use a default.
if ! [ "$4" ]
then
	backgroundColorParam="-background none"; echo SET parameter DEFAULT \"-background none\";
else
	echo background color control parameter passed\; checking if parameter is a hex color code . . .
	# Check errorlevel $? after piping $4 to grep search pattern. Errorlevel will be 0 if match, 1 if no match:
	echo $4 | grep '[a-f0-9]\{6\}'; thisErrorLevel=$?
	if [ "$thisErrorLevel" == "0" ]
	then
		echo Hex color code verified\; setting bgHEXcolorCode to $4!
		bgHEXcolorCode=$4
		echo bgHEXcolorCode val is\: $bgHEXcolorCode
	else
		# BACKGROUND COLOR OPTIONS
		# Uncomment only one of the following options; comment out the others:
		# bgHEXcolorCode=ffffff		# white
		# bgHEXcolorCode=000000		# black
		# bgHEXcolorCode=584560		# Darkish plum?
		bgHEXcolorCode=39383b		# Medium-dark purplish-gray
				# Other potentially good black line color change options: #2fd5fe #bde4e4
		echo $4 is not a hex color code\! Background was set to default $bgHEXcolorCode\!
	fi
	# Whichever option was set, use it:
	backgroundColorParam="-background "#"$bgHEXcolorCode"
fi
# ==== END SET GLOBALS

if [ -a $svgFilenameNoExtension.$IMGformat ]
then
	echo render candidate is $svgFilenameNoExtension.$IMGformat
	echo target already exists\; will not render.
	echo . . .
else
	# Have I already tried e.g. -size 1000x1000 as described here? :  
	echo rendering target file $svgFilenameNoExtension.$IMGformat . . .
			# DEPRECATED, as it causes the problem described at this question: https://stackoverflow.com/a/27919097/1397555 -- for which the active solution is also given:
			# gm convert $backgroundColorParam -scale $IMGsize $svgFileName $svgFilenameNoExtension.$IMGformat
	# UNCOMMENT EITHER the `gm convert` or `magick` option:
	# GRAPHICSMAGICK OPTION, which breaks on some svgs optimized via svgo :(  :
	# gm convert -size $IMGsize $backgroundColorParam $svgFileName $svgFilenameNoExtension.$IMGformat
	# IMAGEMAGICK OPTION (which doesn't break that way) :
	magick -size $IMGsize $backgroundColorParam $svgFileName $svgFilenameNoExtension.$IMGformat
fi