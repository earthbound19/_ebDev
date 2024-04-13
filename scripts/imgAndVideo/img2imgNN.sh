# DESCRIPTION
# Resizes an image of type $1, in the current directory, by nearest-neighbor method, to target format $2, with the longest edge scaled up (or down!) to pixels $3. The shortest edge is scaled to maintain aspect, but that can be overriden to change aspect, with $4. Nearest neighbor method will keep hard edges, or look "pixelated." Uses GraphicsMagick, unless the file is ppm or pbm format, in which case it uses IrfanView (which to my knowledge is Windows only). Also updates timestamp of target file to match the source it was converted from, for file by time stamp sorting (or any other) reference.

# DEPENDENCIES
# GraphicsMagick, touch, checkForTerminalProblematicPath.sh

# USAGE
# Run with the following parameters:
# - $1 source file name
# - $2 destination image format
# - $3 scale by nearest neighbor method to this many pixels _in the longest dimension_ (whether that is X or Y). If the source image is the same dimension in X and Y, just use either.
# - $4 OPTIONAL. Force this dimension _for the shorter side_, regardless of aspect. Scales by nearest neighbor method to this many pixels for the shortest edge, even if that forces a different aspect (including making that side longer). If omitted, the shortest edge is calculated automatically to maintain aspect.
# Example command that will scale the longest edge of a pbm to 640 px (by nearest neighbor method), and scale the other edge automatically to whatever length will maintain the original aspect, and output to a png image:
#    img2imgNN.sh input.pbm png 640
# OR, to force a given longest and shortest dimension for a ppm:
#    img2imgNN.sh input.ppm png 640 480
# KNOWN ISSUE
# If you try to run this against files at a very long path name and/or with very long file names (excessive path depth), gm identify and/or convert may throw errors about files not existing (no image returned etc.) when in fact they exist. The workaround is to move work to a path that's much higher/shorter. OR it may be that it has a hard time if there are terminal-unfriendly characters in the path (such as spaces). Therefore this script calls another script to check for those problems and exits with an error if either is found.


# CODE
# PATH CHECK AND THROW IF ERROR
checkForTerminalProblematicPath.sh
checkError=$?
if [ $checkError != 0 ]; then printf "\nERROR! errorlevel $checkError assigned from check of checkForTerminalProblematicPath.sh. Examine that script to isolate error. EXIT from $0"; exit 4; fi

# PARAMETER CHECKING
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source image file name) passed to script. Exit."; exit 1; else srcFileName=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (target image format) passed to script. Exit."; exit 2; else destFormat=$2; fi
if [ ! "$3" ]; then printf "\nNo parameter \$3 (scale by nearest neighbor method to this many pixels X) passed to script. Exit."; exit 3; else targetLongDim=$3; fi

# MAIN WORK
imgFileExt=${srcFileName##*.}
targetFileName=${srcFileName%.*}.$destFormat
if [ ! -f $targetFileName ]; then
			# DEPRECATED: if source file is ppm or pbm, use IrfanView -- graphicsmagick works fine now (if at one point it didn't?) for converting ppm format files.
			#if [ $imgFileExt == "ppm" ] || [ $imgFileExt == "pbm" ]; then
			#	echo converting ppm file via i_view32 . . .
			#	if [ "$4" ]		# $4 is shorter edge length override, if it's passed
			#	then
			#		iViewTargetShortDimParam="/resize_short=$4"
			#		iViewAspectParam=""
			#	fi
				# re: http://www.etcwiki.org/wiki/IrfanView_Command_Line_Options
				# ROTATE 90 DEGREES OPTION; uncomment next line (used with other options) :
				# extraIrfanViewParam1="/rotate_r"
				# because irfanView at some point started needing the full path to an image for scripting (or something about my environment changed such that that is needed?), prefix the full path to it:
			#	currentDir=$(pwd); currentDir=$(cygpath -w $currentDir)
			#	i_view64 "$currentDir\\$srcFileName /resize_long=$targetLongDim $iViewTargetShortDimParam $iViewAspectParam $extraIrfanViewParam1 /convert=$targetFileName"
			# otherwise use graphicsmagic:
			#else
		echo converting image via GraphicsMagick . . .
		# GRAPHICSMAGIC PAREMETER SETUP VIA SCRIPT PARAMS
		# Identify whether width or height of src image is longer (or the same!) :
		# re: http://jeromebelleman.gitlab.io/posts/graphics/gmresize/
		# re: http://www.graphicsmagick.org/GraphicsMagick.html#details-format
		srcIMGw=$(gm identify $srcFileName -format "%w")
		srcIMGh=$(gm identify $srcFileName -format "%h")
		if [ "$4" ]		# $4 is shorter edge length override, if it's passed
		then
			if (($srcIMGw >= $srcIMGh))
			then
				gmScaleParam="-sample $targetLongDim"x"$4!"
			else
				gmScaleParam="-sample $4"x"$targetLongDim!"
			fi
		else
			gmScaleParam="-sample $targetLongDim"
			# if clause end from deprecated irfanview option:
			#fi
		fi
		gm convert $srcFileName $gmScaleParam $targetFileName
		# update timestamp of target file to match the source it was converted from, for file by time stamp sorting (or any other) reference:
		touch -r $srcFileName $targetFileName
	echo "Converted $srcFileName to $targetFileName and modified time stamp of target to match source."
else
	echo target file $targetFileName already exists\; skipping.
fi