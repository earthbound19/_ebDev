# DESCRIPTION
# My Processing script randomNsetChars.pde writes the seed for each
# animation frames collection in the same folder as the frames, in
# a text file which is also named after the random seed. This script
# collects those from the subfolders/text files and lists them in
# a file outside (above) the subfolders, named "seeds.txt". There are
# reasons I want this script (and not randomNsetChars.pde) to do that.
# WARNING: this wipes out the contents of seeds.txt (before repopulating
# it) if it already exists.


# CODE
array=(`gfind . -iname '*.txt' -print0 -printf "%T@ %Tc %p\n" | gsort -n | gsed 's/.*[AM|PM] \.\/\(.*\)/\1/g'`)

printf "" > seeds.txt
for element in ${array[@]}
do
	echo "logging seed from $element . . ."
	echo $element | gsed 's/.*\/\(.*\).txt/\1/g' >> seeds.txt
done