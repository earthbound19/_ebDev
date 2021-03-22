# DESCRIPTION
# Via a combination of scripts (which in turn call scripts), gets M shades times N chromacities (color saturation intensities) of every color in a palette. Essentially, obtains and lists a gamut of tints, shades and saturated and unsaturated colors for a palette. Results will be in palette files named after each color.

# USAGE
# Run with these parameters:
# - $1 source file name of palette in .hexplt format (a list of RGB color hex codes)
# - $2 how many shades to get for each color in the palette
# - $3 how many chromacities to get for every resultant shade.
# Example that will get 7 shades and 6 chromacities for every resultant shade, for every color in 16_max_chroma_med_light_hues.hexplt:
#    getNshadesXchromacities_from_hexplt.sh 16_max_chroma_med_light_hues.hexplt 7 6

# CODE
# DELETE this line and the next if your script doesn't need them; otherwise adapt per your needs:
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source .hexplt file name) passed to script. Exit."; exit 1; else sourceHexpltFile=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (how many shades to get for each color in palette) passed to script. Exit."; exit 1; else nShades=$2; fi
if [ ! "$3" ]; then printf "\nNo parameter \$3 (how many chroma to get per shade) passed to script. Exit."; exit 1; else nChroma=$3; fi

# check for any pre-existing subfolders in this folder, and if there are any, exit with an error:
subfoldersCheckArray=( $(listAllSubdirs.sh FLORFELNAUT) )
if [ "${#subfoldersCheckArray[@]}" != "0" ]; then echo; echo "PROBLEM: subfolders exist in this folder. This script needs to operate in a folder which has no subfolders in it. Remove or move the subfolder out of this folder. Will exit script."; exit 1; fi

getNshadesOfColorsCIECAM02.sh $sourceHexpltFile $nShades
# temporarily rename source hexplt so it won't be sorted into any subfolder:
mv $sourceHexpltFile "$sourceHexpltFile"__tmp_bak__rename_this_to_original_file_name_if_you_find_this.txt
moveTypeToBasenamedFolder.sh hexplt
# rename that back since we sorted:
mv "$sourceHexpltFile"__tmp_bak__rename_this_to_original_file_name_if_you_find_this.txt $sourceHexpltFile
printf "\n~\n"
read -p "NOTE: at this writing, via the coding of getNshadesOfColorsCIECAM02.sh, resultant .hexplt files only go from the J (brightness) value of colors to dark, but you may wish to include tints. If so, open a CIECAM02 color tool--such as this: https://eeeps.github.io/cam02-color-schemer/ -- and get the tints you want and add them to the .hexplt files in the subfolders. Then press any key to continue."

subdirsOneLevelDeep=( $(listAllSubdirs.sh FLORFELNAUT) )
for folderName in ${subdirsOneLevelDeep[@]}
do
	pushd .
	cd $folderName
	# there will only be one file name, and this stores it in a variable:
	sourceHexpltFileName=$(ls *.hexplt)
	getNchromasOfColorsCIECAM02.sh $sourceHexpltFileName $nChroma
	# remove the ~shades .hexplt file (as it essentially was just folded into the ~xchromas palette:
	rm $sourceHexpltFileName
	# concatenate those chroma results into one file named after hue hexplt: ->
	# ->
	fileNameNoExt=${sourceHexpltFileName%.*}
	# -> this monster of a command gets the .hexplt files into an array sorted by the time they were created first:
	hexpltFileNamesArray=( $(find . -maxdepth 1 -name "*.hexplt" -print0 -printf "%T@ %Tc %p\n" | sort -n | sed 's/.* [0-9]\{3,\} \.\/\(.*\)/\1/g') )
	# -> loop over that array, and for each file append their contents to the destination file
	# -> clobber the dest. file if it already exists with a blank file:
	printf "" > "$fileNameNoExt"_"$nChroma"_chromas.txt
	for file in ${hexpltFileNamesArray[@]}
	do
		cat $file >> "$fileNameNoExt"_"$nChroma"_chromas.txt
	done
	# delete the source .hexplt files we just concatenated:
	rm *.hexplt
	# rename the tmp .txt to a proper .hexplt file::
	mv "$fileNameNoExt"_"$nChroma"_chromas.txt "$fileNameNoExt"_"$nChroma"_chromas.hexplt
	# render the resultant palette, with $nChroma columns and rows per number of hues (.hexplt files we concatenated) :
	renderAllHexPalettes.sh YORP 260 NULL $nChroma $hexpltFilesCount
	# move everything up one folder (to final destination folder) :
	mv * ..
	popd
	# destroy temp subfolder (since we got the files we want back up here in this folder:
	rm -rf $folderName
done

# render the shades palettes:
renderAllHexPalettes.sh YORP 260 NULL $nShades 1
