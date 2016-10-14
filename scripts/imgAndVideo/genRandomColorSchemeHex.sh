# GENERATES RANDOM HEX COLOR SCHEMES.
# Parameters:
# $1 the number of colors to have in the generated color scheme.
# Outputs to randomly named file in e.g.
# ColorSchemesHex/random/p97b8aG4bpVGXg5p4dzCks6wPgMaKAwGcD_HexColors.txt
# $2 Optional: how many such color schemes to generate. If not provided, only one will be made.

# NOTE: at this writing, this script must be executed from the /scripts/imgAndVideo folder.
# TO DO? : Make an unsynced local folder with the absolute path to _devtools root, and reference that? Could be for many scripts, not just this.

if [ ! -z ${2+x} ]
	then
	howManySchemesToCreate=$2
	else
	howManySchemesToCreate=1
fi
for howMany in $( seq $howManySchemesToCreate )
do
	# Generate random file name for new random hex color scheme:
	randomCharsString=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c 5`
	outfile=./ColorSchemesHex/random/"$randomCharsString"_HexColors.txt

	printf "" > $outfile

	for element in $( seq $1 )
		do
			hex=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6`
			echo $hex >> $outfile
		done
done
