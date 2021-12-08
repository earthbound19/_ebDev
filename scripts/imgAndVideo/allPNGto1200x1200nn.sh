# DESCRIPTION
# creates a 1200x1200 png resized copy, by nearest neighbor method, of every png in the current directory. Intended for square color field previews of palettes rendered via renderAllHexPalettes.sh. Files are named after the original but append 1200x1200nn to the base file name.

# WARNING
# This overwrites any target file names of the same name without warning.

# USAGE
# Run without any parameters:
#    allPNGto1200x1200nn.sh


# CODE
pngFilesList=( $(find . -maxdepth 1 -iname "*.png" -printf "%P\n") )

# hard-coded globals:
convertResolution="1200x1200"
convertedFileNameTag=rs"$convertResolution"nn

for fileName in ${pngFilesList[@]}
do
	echo "----"
	targetFileName=${fileName%.*}_"$convertedFileNameTag".png
	# check if fileName includes "rs1200x1200nn". If it does, skip conversion (because we would be almost certainly making a reconvert of a conveted target, and end up with a filename like _rs1200x1200nn_rs1200x1200nn or more repeats).
	# - grep it:
	echo $fileName | grep -q rs1200x1200nn
	# - check if errorlevel is NOT zero; if it is, the grep did not match, and we should convert. otherwise, the skip conversion and print notice that target exists.
	if [ "$?" != "0" ]
	then
		# this will only work with the ! (escaped here with a backslash), which forces the wrong aspect:
		echo operating on $fileName . . .
		gm convert $fileName -sample $convertResolution\! $targetFileName
	else
		echo Convert target would be named $targetFileName\; redundant. Skipping conversion.
	fi
done
