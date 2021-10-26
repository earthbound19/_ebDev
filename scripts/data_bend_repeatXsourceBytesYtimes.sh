# DESCRIPTION
# Makes an expanded bytes copy of an input file (parameter 1), with each byte repeated N (parameter 2) times to an output file named like `sourceBaseName__dataStretched__.dat`. Intended for data bending / glitching e.g. importing the result file as raw uLaw data in Audacity audio to "hear" it in terms of a pattern more clearly. Could work for stagonography also, but only if the reversed process knows that the last copied bytes are copies of fewer bytes if the number of source bytes weren't a multiple of the second parameter.

# USAGE
# Run this script with the below parameters:
# - $1 The input file name
# - $2 How many times to repeat each byte from the input file to the output file.
# For example, suppose you have a source file named `data.dat`, with these hexadecimal values for data (two hex characters per byte) :
#    AB CD EF 00 11 22
# If you run:
#    data_bend_repeatXsourceBytesYtimes.sh data.dat 3
# It gives this result (again shown as hexadecimal) in `__dataStretched__sourceBaseName.dat`:
#    AB CD EF AB CD EF AB CD EF 00 11 22 00 11 22 00 11 22
# The pattern is that every group of bytes size $2 is repeated $2 times.
# NOTES
# - Even for relatively small amounts of data, this can be SLOOOOOOW.
# - A way to get some data for this for .bmp -> .wav data bending purposes, is to create a one-line many-column bitmap with this command:
#        colorsGridFromRNDorList.sh 70 1 1 rainbowHexColorsByMyEye.hexplt
# - Then in Photoshop convert the resulting .ppm to a .bmp
# - Then split it into a header and data file with these commands, that split the file into a 54-byte header.dat and the data remaining after that to `data.dat`:
#        dd bs=54 ibs=54 count=1 if=in.bmp of=header.dat
#        dd ibs=54 skip=1 if=in.bmp of=data.dat


# CODE
# TO DO: adapt this (if possible?) to repeat arbitrary multiple indexes of bytes arbitrary times (where now it repeats every 2 bytes 2 times, or 3 bytes 3 times, etc.)
if [ ! "$1" ]; then printf "\nNo parameter \$1 (input file) passed to script. Exit."; exit 1; else inFileName=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$1 (how many times to repeat every byte) passed to script. Exit."; exit 1; else hexRepeats=$2; fi

# If hexRepeats isn't a useful value, print an error message and exit with error code.
if [ "$hexRepeats" -lt "2" ]; then echo "Error: there is no point in running this script with hexRepeats 1 or less. 1 will result in just a copy, less than 1 will throw an error. Parameter should be 2 or more. Exit."; fi

fileNameNoExt=${inFileName%.*}
outFileName="$fileNameNoExt""__dataStretched__".dat

if [ -e $outFileName ]; then rm $outFileName; fi

nBytes=`stat -c %s $inFileName`
counter=0
for a in $(seq $nBytes)
do
	for b in $(seq $hexRepeats)
	do
		# append so many times to the target file via this inner loop (oflag=append and conv=notruck tell it to leave the original file as-is and only append to it):
		dd skip=$counter ibs=$hexRepeats count=1 if=$inFileName of=$outFileName oflag=append conv=notrunc
	done
	counter=$((counter + 1))
done

echo DONE. Results are in $outFileName.