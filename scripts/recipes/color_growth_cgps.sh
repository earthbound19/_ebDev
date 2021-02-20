# DESCRIPTION
# runs `color_growth.py` once for every `.cgp` preset in the current directory and all subdirectories. creates .rendering temp files of the same name as a render target file name so that you can interrupt / resume or run multiple simultaneous renders.

# USAGE
# Run with or without these optional parameters:
# - $1 OPTIONAL. Any extra arguments as usable by color_growth.py, surrounded by single or double quote marks. These will override any arguments that use the same switch or switches which are in the .cgp file(s). To use $2 but not this (or to use the built-in defaults for this), pass an empty string ('') for this.
# - $2 OPTIONAL. Anything, for example the string 'PLIBPLUP', which will cause the script to skip the cooldown period after every render.
# An example that uses parameter $1:
#    color_growth_cgps.sh '--WIDTH 850 --HEIGHT 180 --SAVE_PRESET False --SAVE_EVERY_N 7150 --RAMP_UP_SAVE_EVERY_N True'
# An example that uses parameters $1 and $2:
#    color_growth_cgps.sh '--WIDTH 850 --HEIGHT 180 --SAVE_PRESET False --SAVE_EVERY_N 7150 --RAMP_UP_SAVE_EVERY_N True' PLIBPLUP
# An example that uses parameter $2 but leaves it to use the defaults for $1:
#    color_growth_cgps.sh '' PLIBPLUP


# NOTES
# This is designed to run in multiple simultaneous batch jobs, for example from multiple computers reading and writing to a network drive, or from one computer with many CPU cores, which will allow multiple simultaneous runs of renders if it does not load the CPUs too much. To accomode multiple simultaneous runs, the script does this:
# - On run of a render for a given .cgp preset, it creates a file named after the preset but with the .rendering extension (it does not ever delete them; you have to).
# - But before it makes that file, it checks for the existence of it. If it already exists, it moves on to the next preset render task. Therefore, if one run of the script created the preset already (to signify that a render associated with it is underway), another run of the script will not duplicate that work.


# CODE
if [ "$1" ]; then extraParameters=$1; fi

bypassCooldownPeriod="False"
if [ "$2" ]; then bypassCooldownPeriod="True"; fi

pathToScript=$(getFullPathToFile.sh color_growth.py)
presetsArray=( $(find . -maxdepth 1 -type f -name "*.cgp" -printf '%f\n') )

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
		echo "Render log file $renderLogFileFile was not found; rendering via command:"
		echo "python $pathToScript --LOAD_PRESET $element $extraParameters"
		python $pathToScript --LOAD_PRESET $element $extraParameters
# OPTIONAL, and may save your CPU from burning out:
		if [ "$bypassCooldownPeriod" == "False" ]
		then
			echo "Will pause 300 seconds to let CPU(s) cool off . . ."; sleep 300
		else
			echo "Will bypass cooldown period per parameter passed to this script."
		fi
	else
		echo ""
		echo "Render log file $renderLogFileFile found;"
		echo "SKIPPING render . . ."
	fi
done