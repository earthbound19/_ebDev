# DESCRIPTION
# Creates entropy from any file by concatenating all of the hex of many hash algorithms (hashes of the file) to a binary file, via rehash.exe (compiled or downloaded via resources at http://rehash.sourceforge.net/). Throws an error and exits if source file not found. Throws a warning and exits if source file is zero bytes. See also PRNDfromEntropicData.sh.

# DEPENDENCIES
# bash, rehash, xxd

# USAGE
# Run with these parameters:
# - $1 input file name
# For example:
#    entropyFromFile.sh inputFileName.bak
# Result file name is <input file name>_hashEntropy.bin
# NOTES
# - This will not clobber (overwrite) output file if it already exists.
# - Source file names may not work if they have terminal-unfriendly characters in their file name. See ftun.sh to rename all files in directory to have only terminal-friendly characters.


# CODE
# TO DO
# - add more hash types via other tools? See TO DO iteams in PRNDfromEntropicData.sh.
if [ ! "$1" ]; then printf "\nNo parameter \$1 (input file name to generate entropy from) passed to script. Exit."; exit 1; else entropySourceFileName=$1; fi

if [ ! -f $entropySourceFileName ]
then
	printf "ERROR: source file $entropySourceFileName not found.\n"
	exit 1
else
	blar=blor
	entropySourceFileSize=$(stat -c %s $entropySourceFileName)
	if [ "$entropySourceFileSize" == "0" ]
	then
		printf "WARNING: source file $entropySourceFileName has a size of 0 bytes (is empty). Exit.\n"
		exit 2
	fi
fi

renderTargetFileName=${entropySourceFileName%.*}_hashEntropy.bin

# TEH PIPES TEH PIPES THREE TEH PIPES
# print all but first line, strip hash algo info from start (up to ' : '), then delete whitespace and newlines, then convert hex characters to binary data and pipe to $renderTargetFileName via xxd:
rehash $entropySourceFileName | tail -n +2 | sed 's/.* : //g' | tr -d '[[:space:]]\n' | xxd -r -ps > $renderTargetFileName

printf "DONE rendering hash-derived binary entropy from source file $entropySourceFileName to target file $renderTargetFileName.\n"
