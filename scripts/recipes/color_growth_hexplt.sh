# DESCRIPTION
# repeatedly invokes color_growth.py, once for each color
# in a pallete $1 (converted from .hexplt to rgbplt format),
# also randomly varying the seed each run. Tracks renders
# by creating .rendering files named after the RGB (decimal)
# values passed to color_growth.py (and saved in resulting .cgp
# render config files); this allows you to avoid duplicate
# renders from simultanious/restarted runs.

# USAGE
# Invoke with one parameter, being the name of a .hexplt
# file you want to do this for. See comments in
# hexplt2rgbplt for expected PATH for .hexplt files.
# example invocation:
# color_growth_fast_multi_colors.sh RAHfavoriteColorsHex.hexplt
# NOTE that it will create a .rendering file named after the
# RGB decimal values for the given render. When you're done with
# a batch, you may delete all the .rendering files (they are
# intended to be temporary). To interrupt and resume a batch,
# keep the .rendering files (but delete the newest one if a
# render was interrupted); the script checks for them before
# calling color_growth.py for a render using a given color,
# and skips the render if it finds an existing (match)
# .rendering file. You can do multiple simultaneous batch
# renders (exploiting multiple processors/threads) this way too.


# CODE
if ! [ "$1" ]; then echo "No parameter \$1 (a .hexplt file). Exit."; exit; fi

hexplt2rgbplt.sh $1

paletteFileNoExt=`echo "${1%.*}"`
convertedPaletteFile=$paletteFileNoExt.rgbplt
pathToScript=`whereis color_growth.py | gsed 's/color_growth: \(.*\)/\1/g'`

# uncomment any of the following to add its optional additional arguments:
# extraArgs='--SAVE_EVERY_N 6'
# extraArgs='--WIDTH 20480 --HEIGHT 720 --SAVE_EVERY_N 0 --BORDER_BLEND False'
# extraArgs='--WIDTH 8640 --HEIGHT 1800 --SAVE_EVERY_N 0 --BORDER_BLEND False'
# extraArgs='--WIDTH 9600 --HEIGHT 2400 --SAVE_EVERY_N 0 --BORDER_BLEND False'
extraArgs='--WIDTH 3600 --HEIGHT 3600 --SAVE_EVERY_N 0'

# I treid iterating over a created array from the palette file, and different commands expecting different IFS delimiters I know not which scewed it up. Just iterate over lines in a file:
while read -r element
do
	# Only render if there is no .rendering stub file named after the
	# RGB (decimal) values being used for this proposed render:
	renderLogFile=`echo "RGB_COLORS__""$element"".rendering" | gsed 's/ /-/g'`
	if ! [ -e $renderLogFile ]
	then
		# create render stub file so that other or subsequent runs of this script
		# in the same directory will skip renders in progress or already done:
		printf "Rendering . . ." > $renderLogFile
		echo ""
		echo "Render log file $renderLogFile was not found;"
		echo "Rendering . . ."
		# randomize parameters in ranges:
		rndSeedValForParam=`shuf -i 0-4294967296 -n 1`
				# DEPRECATED; because sometimes the inverse of a color is ugly with it;
				# In cases where you know it won't be, you may want to uncomment this
				# indented block; then also be sure to set $invertRGBvalForParam in -b:
				# invert that color param for background, by subtracting each from 255:
				# invertRGBvalForParam=""
				# for value in $element
				# do
				# 	invert=$((255 - $value))
				#	invertRGBvalForParam="$invertRGBvalForParam $invert"
				# done
				# invertRGBvalForParam=`echo $invertRGBvalForParam | tr ' ' ','`
		rgbValForParam=`echo $element | tr ' ' ','`
		rshiftParam=`shuf -i 1-8 -n 1`
		lowGrowthClipParam=`shuf -i 1-3 -n 1`
		highGrowthClipParamAddend=`shuf -i 1-5 -n 1`
		highGrowthClipParam=$(($lowGrowthClipParam + $highGrowthClipParamAddend))
		# reduce the upper value to max if it's beyond max:
		if [ $highGrowthClipParam -gt 8 ]; then echo highGrowthClipParam value $highGrowthClipParam greater than max allowed \(8\)\; reducing to 8\.; highGrowthClipParam=8; fi
		echo "Calling color_growth.py with custom values rgbValForParam $rgbValForParam, invertRGBvalForParam $invertRGBvalForParam, rndSeedValForParam $rndSeedValForParam, rshiftParam $rshiftParam, lowGrowthClipParam $lowGrowthClipParam, highGrowthClipParamAddend $highGrowthClipParamAddend, highGrowthClipParam $highGrowthClipParam . ."
		# random string component to add to temp shell script name, so multiple insances of this can run simultaneously without clobbering one another's temp scripts:
		rndString=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6`
		tmp_script_file_name=RUN_this__gQThHuC5RTeeRn__"$rndString".sh
# echo that is $tmp_script_file_name
		# Works around problems escaping characters by writing the whole command
		# to a script (which still needs " ( and ) escaped though?!) :
		echo "python $pathToScript --WIDTH 200 --HEIGHT 100 --RSHIFT $rshiftParam -b [$rgbValForParam] -c [$rgbValForParam] --RECLAIM_ORPHANS True --BORDER_BLEND True --TILEABLE False --STOP_AT_PERCENT 1 -a 0 --RANDOM_SEED $rndSeedValForParam -q 1 --GROWTH_CLIP \($lowGrowthClipParam,$highGrowthClipParam\) --SAVE_PRESET True $extraArgs" > $tmp_script_file_name
# ALT COMMAND with custom hard-coded coord but still using color parameter:
# echo "python $pathToScript --WIDTH 200 --HEIGHT 100 --RSHIFT $rshiftParam -b [$rgbValForParam] --CUSTOM_COORDS_AND_COLORS '[[(1799,1799),[$rgbValForParam]]]' --RECLAIM_ORPHANS True --BORDER_BLEND True --TILEABLE False --STOP_AT_PERCENT 1 -a 0 --RANDOM_SEED $rndSeedValForParam -q 1 --GROWTH_CLIP \($lowGrowthClipParam,$highGrowthClipParam\) --SAVE_PRESET True $extraArgs" > $tmp_script_file_name
		./$tmp_script_file_name
		echo ""
		echo "pausing 4 seconds before deleting temp shell script . . ."
		sleep 4
		rm ./$tmp_script_file_name
		# When I got this to work and saw initial output of so many colors, I exclaimed:
		# OH MY HONKEY-TONK STARS OF WRATH!
		#
		# OPTIONAL, and may save your CPU from burning out:
		echo "Letting CPU cool off; pausing 300 seconds . . ."; sleep 300
	else
		echo ""
		echo "Render log file $renderLogFile found;"
		echo "SKIPPING render . . ."
	fi
done < $convertedPaletteFile