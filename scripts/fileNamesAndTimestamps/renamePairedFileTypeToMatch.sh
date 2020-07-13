# DESCRIPTION
# This script should not exist. I hope I never need to use it again.
# Scenario: you have a lot of preset files of type $1 (say, .cgp)
# from which you have rendered target files $2 (say, .png). However,
# because you are silly and didn't ensure the rendered files have
# names that give you any clue what preset or source they were
# rendered from, you have no way of knowing which presets you want
# to dispose of also.
# This script attempts to solve that problem through guesswork.
# It assumes:
# 1. The batch that rendered the presets listed them in default
# find sort order
# 3. The default find sort order of the rendered files matches
# the sort order of the sources. If so, all $2 can be renamed
# to match all $1.
# WARNING: ONLY RUN THIS BATCH ON COPIES of the files. Why?
# because it renames all $2 to match all $1 on that assumption,
# which could be wrong.

# USAGE
# Run script with two parameters, being $1 the format of the
#  source files and $2 the format of the target/rendered/mystery
#  companion files which need to be renamed to match all $1.
#  Don't include the . in the format; just the extension, e.g.
#  cgp for $1 or png for $2,
# renamePairedFileTypeToMatch.sh sourceExtension targetExtensionMysteryFiles
# OR:
# renamePairedFileTypeToMatch.sh cpg png


# CODE
if ! [ "$1" ]; then echo "No paramater \$1 passed to script. Exit."; exit; else sourceFormat=$1; fi
if ! [ "$2" ]; then echo "No paramater \$2 passed to script. Exit."; exit; else destFormat=$2; fi

echo ""
read -p "WARNING: This script renames all files of type $2 after the presumed matching file name of type $1. See comments in script for details. If this is not what you want to do, press ENTER or RETURN, or CTRL+C or CTRL+Z. If this _is_ what you want to\n do, type SNARFBLOR and then press ENTER or RETURN: " CHORFL

if ! [ "$CHORFL" == "SNARFBLOR" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
		# This can work for building an array from find (I rename it find) :
		# readarray -d '' filesArray1 < <(find . -name "*.$1" -print0)
		# -- from here: https://stackoverflow.com/a/54561526/1397555
	# -- but so can this; subscriptable; adds stuff that sorts by file date (which I want here):
	filesArrayOne=(`find . -name "*.$1" -print0 -printf "%T@ %Tc %p\n" | sort -n | sed 's/.*[AM|PM] \.\/\(.*\)/\1/g'`)

	filesArrayTwo=(`find . -name "*.$2" -print0 -printf "%T@ %Tc %p\n" | sort -n | sed 's/.*[AM|PM] \.\/\(.*\)/\1/g'`)
	# demonstrates that subscripting works with these arrays:
	# echo "${filesArrayOne[4]}"
	# echo "${filesArrayTwo[4]}"
	
	# Check if arrays are same size; if not, warn and exit.
	if ! [ ${#filesArrayOne[@]} -eq ${#filesArrayTwo[@]} ]
	then
		echo ""
		echo "WARNING: Number of files found of type $1 not the same as $2."
		echo " Exiting."
		exit
	else
		echo "Number of files found of type $1 the same as $2;"
		echo " continuing . . ."
	fi

	# make rename log named after date and time, then append to it during renames:
	timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
	renameLogFileName=_rename_log__"$timestamp".txt
	printf "FILE RENAMES done $timestamp:\n\n" > $renameLogFileName
	i=0
	for element in ${filesArrayOne[@]}
	do
		typeOneFile="${filesArrayOne[$i]}"
		typeOneFileFileNameNoExt=${typeOneFile%.*}
		typeTwoFile="${filesArrayTwo[$i]}"
		echo "--"
		echo "Source candidate: $typeOneFile"
		echo "Target candidate: $typeTwoFile"
		targetRename="$typeOneFileFileNameNoExt"."$destFormat"
		echo "Target rename   : $targetRename"
		echo RENAMING . . .
		mv $typeTwoFile $targetRename
		printf "from: $typeTwoFile\n  to: $targetRename\n\n" >> $renameLogFileName
		i=$((i + 1))
	done
fi

echo DONE. See $renameLogFileName.