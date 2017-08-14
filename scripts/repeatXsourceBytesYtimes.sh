# DESCRIPTION
# Makes an expanded bytes copy of an input file; repeats X ($2) bytes Y ($3) times to output file __dataStretched__"$filenameNoExt".dat ($filenameNoExt being parameter A or $1--the input file), over the span of however many bytes long the input file is. Intended for data bending / glitching e.g. importing the result file as raw uLaw data in Audacity audio to "hear" it in terms of a pattern more clearly. This would also be a good basic way to hide data, because someone expert enough would have to write a program that detects and reverses the obfuscation pattern.

# USAGE
		# OPTIONAL for .bmp -> .wav data bending purposes: FIRST, create a one-line many column bitmap with this command:
		# randomColorTilesGen.sh 70 1 1 ./rainbowHexColorsByMyEye.txt
		# then in photoshop convert the resulting .ppm to a .bmp
		# then split it into a header and data file with these commands, that split the file into a 54-byte header.dat and the data remaining after that (to data.dat):
		# dd bs=54 ibs=54 count=1 if=in.bmp of=header.dat
		# dd ibs=54 skip=1 if=in.bmp of=data.dat
# Run this script with the below parameters:
#
# $1			the input file name
# $2			how many bytes (X) to copy Y (next parameter) times per loop of data expanding (or repeating).
# $3			how many times to copy bytes X per loop of data expanding.
# Example data and command;
# data.dat source shown as hexadecimal--
# FF AB 00 GG GG 00
# script execution and parameters--
# ./thisScript.sh data.dat 3 5
# --gives this result (again shown as hexadecimal) in __dataStretched__data.dat:
# FF AB 00 FF AB 00 FF AB 00 FF AB 00 FF AB 00 GG GG 00 GG GG 00 GG GG 00 GG GG 00 GG GG 00

# CODE
		# - To get file name up to first period or dot (.) :
		# fbname=$(basename "$fullfile" | cut -d. -f1)
		# re: http://stackoverflow.com/a/26753382/1397555
		# - To get the file name up to just before the last . ; preferred:
		# filename=`rev <<< "$1" | cut -d"." -f2- | rev`
		# fileext=`rev <<< "$1" | cut -d"." -f1 | rev`
		# re: http://stackoverflow.com/a/17203159/1397555

inFile=$1
filenameNoExt=`rev <<< "$inFile" | cut -d"." -f2- | rev`
outfile=__dataStretched__"$filenameNoExt".dat

if [ -e $outfile ]; then rm $outfile; fi

HexSextupletRepeats=$2

nBytes=`stat -c %s $1`
counter=0
fileext=`rev <<< "$1" | cut -d"." -f1 | rev`
for a in $( seq $nBytes )
do
	for b in $( seq $HexSextupletRepeats )
	do
		# append so many times to the target file via this inner loop (oflag=append and conv=notruck tell it to leave the original file as-is and only append to it):
		dd skip=$counter ibs=$HexSextupletRepeats count=1 if=$inFile of=$outfile oflag=append conv=notrunc
	done
	counter=$((counter + 1))
done