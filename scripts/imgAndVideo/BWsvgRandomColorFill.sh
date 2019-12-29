# DESCRIPTION
# Takes an .svg file and fills all white (ffffff) shape regions with random colors, n times, OR from colors randomly selected from a list (per optional paramater passed to script).

# USAGE
# Pass this script three parameters (the third is optional), being:
# $1 an .svg file name and
# $2 how many random color fill variations of that file to create, and
# $3 OPTIONAL; will produce random colors if absent: a flat text file list of hexadecimal RGB color codes, one per line, from which to choose random colors for this fill. NOTE: each hex color must be preceded by #. This script makes a copy of the .svg with a name being a time stamp. NOTE: This expects an svg colored via hexadecimal color code fills where areas to color are designated in the svg as #ffffff. If your svg is not thus, potrace the original black bitmap using potraceAllBMPs.sh, or use the SVGOMG service (convert your SVG file online) at: https://jakearchibald.github.io/svgomg/ -- or use SVGO re https://github.com/svg/svgo and https://web-design-weekly.com/2014/10/22/optimizing-svg-web/ -- It converts rgb values to hex by default. BUT NOTE: for our purposes, DO NOT use the "minify colors" option. 

# TO DO:
# - Items listed in comments that read TO DO
# - make it use an optional global hex color schemes dir tree (search path), otherwise search in path script is invoked from.
# - make it name the target file after the color scheme.
# ? - implement an optional buffer memory of the last three colors used, and if the current picked color is among them, pick another color until it is not among them.
# ? - replace all this functionality with a script that works with a nodejs svg library, if possible? It could be run from a CLI on any local nodejs (node) install.

# CODE

svgFileName=$1
generateThisMany=$2
paletteFile=$3


# If no $3 parameter passed to script, create an array of 18 random hex RGB color values. Otherwise, create the array from the list in the filename specified in $3.
if [ -z "$3" ]
	then
		echo no parameter \$3 passed to script\; generating random hex colors array . . .
		for i in $( seq 9 );
		do
# TO DO: make this work faster with one pre-generated string in memory that you bite six bytes off in increments.
		randomHexString=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 6`
				echo Random color \#"$randomHexString" . . .
		rndHexColors[$i]=$randomHexString
		done
# TO DO: make this save the generated hex color scheme to a plain text file.
	else
		# Search for specified palette file in palettesRootDir (if that dir exists; if it doesn't, exit with an error) :
		if [ -e ~/palettesRootDir.txt ]
		then
			palettesRootDir=$(< ~/palettesRootDir.txt)
					echo palettesRootDir.txt found\;
					echo searching in path $palettesRootDir --
					echo for file $paletteFile . . .
			hexColorSrcFullPath=`gfind $palettesRootDir -iname "$paletteFile"`
			echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
			if [ "$hexColorSrcFullPath" == "" ]
				then
					echo File of name $paletteFile NOT FOUND in the path this script was invoked from OR in path \"$palettesRootDir\" \! ABORTING script.
					exit
				else
					echo File name $paletteFile FOUND in the path this script was invoked from OR in path \"$palettesRootDir\" \!
					echo File is at\:
					echo $hexColorSrcFullPath
					echo PROCEEDING. IN ALL CAPS.
			fi
		else
			echo !--------------------------------------------------------!
			echo file ~/palettesRootDir.txt \(in your root user path\) not found. This file should exist and have one line, being the path of your palette text files e.g.:
			echo
			echo /cygdrive/c/_ebdev/scripts/imgAndVideo/palettes
			echo
			echo ABORTING script.
			echo !--------------------------------------------------------!
			exit
	fi
		echo Generating hex colors array from file $paletteFile . . .
		gsed 's/#//g' $hexColorSrcFullPath > srcHexColorsNoHash.txt
		mapfile -t rndHexColors < srcHexColorsNoHash.txt
				for element in ${rndHexColors[@]}
				do
					echo Color $element . . .
				done
		rm srcHexColorsNoHash.txt
fi

sizeOf_rndHexColors=${#rndHexColors[@]}
sizeOf_rndHexColors=$(( $sizeOf_rndHexColors - 1))		# Else we get an out of range error for the zero-based index of arrays.
		# echo val of sizeOf_rndHexColors is $sizeOf_rndHexColors
		# Dev test to assure no picks are out of range (with the first seq command in this script changed to 3):
		# for i in $( seq 50 )
		# do
			# pick=`shuf -i 0-"$sizeOf_rndHexColors" -n 1`
			# echo sizeOf_rndHexColors val \(\*zero-based\*\) is $sizeOf_rndHexColors
			# echo rnd pick is $pick
		# done
for i in $( seq $generateThisMany )
do
	echo Generating variant $i of $generateThisMany . . .
	timestamp=`date +"%Y%m%d_%H%M%S_%N"`
	newFile="$timestamp"rndColorFill__$svgFileName
	cp $svgFileName $newFile
	numFFFFFFstringsInFile=`grep -c "[fF][fF][fF][fF][fF][fF]" $newFile`		# The repeated [fF] is to allow for six f characters lowercase OR uppercase in a row, because svgs vary in representing hex digits in upper or lower case letters.
	for j in $( seq $numFFFFFFstringsInFile )
	do
		pick=`shuf -i 0-"$sizeOf_rndHexColors" -n 1`
		randomHexString="${rndHexColors[$pick]}"
				# echo pick is $pick
				echo Randomly picked hex color \#"$randomHexString" for fill . . .
			# ULTIMATE CLUGE WORKAROUND for problem mixing ' and " in a gsed command; NOTE that the $ is escaped--in some insane way that for some reason the shell insists! :
			# NOTE: I was at first using $j instead of 1 to delimit which instance should be replaced, but D'OH! : that Nth instance changes (for the next replace by count operation) after any inline replace!
			# Changing Nth instance of string re: http://stackoverflow.com/a/13818063/1397555
					# test command that worked [by replacing 5th instance of the string?] :
					# gsed ':a;N;$!ba;s/FFFFFF/3f2aff/5' test.svg
			# -- expanding on that pattern, the following command changes the first instance of [fF]\{6\} in the file (I think?) :
		sedCommand=`echo gsed -i \'":a;N;\\$!ba;s/[fF]\{6\}/$randomHexString/1"\' $newFile`
				# echo $sedCommand
		echo $sedCommand > tempCommand.sh
				chmod 777 ./tempCommand.sh
		./tempCommand.sh
	done
	rm ./tempCommand.sh
	chmod 777 $newFile
done
