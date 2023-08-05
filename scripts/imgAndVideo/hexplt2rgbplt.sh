# DESCRIPTION
# Converts a .hexplt format palette (a list of RGB colors in hex format) to a list of RGB values. See also rgbplt2hexplt.sh.

# USAGE
# Run this script with one parameter, which is the .hexplt format file to convert, e.g.:
#    hexplt2RGBplt.sh RAHfavoriteColorsHex.hexplt
# NOTE
# If you have an environment variable export of EB_PALETTES_ROOT_DIR set in `~/.bashrc` (in your home folder) which contains one line, set with a Unix-style path to the folder where you keep hex palette (`.hexplt`) files (for example /some_path/_ebPalettes/palettes), this script will search all paths below that root folder for the file, IF the file is not in the same directory you run this script from. If the file is in the same directory, it uses it from the same directory. See _ebPalettes/setEBpalettesEnvVars.sh.


# CODE
# DEV NOTE
# Much of the code in this was adapted from hexplt2ppm.sh; see the file for revelation on what all this convoluted mess is.
# Use Python instead? But then I'd have to fuss with getting Python the full path to the script.. But, re: https://stackoverflow.com/questions/9210525/how-do-i-convert-hex-to-decimal-in-python
# =============
# BEGIN SETUP GLOBAL VARIABLES
if [ ! "$1" ]; then printf "No .hexplt file name passed to script. Expected as parameter \$1."; exit 1; else paletteFile=$1; fi
renderTargetFile=${paletteFile%.*}.rgbplt

# Search for palette with utility script; exit with error if it returns nothing:
hexColorSrcFullPath=$(findPalette.sh $paletteFile)
if [ "$hexColorSrcFullPath" == "" ]
then
	echo "!---------------------------------------------------------------!"
	echo "No file of name $paletteFile found. Consult findPalette.sh. Exit."
	echo "!---------------------------------------------------------------!"
	exit 1
fi
echo "File name $paletteFile found at $hexColorSrcFullPath! PROCEEDING. IN ALL CAPS."

sed -n -e "s/^\s\{1,\}//g" -n -e "s/#\([0-9a-fA-F]\{6\}\).*/\L\1/p" $hexColorSrcFullPath > tmp_d44WYq2HHQ.hexplt
hexColorSrcTMPpath=tmp_d44WYq2HHQ.hexplt
ppmBodyValues=$(tr -d '\n' < $hexColorSrcTMPpath)
rm tmp_d44WYq2HHQ.hexplt
ppmBodyValues=$(echo $ppmBodyValues | sed 's/../& /g' | tr -d '\15\32')
ppmBodyValues=$(echo $ppmBodyValues | sed 's/[a-zA-Z0-9]\{2\}/$((16#&))/g' | tr -d '\15\32')
printf "echo $ppmBodyValues" > tmp_hsmwzuF64fEWmcZ2.sh
chmod +x tmp_hsmwzuF64fEWmcZ2.sh
ppmBodyValues=$(./tmp_hsmwzuF64fEWmcZ2.sh)
rm tmp_hsmwzuF64fEWmcZ2.sh
# echo $ppmBodyValues > tmp_ykSp296krZ6X.txt
echo $ppmBodyValues | sed "s/\( \{0,1\}[0-9]\{1,\}\)\{3\}/&\n/g" > tmp_ykSp296krZ6X.txt
sed -i 's/^ \(.*\)/\1/g' tmp_ykSp296krZ6X.txt
# removes any resulting trailing double-newlines:
sed '/^$/d' tmp_ykSp296krZ6X.txt > $renderTargetFile
rm tmp_ykSp296krZ6X.txt
