# DESCRIPTION
# Repeatedly invokes transplantSVGcolors.sh against a directory full of svg color transplant source files.

# USAGE
#  ./transplantSVGsDirColors.sh transplantDestinationSVGfilename.svg _SVGcolorTransplantSRCs_directoryName


# CODE
SVGcolorTransplantRecipient=$1
SVGcolorTransplantSRCsDIR=$2

gfind $SVGcolorTransplantSRCsDIR -maxdepth 1 -iname \*.svg > SVGcolorTransplantSRCs.txt
SVGcolorTransplantSRCs=( $( < SVGcolorTransplantSRCs.txt) )

for SVGcolorTransplantSRC in ${SVGcolorTransplantSRCs[@]}
do
	# echo $SVGcolorTransplantSRC
	transplantSVGcolors.sh $SVGcolorTransplantRecipient $SVGcolorTransplantSRC
done
