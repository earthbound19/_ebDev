# DESCRIPTION
# Takes an .svg file and fills all white (FFFFFF) shape regions with random colors, n times (per paramater passed to script).

# USAGE
# Pass this script three parameters (the third is optional), being:
# $1 an .svg file name and
# $2 how many random color fill variations of that file to create, and
# $3 a flat text file list of hexadecimal RGB color codes, one per line, from which to choose random colors for this fill. This makes a copy of the .svg with a name being a time stamp. NOTE: This expects an svg colored via hexadecimal color code fills. If your svg is not thus, potrace the original black bitmap using potraceAllBMPs.sh, or use the SVGOMG service (convert your SVG file online) at: https://jakearchibald.github.io/svgomg/ -- or use or SVGO re https://github.com/svg/svgo and https://web-design-weekly.com/2014/10/22/optimizing-svg-web/ -- but NOTE: DO NOT use the "minify colors" option. It converts rgb values to hex by default.

# TO DO? : implement an optional buffer memory of the last three colors used, and if the current picked color is among them, pick another color until it is not among them.


# CODE
# If no $1 parameter passed to script, create an array of 9 random hex RGB color values. Otherwise, create the array from the list in the filename specified in $1.
if [ -z ${3+x} ]
	then
		echo Generating random hex colors array . . .
		for i in $( seq 11 );
		do
# TO DO: make this work faster with one pre-generated string in memory that you bite six bytes off in increments.
		randomHexString=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 6`
				echo Random color \#"$randomHexString" . . .
		rndHexColors[$i]=$randomHexString
		done
	else
		echo Generating hex colors array from file $3 . . .
		mapfile -t rndHexColors < $3
				for element in ${rndHexColors[@]}
				do
					echo Color $element . . .
				done
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
for i in $( seq $2 )
do
	echo Generating variant $i of $1 . . .
	timestamp=`date +"%Y%m%d_%H%M%S_%N"`
	newFile="$timestamp"rndColorFill__$1
	cp $1 $newFile
	numFFFFFFstringsInFile=`grep -c "[fF][fF][fF][fF][fF][fF]" $newFile`		# The repeated [fF] is to allow for six fs lowercase OR uppercase in a row (svgs vary in representing hex digits in upper or lower case letters.)
	for j in $( seq $numFFFFFFstringsInFile )
	do
		pick=`shuf -i 0-"$sizeOf_rndHexColors" -n 1`
		randomHexString="${rndHexColors[$pick]}"
				# echo pick is $pick
				echo Randomly picked hex color \#"$randomHexString" for fill . . .
			# ULTIMATE CLUGE WORKAROUND for problem mixing ' and " in a sed command; NOTE that the $ is escaped--in some insane way that for some reason the shell insists! :
			# NOTE: I was at first using $j instead of 1 to delimit which instance should be replaced, but D'OH! : that nth instance changes (for the next replace by count operation) after any inline replace!
			# Changing nth instance of string re: http://stackoverflow.com/a/13818063/1397555
					# test command that worked:
					# sed ':a;N;$!ba;s/FFFFFF/3f2aff/5' test.svg
		sedCommand=`echo sed -i \'":a;N;\\$!ba;s/[fF]\{6\}/$randomHexString/1"\' $newFile`
				# echo $sedCommand
		echo $sedCommand > tempCommand.sh
				chmod 777 ./tempCommand.sh
		./tempCommand.sh
	done
	rm ./tempCommand.sh
done

# DEV NOTES
# test file wut.svg:
# ----
# first line
# second line
# third line
# jack=1
# fifth line
# jack=
# seventh line
# jack=
# blergh
# fjloor
# jack0328203
# fwewf
# ----

# working command that replaces the 4th instance of jack in the file with jill:
# sed ':a;N;$!ba;s/jack/jill/4' wut.svg