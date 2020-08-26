# DESCRIPTION
# Runs color_growth_hexplt_multiColor.sh (note that is ~hexplt, where this is ~hexplts) repeatedly, for every .hexplt file in the current directory, with customizable settings for how many colors to use, and width, and height (defaults used if no settings provided). See USAGE.

# DEPENDENCIES
# See the DEPENDENCIES section of color_growth_hexplt_multiColor.sh.

# USAGE
# With so many .hexplt palette files of your liking in the directory you want this to work on, run this script, with these optional parameters, which all default to hard-coded values if you don't pass them (examine the parameter parsing right after the CODE comment) :
# - $1 OPTIONAL. How many colors in the palette to use. May be fewer or greater than the number of colors in palette. For details and other options for this parameter, see color_growth_hexplt_multiColor.sh. If not provided, defaults to all colors in each palette.
# - $2 OPTIONAL. How many renders to make from colors in each palette.
# - $3 OPTIONAL. Width of renders, in pixels.
# - $4 OPTIONAL. Height of renders, in pixels.
# - $5 OPTIONAL. Extra parameters, surrounded by double quote marks, in the format expected by color_growth.py.
# - $6 OPTIONAL. Pass any string for this (for example 'HORBWAITH'), and the script will skip the 300-second cool-down period between renders.
# Example command that will use 15 colors from each palette, and also make 5 renders for each, of width 1920 pixels and height 1080, passing the extra switches '--RSHIFT 1 --SAVE_EVERY_N 0' :
#    color_growth_hexplts_multiColor_Ntimes.sh 15 5 1920 1080 '--RSHIFT 1 --SAVE_EVERY_N 0'


# CODE
if [ "$1" ]; then howManyColors=$1; else howManyColors='ALL'; fi
if [ "$2" ]; then renderEachPaletteNtimes=$2; else renderEachPaletteNtimes=6; fi
if [ "$3" ]; then width=$3; else width=1920; fi
if [ "$4" ]; then height=$4; else height=1080; fi
if [ "$5" ]
then
	extraParameters="'$5'"
else
	extraParameters="'--RSHIFT 1 --SAVE_EVERY_N 7150 --RAMP_UP_SAVE_EVERY_N True --TILEABLE True'"
fi
# If the following is false (no $6 passed to script), no SKIP_COOLDOWN variable will be set, and the script will only skip cooldown if that is set:
if [ "$6" ]; then SKIP_COOLDOWN='True'; printf "\n\nParameter \$6 passed to script; a variable was set to skip cooldown period between renders."; fi

palettes=(`find . -maxdepth 1 -type f -name "*.hexplt" -printf '%f\n'`)

# renderEachPaletteNtimes times, render an image for every palette:
for ((i=1;i<=renderEachPaletteNtimes;i++))
do
	for palette in ${palettes[@]}
	do
		# check for .rendering stub files and don't render if they exist
		# (allows interrupt/resume of render batch); if they don't exist,
		# render:
		paletteFileNoExt=`echo "${palette%.*}"`
		renderLogFileFile="$paletteFileNoExt"_variant"$i".rendering
		if [ -e $renderLogFileFile ]
		then
			echo ""
			echo "Render log file $renderLogFileFile found;"
			echo "SKIPPING render . . ."
		else
			printf "Rendering . . ." > $renderLogFileFile
			echo ""
			echo "Render log file $renderLogFileFile was not found;"
			echo "Rendering . . ."
			# If I write this to a script and execute it, the script I call won't wait for Python to terminate before returning, it seems? And the #resulting .cgp files were incomplete; but writing it to a script file and running the script works; also, if we run multiple of this at the same time we want the scripts to have different names, so get an rndStr to add to the temp script name:
			rndString=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6`
			tmpScriptFileName=tmp_color_growth_hexplts_multiColor_Ntimes_script__t6KGRUQPBDE7Y4_"$rndString".sh
			echo "Writing command to $tmpScriptFileName:"
			echo "color_growth_hexplt_multiColor.sh $palette $howManyColors $width $height $extraParameters"
			echo "color_growth_hexplt_multiColor.sh $palette $howManyColors $width $height $extraParameters" > ./$tmpScriptFileName
			./$tmpScriptFileName
			printf "Waiting 4 seconds before deleting ~multiColor_Ntimes~ temp script file . . .\n"
			sleep 4
			rm ./$tmpScriptFileName
			# OPTIONAL, and may save your CPU from burning out; if SKIP_COOLDOWN was NOT set (we should NOT skip cooldown), then cool down. If it WAS set, skip cooldown:
			if ! [ "$SKIP_COOLDOWN" ]; then echo "Letting CPU cool off; pausing 300 seconds . . ."; sleep 300; else echo "SKIPPING COOLDOWN period as instructed by parameter to this script."; fi
		fi
	done	
done

Echo "color_growth_hexplts_multiColor_Ntimes.sh renders DONE."