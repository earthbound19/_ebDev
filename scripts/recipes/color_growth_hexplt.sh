# DESCRIPTION
# repeatedly runs `color_growth.py` with a new `--RANDOM_SEED` and one custom `--CUSTOM_COORDS_AND_COLORS` coordinate/color each run; the colors are from a `.hexplt` file passed to the script; other things per preferences customizable via parameters. Also, it creates stub `.rendering` files when it starts a render, to enable concurrent runs (of more than one instance of this script running at the same time, but without duplicating work). See USAGE.

# USAGE
# Run with at least three required parameters, and optional additional parameters:
# - $1 the file name of a .hexplt palette file.
# - $2 the `--WIDTH` (as expected by `color_growth.py`) of intended render(s).
# - $3 the `--HEIGHT` (as expected by `color_growth.py`) of intended render(s).
# - $4 OPTIONAL. Either A) the keyword RND_BASIC_POS or B) a pair of x,y values (a component of that expected by the `color_growth.py` --CUSTOM_COORDS_AND_COLORS switch), surrounded by single quote marks, for example '1799,1799'. (Note that while the `--CUSTOM_COORDS_AND_COLORS` switch expects parenthesis around those values (among other things), it may break it to do that here. Don't use parenthesis here). If not provided, the x,y values are highly randomized (read on). If you need to use $5 but don't want to "use" $4 (leave it at default), pass the keyword NULL as $4.
# - $5 OPTIONAL. Any additional arguments that can be accepted by `color_growth.py`, surrounded by double quote marks, for example '--WIDTH 3600 --HEIGHT 3600 --RSHIFT 8 --BG_COLOR [255,0,255] --BORDER_BLEND True --TILEABLE True --SAVE_EVERY_N 0'. If $5 is not provided, no additional parameters are used, or in other words the variable that controls them is not even set; it is effectively empty as far as the script is concerned). If $5 is provided, you may be able to use `--WIDTH` and `--HEIGHT` parameters in it if they wouldn't cause errors vs. $2 and $3. (I suppose only if in $5 they are larger than $2 and $3?) If you want to use $6 but not $5, pass the keyword NULL as $5. NOTE that any use of the --GROWTH_CLIP flag must surround the tuple (the parenthesis) with a single quote mark (while the entirety of $5 itself must be surrounded by double quotes). For example: "--RSHIFT 3 --GROWTH_CLIP '(2,6)' --SAVE_PRESET False"
# - $6 OPTIONAL. Pass any value for this, and the script will skip the 300 second pause (cool-down period) after every render. Only do this if your renders are lightweight or your CPU stays relatively cooled very well.
# For every color in the .hexplt file ($1), the script will make a `color_growth.py` render.
# EXAMPLE RUN with only a palette, and width 1920 x 1080:
#    color_growth_hexplt.sh RAHfavoriteColorsHex.hexplt 1920 1080
# See comments in `hexplt2rgbplt.sh` for expected PATH for any `.hexplt` file ($1).
# If $4 is passed as `RND_BASIC_POS`, for every `color_growth.py` call (render), the script will randomly choose from any of these six origin coordinates: a hard-coded upper-left, upper-right, lower-left, lower-right, center, or a random coordinate (it will do the math to determine any of them). If $4 is passed as a string matching the Python tuple format (but surrounded by single quote marks), e.g. '(100,50)' (where the first number is an X (across) coordinate, and the second number is a Y (down) coordinate), the script will use that as the coordinate component of the `--CUSTOM_COORDS_AND_COLORS` on every run it does of `color_growth.py`. If $4 is not provided, or is passed as the keyword NULL, the script will choose a random coordinate from the whole image range (anywhere within WIDTH and HEIGHT) each render.
# EXAMPLE RUN with the same parameters but also using the `RND_BASIC_POS` keyword for $4:
#    color_growth_hexplt.sh collectedColors1.hexplt 1920 1080 RND_BASIC_POS
# EXAMPLE RUN that would cause the script to use a specific origin coordinate for every render (not `RND_BASIC_POS`):
#    color_growth_hexplt.sh collectedColors1.hexplt 1920 1080 '(2027,400)'
# EXAMPLE RUN that would cause the script to choose a random coordinate from the whole canvas range each render:
#    color_growth_hexplt.sh collectedColors1.hexplt 1920 1080 NULL
# EXAMPLE RUN that passes custom parameters (with different values than previous examples for the other parameters) -- NOTE that for parameter $5, the tuple passed with --GROWTH_CLIP must be surrounded by single quote marks, but the entire parameter $5 must be in double quote marks to distinguish it syntactically vs. the single quote marks:
#    color_growth_hexplt.sh collectedColors1.hexplt 9600 2400 '(4800,1280)' "--RSHIFT 3 --GROWTH_CLIP '(2,6)' --SAVE_PRESET False"
# NOTES
# - Just before every render that is started by calling `color_growth.py`, this script creates a .rendering file named after the RGB decimal values for the given render, e.g. `RGB_COLORS__168-230-207.rendering`. When you're done with a batch, you may delete all the .rendering files (they are intended to be temporary). The intent of these .rendering files is for concurrent runs of this script to check for them, and not duplicate work on a render if it finds one. How that works is that the script checks for a .rendering stub before it would otherwise make a render with that color, and skips the render if it finds an existing (match) .rendering file. You can do multiple simultaneous batch renders (exploiting multiple processors/threads) this way too. To interrupt and resume a batch, keep the .rendering files. If a render was interrupted, you may resume it by deleting the associated .rendering file, then run this script.
# - Even though `color_growth.py` internally zero-indexes coordinates (1 is 0), pass WIDTH and HEIGHT ($2 and $3) as the actual human-indexed (counting starts from 1, or natural numbers) values, because `color_growth.py` does the zero-indexing adjustment internally.


