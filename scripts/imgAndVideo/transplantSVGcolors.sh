# IN DEVELOPMENT

# DESCRIPTION
# Applies color fills from a source svg to a target svg that has the same path names, saving to a new file.

# USAGE

# DEPENDENCIES
# - gsed, svgo
# Prerequisites:
# - a run of svgo_optimize.sh (following the configuration instructions therein) against both color transplant recipient and donar svg files. svgo_optimize.sh is to get source and destination svgs into a format with all paths on one line and attributes sorted just so, so that the gsed command in this script will even work on the files as expected. Specifically, all paths and fills must be attributes (not styles) in the svgs this operates on, with the path, and the id and fill attributes in this pattern: `<path id="path4524" fill="#eb6a06"` .. also, you must have and specify (by parameter, see USAGE) a folder which contains only the svg files you wish to transplant color from.
# - an svg file that colors will be transplanted into from another svg, then the file copied.
# - a color donor svg file.

# ./thisScript.sh SVGcolorTransplantRecipient.svg SVGcolorTransplantSRCfileName.svg


# CODE
SVGcolorTransplantRecipient=$1
SVGcolorTransplantSRCfileName=$2

# build new file name for cloned transplant . . . this is so immoral.
# get filename without extension:
imgFileNoExt=${SVGcolorTransplantRecipient%.*}
# strip any path off SVGcolorTransplantSRCfileName:
# gsed has to be used instead of IFS / <<< thingy because the transplant source file name may not come with a pathname/file.svg structure (it may not be in a subfolder):
SVGcolorTransplantSRCfileNameNoPath=`echo $SVGcolorTransplantSRCfileName | gsed 's/\(.*\/\)\(.*\)/\2/g'`
newSVGtransplantFileName="$imgFileNoExt"_colorTransplantsFrom_"$SVGcolorTransplantSRCfileNameNoPath"

# copy color transplant recipient to new file with acknowledged potentially much too long name:
cp $SVGcolorTransplantRecipient $newSVGtransplantFileName
echo created new transplant clone recipient svg file $SVGcolorTransplantRecipient and working on it . . .

# extract all paths and fills from svg to transplant color _from_:
gsed -n 's/.*<path id="\([^"]\{0,\}\)" fill="#\([a-fA-F0-9]\{6\}\)" .*/\1,\2/p' $SVGcolorTransplantSRCfileName > tmp_8cEX5EEK_transplantPathsAndFillsSRC.txt
# then put them in the color transplant recipient:
transplantPathsAndFillsSRCs=( $( < tmp_8cEX5EEK_transplantPathsAndFillsSRC.txt) )

for colorTransplantDatum in ${transplantPathsAndFillsSRCs[@]}
do
	# split that svg pathID and hex color fill attribute (which is separated by commas) into two vars on comma delimiter, re: https://stackoverflow.com/questions/10520623/how-to-split-one-string-into-multiple-variables-in-bash-shell
	IFS=',' read SVGpathName SVGfillHexTransplantATTR <<< $colorTransplantDatum
	# echo SVGpathName value is\: $SVGpathName
	# echo SVGfillHexTransplantATTR value is\: $SVGfillHexTransplantATTR
	sedCommand="s/\(.*<path id=\""$SVGpathName"\" fill=\"\)#[a-zA-Z0-9]\{6\}\(\" .*\)/\1#"$SVGfillHexTransplantATTR"\2/g"
	gsed -i "$sedCommand" $newSVGtransplantFileName
done

echo DONE. New file is $newSVGtransplantFileName.

rm SVGcolorTransplantSRCs.txt tmp_8cEX5EEK_transplantPathsAndFillsSRC.txt
