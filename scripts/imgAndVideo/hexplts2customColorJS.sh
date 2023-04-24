# DESCRIPTION
# Creates text files of custom JavaScript palette objects with foreground and background color arrays (for example for generative art projects), from all .hexplt palette files in the current directory. Does not overwite (clobber) any existing text file. If a corresponding background palette (named <original_file_basename>_BG.hexplt) does not exist for any palette, it generates one based on colors from the original palette: it gets a highly saturated near-white tint and highly desaturated near-black shade for every color in the given .hexplt palette file. Does so by generating many other colors (via other scripts), and then gathering those two start and end results. Result JavaScript objects are written to a file named <original_palette_basename>_js.txt. If a corresponding background palette already exists, uses the colors from it instead of generating any.

# DEPENDENCIES:
# `getN_hexplt_shadesXchromas_Oklab.sh` and its dependencies.

# USAGE
# With so many .hexplt files (for example from https://github.com/earthbound19/_ebPalettes/tree/master/palettes) in the current directory, run this script:
    # ./hexplts2customColorJS.sh
# (OR run this script without ./ before it, if it is in your $PATH.)
# Result files are named after the original file but with _js added to the base, then .txt (text)

# LICENSE
# Adapted from an (at this writing) private work with authorization from its intellectual property controllers (myself, RAH, et al) to dedicate this adapted work to the Public Domain; this work (bash script) is in the Public Domain.


# CODE
# EXCLUDE any .hexplt files from this that have the pattern *_BG* in their file name (avoid creating redundant palettes and sub-bg palettes where background palettes with that in their file name wer made; do this via `not` find switch filter:
array=( $(find . -maxdepth 1 -type f -not -iname "*_BG*" -iname \*.hexplt -printf '%f\n') )

for filename in ${array[@]}
do
	fileNameNoExt=${filename%.*}
	printPaletteName=${fileNameNoExt//_/ }		# replace underscores with spaces for print palette name in js
	targetFileName="$fileNameNoExt"_js.txt
	# check for text file render target file name, and render to it if it doesn't already exist:
	if [ -f $targetFileName ]
	then
		echo "Target file $targetFileName already exists; will not overwite it. To recreate it, delete it and re-run this script."
	else
		echo "Will create target file $targetFileName . . ."
		# create everything at start of object definition up to square bracket start of palette (foreground) contents:
		printf "      {\n        name: \"$printPaletteName\",\n        fg: [" > $targetFileName
		# get colors from hexplt into array, then print them to JS objects' array content:
		lines=( $(grep -i -o '#[0-9a-f]\{6\}' $filename) )
		for line in ${lines[@]}
		do
			# remove newline:
			line=$(echo $line | tr -d '\15\32')		# horror and serious slowdown
			printf "'$line', " >> $targetFileName
		done
		# print close of fg colors array:
		printf "],\n        bg: [" >> $targetFileName
		# BUILD BACKGROUND COLORS array:
		# check for accompanying background palette; if it does not, build it. if it does, don't build it; after either scenario use its colors.:
		BGtargetFileName=${filename%.*}_BG.hexplt
		# if the bg palette does not exist, build it with its colors:
# NOTE is hear wer check if bad name?? : || [ -f "$BGtargetFileName"_BG.hexplt ]
		if [ ! -f $BGtargetFileName ]
		then
			rm -rf shadesXchromas_build_tmp
			mkdir shadesXchromas_build_tmp
			pushd .
			cd shadesXchromas_build_tmp
			cp ../$filename .
# TO DO: okLab auto-generate background palette that is all colors turned 75 percent toward nuetral gray #919191, OR 80 percent toward white, OR 80 percent toward black?
			getN_hexplt_shadesXchromas_Oklab.sh $filename 7 7 1 1 NULL FLOOFARF
			# then get start and end colors from all files; first copy of palette file out of way to not interfere:
			rm $filename
			# create array of file names of those generated .hexplts, to get their colors into tmp files named after orig. + _BG_TEMP:
			array2=( $(find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n') )
			extractedColorsArray=()
			for filename2 in ${array2[@]}
			do
				# 	UNCOMMENT ANY OF THESE sed extract (and add to array) lines that you want to get the related color for:
				extractedColorsArray+=($(sed '17q;d' $filename2))			# 17th line is very tinted, mostly desaturated
				extractedColorsArray+=($(sed '22q;d' $filename2))			# 22nd line is quite tinted and desaturated
				extractedColorsArray+=($(sed '65q;d' $filename2))			# 65th line is quite dark and desaturated
				extractedColorsArray+=($(sed '72q;d' $filename2))			# 72nd line is very shaded, even more desaturated
				# since we have our colors, delete temp palette:
				rm $filename2
			done
			# write extracted colors to bg palette file as we also build the custom js palette bg colors out:
			printf "" > $BGtargetFileName
			counter=0
			for color in ${extractedColorsArray[@]}
			do
				printf "$color" >> $BGtargetFileName
				numCols=$((${#extractedColorsArray[@]} / ${#lines[@]}))		# this is a horrifying expression
				# if this is the first line, append number of render columns indicator to .hexplt to match size of extracted colors; otherwise print newline:
				counter=$((counter + 1))
				if [[ $counter == 1 ]]
				then
					printf " columns: $numCols\n" >> $BGtargetFileName
				else
					printf "\n" >> $BGtargetFileName
				fi
				writeLine=$(echo $color | tr -d '\15\32')		# moar horror and serious slowdown
				printf "'$writeLine', " >> ../$targetFileName
				# conditionally print newlines to arrange background colors in columns to match BG colors extracter per color, for easier visual reference:
				if [ $(($counter % $numCols)) == 0 ]; then printf "\n\t\t" >> ../$targetFileName; fi
			done
			# copy generated bg hexplt up one dir where we want to keep it:
			mv $BGtargetFileName ..
			popd
			rm -rf shadesXchromas_build_tmp
			# END BUILD OF BACKGROUND COLORS ARRAY
		fi
		echo "Accompanying background colors file $BGtargetFileName either found or built; will use colors from it."
		# get colors from hexplt into array, then print them to JS objects' array content:
		bgColors=( $(grep -i -o '#[0-9a-f]\{6\}' $BGtargetFileName) )
		# write the bg colors to the array in the render target:
		for line in ${bgColors[@]}
		do
			# remove newline:
			line=$(echo $line | tr -d '\15\32')		# horror and serious slowdown
			printf "'$line', " >> $targetFileName
		done
		# print close of array and file:
		printf "]
      }" >> $targetFileName
	fi

	# remove trailing commas and spaces; this isn't supposed to work according to my brain, but it does:
	sed -i 's/\(.*\), /\1/g' $targetFileName
done