# CODE
# START PARAMETER PARSING AND GLOBALS SETUP.
if ! [ "$1" ]; then printf "\nNo parameter \$1 (a .hexplt file). Exit."; exit; else sourcePaletteHexplt=$1; fi

# I would subtract one from WIDTH and HEIGHT (if passed) because the coordinates are zero-indexed color_growth.py, but color_growth.py accounts for that--so no need to!:
if ! [ "$2" ]; then printf "\nNo parameter \$2 (--WIDTH for color_growth.py) passed to script. Exit."; exit; else WIDTH=$2; fi

if ! [ "$3" ]; then printf "\nNo parameter \$3 (--HEIGHT for color_growth.py) passed to script. Exit."; exit; else HEIGHT=$3; fi

# Cases for $4: provided and RND_BASIC_POS, or provided and something else, or not provided. Handle each case; script will do different things depending on how these control blocks set up variables. Note that in the case of "$4" == "NULL" (which we only check NOT for), a variable $coordinateSuperParameter is never created, and the script later checks whether that variable was created:
if [ "$4" ] && [ "$4" == "RND_BASIC_POS" ]; then coordinateSuperParameter=$4; printf "\nParameter \$4 passed to the script as '$coordinateSuperParameter'; using that."; fi
if [ "$4" ] && [ "$4" != "RND_BASIC_POS" ] && [ "$4" != "NULL" ]; then coordinateSuperParameter=$4; printf "\nParameter $\4 passed to the script as '$coordinateSuperParameter'; using that."; fi

if [ "$5" ] && [ "$5" != "NULL" ]; then additionalParams=$5; printf "\n\nParameter \$5 passed to script as '$additionalParams'. Using that."; fi

# If the following is false (no $6 passed to script), no SKIP_COOLDOWN variable will be set, and the script will only skip cooldown if that is set:
if [ "$6" ]; then SKIP_COOLDOWN='True'; printf "\n\nParameter \$6 passed to script; a variable was set to skip cooldown period between renders."; fi

pathToScript=$(getFullPathToFile.sh color_growth.py)
# END PARAMETER PARSING AND GLOBALS SETUP.

hexplt2rgbplt.sh $sourcePaletteHexplt
paletteFileNoExt=$(echo "${1%.*}")
convertedPaletteFile=$paletteFileNoExt.rgbplt

