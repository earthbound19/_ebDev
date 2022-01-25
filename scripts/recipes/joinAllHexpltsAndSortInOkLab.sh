# DESCRIPTION
# concatenates all .hexplt files in the current directory into one, then deduplicates colors from it and sorts it in okLab color space (using various scripts).

# DEPENDENCIES
# nodejs, the culori package for it, and various scripts in _ebDev

# USAGE
# Run without any parameters:
#    joinAllHexpltsAndSortInOkLab.sh
# Result palette name will be named after the current directory plus random characters, and printed for your information after operations are complete.


# CODE
# CONSTRUCT TARGET FILE BASENAME:
targetFileNameRNDbaseSTR=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 11)
dirBasename=$(basename $(pwd))
targetFileBasename=_"$dirBasename"__all_hexplts_concatenated__"$targetFileNameRNDbaseSTR"

# concatenate all .hexplt files into one new file:
cat *.hexplt > $targetFileBasename.txt

# sort and deduplicate the colors in it:
sortuniq.sh $targetFileBasename.txt FLOURPESCENSE

# sort colors in it in okLab space; get full path to sorting script first:
okLabScript=$(getFullPathToFile.sh rgbHexColorSortInOkLab.js)

# sort colors in resultant .hexplt, in okLab space, and capture output to array:
colorsResult=( $(node $okLabScript -i $targetFileBasename.txt) )

# overwrite original file from result array:
printf '%s\n' "${colorsResult[@]}" > $targetFileBasename.txt

# rename result:
mv $targetFileBasename.txt $targetFileBasename.hexplt

printf "\nDONE. Result file is $targetFileBasename.hexplt."
