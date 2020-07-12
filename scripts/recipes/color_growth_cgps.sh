# DESCRIPTION
# invokes color_growth.py, once for every .cgp preset
# in the current directory and all subdirectories.
# creates .rendering temp files of the same name as
# a render target file name so that you can interrupt/
# resume or run multiple simultaneous renders.

# USAGE
# - From a folder with one or more .cgp preset files, run
#  this script:
# color_growth_cgps.sh
#  It will invoke color_growth.py repeatedly with each
#  .cgp preset as the parameter to --LOAD_PRESET.
# NOTES
# - This is designed to run in multiple simultaneous
#  batch jobs. When rendering a preset, it cretes a file
#  named after the preset but with the .rendering extension,
#  (it does not ever delete them; you have to). Another,
#  simultaneous run of this script will check for the
#  .rendering file and skip render of that preset if it
#  finds one. This is useful for computers with many
#  cores where you can even run multiple of this same
#  task on one core if it's not loading the CPU too much.
# - You may customize parameters by tweaking
#  and uncommenting one of the extraParameters lines,
#  just below (or adding your own).


# CODE
# extraParameters='--WIDTH 850 --HEIGHT 180 --SAVE_PRESET False --SAVE_EVERY_N 9'
# extraParameters='--WIDTH 1920 --HEIGHT 1080 --SAVE_PRESET False --SAVE_EVERY_N 1400'
extraParameters='--SAVE_EVERY_N 1226'
# extraParameters='--SAVE_PRESET False'

pathToScript=`whereis color_growth.py | sed 's/color_growth: \(.*\)/\1/g'`
presetsArray=(`find . -maxdepth 1 -type f -name "*.cgp" -printf '%f\n'`)

for element in ${presetsArray[@]}
do
	cgpFileNoExt=`echo "${element%.*}"`
	renderLogFileFile=$cgpFileNoExt.rendering
	if ! [ -e $renderLogFileFile ]
	then
		# create render stub file so that other or subsequent runs of this script
		# in the same directory will skip renders in progress or already done:
		printf "Rendering . . ." > $renderLogFileFile
		echo ""
		echo "Render log file $renderLogFileFile was not found;"
		echo "Rendering . . ."
		python $pathToScript --LOAD_PRESET $element $extraParameters
		# rm $cgpFileNoExt.rendering
# OPTIONAL, and may save your CPU from burning out:
		echo "Letting CPU cool off; pausing 300 seconds . . ."; sleep 300
	else
		echo ""
		echo "Render log file $renderLogFileFile found;"
		echo "SKIPPING render . . ."
	fi
done