# I tried iterating over a created array from the palette file, and different commands expecting different IFS delimiters (I know not which) scewed it up. So, just iterate over lines in a file:
while read -r element
do
	# Only render if there is no .rendering stub file named after the
	# RGB (decimal) values being used for this proposed render:
	renderLogFile=$(echo "RGB_COLORS__""$element"".rendering" | sed 's/ /-/g')
	if ! [ -e $renderLogFile ]
	then
		# create render stub file so that other or subsequent runs of this script
		# in the same directory will skip renders in progress or already done:
		printf "A render associated with information in this file name is underway by user $USERNAME on $HOSTNAME." > $renderLogFile
		echo ""
		echo "Render log file $renderLogFile was not found;"
		echo "Rendering . . ."
		# randomize parameters in ranges:
		rndSeedValForParam=$(shuf -i 0-4294967296 -n 1)
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
				# invertRGBvalForParam=$(echo $invertRGBvalForParam | tr ' ' ',')
		rgbValForParam=$(echo $element | tr ' ' ',')
		rshiftParam=$(shuf -i 1-8 -n 1)

		# get an RND clip range (will be overriden by anything in $additionalParams, as that is passed last in the color_growth.py parameter set):
		lowGrowthClipParam=$(shuf -i 1-8 -n 1)
		highGrowthClipParamAddend=$(shuf -i 2-8 -n 1)
		highGrowthClipParam=$(($lowGrowthClipParam + $highGrowthClipParamAddend))
		# reduce the upper value to max if it's beyond max:
		if [ $highGrowthClipParam -gt 8 ]; then echo highGrowthClipParam value $highGrowthClipParam greater than max allowed \(8\)\; reducing to 8\.; highGrowthClipParam=8; fi
		echo "That'll be --GROWTH_CLIP ($lowGrowthClipParam,$highGrowthClipParam), Capn'."

		# ==== BEGIN ALTER coordinateArg; depending: ====
		# If coordinateSuperParameter was set AND is RND_BASIC_POS (see USAGE), roll six-sided die to assign any of "basic" positions as origin coordinate center (to $coord_tuple); ELSE (if it was set as something else), use its value:
		if [ "$coordinateSuperParameter" == "RND_BASIC_POS" ]
		then
			# Pick a random number. If outside range of numbered cases below, pick x,y coordinates in center of canvas (default case). If inside range, pick coordinates from among more fundamental geometric positions among those cases:
			picked_number=$(shuf -i 1-10 | head -n 1)
			case $picked_number in
				1) coord_tuple="1,1" ;;				# upper left as x,y
				2) coord_tuple="$WIDTH,1" ;;			# upper right
				3) coord_tuple="1,$HEIGHT" ;;			# lower left
				4) coord_tuple="$WIDTH,$WIDTH" ;;		# lower right
				5)
					# $ get rnd coordinates for anywhere on canvas:
					first_number=$(shuf -i 1-$WIDTH | head -n 1)
					second_number=$(shuf -i 1-$HEIGHT | head -n 1)
					coord_tuple="$first_number,$second_number"
					;;
				*)
					# DEFAULT case: get center coords via bc terminal calculator:
					coord_tuple_element_one=$(echo "$WIDTH / 2" | bc)
					coord_tuple_element_two=$(echo "$HEIGHT / 2" | bc)
					coord_tuple="$coord_tuple_element_one,$coord_tuple_element_two"
					;;
			esac
		else
			coord_tuple=$coordinateSuperParameter
		fi
		# BUT if coordinateSuperParameter was not set, or was passed as NULL, pick a random coord.
		if ! [ "$coordinateSuperParameter" ] || [ "$coordinateSuperParameter" == "NULL" ]
		then
			first_number=$(shuf -i 1-$WIDTH | head -n 1)
			second_number=$(shuf -i 1-$HEIGHT | head -n 1)
			coord_tuple="$first_number,$second_number"
		fi
		# ==== END ALTER coordinateArg; depending: ====
		# random string component to add to temp shell script name, so multiple insances of this can run simultaneously without clobbering one another's temp scripts:
		rndString=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6)
		tmp_script_file_name=RUN_this__gQThHuC5RTeeRn__"$rndString".sh
		echo "Calling color_growth.py via temp script $tmp_script_file_name . . ."
		# Works around problems escaping characters by writing the whole command
		# to a script (which still needs " ( and ) escaped though?!) :
# TO DO: make a tmp. cgp file and load it with --LOAD_PRESET from a temp script instead (as in call_get_img_RND_CCC_for_color_growth-py.sh). For reasons. start of code to use: rndStringForTempPreset=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6) -- and a timestamp string and the RGB vals?
# TO DO: hunt down and fix cause of this error also: Traceback (most recent call last): File "C:/_ebdev/scripts/imgAndVideo/color_growth.py", line 732, in <module> canvas[ element[0][1]-1 ][ element[0][0]-1 ] = color_values     # LORF! IndexError: list index out of range
		echo "python $pathToScript --WIDTH $WIDTH --HEIGHT $HEIGHT --RSHIFT $rshiftParam -b [$rgbValForParam] --CUSTOM_COORDS_AND_COLORS '[[($coord_tuple),[$rgbValForParam]]]' --RECLAIM_ORPHANS True --BORDER_BLEND True --TILEABLE False --STOP_AT_PERCENT 1 -a 0 --RANDOM_SEED $rndSeedValForParam -q 1 --GROWTH_CLIP \($lowGrowthClipParam,$highGrowthClipParam\) --SAVE_PRESET True $additionalParams" > $tmp_script_file_name
		./$tmp_script_file_name
		echo ""
		echo "pausing 4 seconds before deleting temp shell script . . ."
		sleep 4
		rm ./$tmp_script_file_name
		# When I got this to work and saw initial output of so many colors, I exclaimed:
		# OH MY HONKEY-TONK STARS OF WRATH!
		#
		# OPTIONAL, and may save your CPU from burning out; if SKIP_COOLDOWN was NOT set (we should NOT skip cooldown), then cool down. If it WAS set, skip cooldown:
		if ! [ "$SKIP_COOLDOWN" ]; then echo "Letting CPU cool off; pausing 300 seconds . . ."; sleep 300; else echo "SKIPPING COOLDOWN period as instructed by parameter to this script."; fi
	else
		echo ""
		echo "Render log file $renderLogFile found;"
		echo "SKIPPING render . . ."
	fi
done < $convertedPaletteFile