# DESCRIPTION
# Invokes color_growth_hexplt_multiColor.sh (note that is ~hexplt,
# where this is ~hexplts) repeatedly, for every .hexplt file in the
# current directory, with hard-coded settings. Moreover, makes N
# renders from each hexplt file. Hack the variables at the start of
# the script to alter preferences.

# DEPENDENCIES
# See the DEPENDENCIES section of the script this calls.

# TO DO
# Paramaterize this script?

# USAGE
# With so many .hexplt files of your liking in the directory you
# want this to work on, run this script.


# CODE
howManyColors='ALL'
width=1920
height=1080
extraParameters="'--RSHIFT 1 --SAVE_EVERY_N 7150 --RAMP_UP_SAVE_EVERY_N True --TILEABLE True'"
renderEachPaletteNtimes=6

palettes=(`gfind . -maxdepth 1 -type f -name "*.hexplt" -printf '%f\n'`)

# Do everything in the inner for palette .. loop $renderEachPaletteNtimes:
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
			# If I write this to a script and execute it, the script I call won't wait for Python to terminate before returning, it seems? And the #resulting .cgp files were incomplete; but writing it to a script file and invoking the script works:
			echo "Writing command to tmp_color_growth_hexplts_multiColor_Ntimes_script__t6KGRUQPBDE7Y4.sh:"
			echo "color_growth_hexplt_multiColor.sh $palette $howManyColors $width $height $extraParameters"
			echo "color_growth_hexplt_multiColor.sh $palette $howManyColors $width $height $extraParameters" > tmp_color_growth_hexplts_multiColor_Ntimes_script__t6KGRUQPBDE7Y4.sh
			./tmp_color_growth_hexplts_multiColor_Ntimes_script__t6KGRUQPBDE7Y4.sh
			rm ./tmp_color_growth_hexplts_multiColor_Ntimes_script__t6KGRUQPBDE7Y4.sh
		fi
	done	
done