# DESCRIPTION
# Runs extractXMPandEmbeddedRAWfromDNGandDestroyDNG.sh for every DNG format file in the current directory.

# USAGE
# Run without any parameters:
#    extractXMPsandEmbeddedRAWsfromDNGsandDestroyDNGs.sh


# CODE
allDNGfileNames=($(find . -type f -iname "*.dng" -printf "%P\n"))
for DNGfileName in ${allDNGfileNames[@]}
do
	extractXMPandEmbeddedRAWfromDNGandDestroyDNG.sh $DNGfileName
done

echo "DONE running extractXMPandEmbeddedRAWfromDNGandDestroyDNG.sh (phew!) for every DNG format file name in the current directory."