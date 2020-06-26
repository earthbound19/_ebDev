# DESCRIPTION
# Invokes color_growth_hexplt_multiColor.sh (note that is ~hexplt,
# where this is ~hexplts) repeatedly, for every .hexplt file in the
# current directory, with custom settings for how many colors to use,
# and width, and height. See USAGE.

# DEPENDENCIES
# See the DEPENDENCIES section of color_growth_hexplt_multiColor.sh

# USAGE
# With so many .hexplt files of your liking in the directory you
# want this to work on, run this script, with these optional
# parameters (which all default to hard-coded values if you don't
# pass them:
#  $1 how many colors in the palette to use. May not exceed number
# of colors in palette. To use all colors in the palette, pass the
# string 'ALL' in single quote marks. If unused, defaults to the
# string 'ALL'.
#  $2 how many renders to make from colors in each palette. If not
# provided, defaults to a hard-coded value.
#  $3 width of renders, in pixels. If not provided, defaults to a
# hard-coded value.
#  $4 height of renders, in pixels. If not provided, defaults to a
# hard-coded value.
#  $5 extra parameters, surrounded by double quote marks, in the
# format expected by color_growth.py.

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

palettes=(`gfind . -maxdepth 1 -type f -name "*.hexplt" -printf '%f\n'`)

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
			# If I write this to a script and execute it, the script I call won't wait for Python to terminate before returning, it seems? And the #resulting .cgp files were incomplete; but writing it to a script file and invoking the script works:
			echo "Writing command to tmp_color_growth_hexplts_multiColor_Ntimes_script__t6KGRUQPBDE7Y4.sh:"
			echo "color_growth_hexplt_multiColor.sh $palette $howManyColors $width $height $extraParameters"
			echo "color_growth_hexplt_multiColor.sh $palette $howManyColors $width $height $extraParameters" > tmp_color_growth_hexplts_multiColor_Ntimes_script__t6KGRUQPBDE7Y4.sh
			./tmp_color_growth_hexplts_multiColor_Ntimes_script__t6KGRUQPBDE7Y4.sh
			rm ./tmp_color_growth_hexplts_multiColor_Ntimes_script__t6KGRUQPBDE7Y4.sh
			echo "sleeping for 300 seconds to let computer cool . . ."
			sleep 300
		fi
	done	
done

Echo "color_growth_hexplts_multiColor_Ntimes.sh renders DONE."