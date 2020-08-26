# DESCRIPTION
# PERMANENT DESTRUCTION-INDUCING SCRIPT. WIPES THE CONTENTS of all files in the current directory and all subdirectories, making them null or zero byte files. Prompts to enter two passwords before it will proceed.

# USAGE
# From a path in which you wish to blank all files to 0 bytes, run this script:
#    blankAllFiles.sh


# CODE
echo ""
echo "WARNING: THIS SCRIPT PERMANENTLY BLANKS all files in the current directory, and all subdirectories (changes them to 0 bytes long). If this is what you want to do, type FAULHOOF and then press <enter> (or <return>)."
read -p "TYPE HERE: " SILLYWORD

if ! [ "$SILLYWORD" == "FAULHOOF" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi

echo ""
echo "WARNING AGAIN: THIS SCRIPT PERMANENTLY BLANKS all files in the current directory, and all subdirectories (changes them to 0 bytes long). If this is what you want to do, and you're absolutely certain about it, type WHEEBWHELM and then press <enter> (or <return>)."
read -p "TYPE HERE: " SILLYWORD

if ! [ "$SILLYWORD" == "WHEEBWHELM" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi


thisDir=`pwd`
find "$thisDir/" -type f > ../allFiles.txt
while read p
do
	rm "$p"
	dd count=0 if=/dev/zero of="$p"
done < ../allFiles.txt
rm ../allFiles.txt


# REVISION HISTORY
# Wrote this script, which it turns out has a bug [unknown when].
# Updated with a much simpler command to empty files (it didn't always work before now; now it does). 02/21/2016 08:20:22 PM PM -RAH
# Bugfix: would't work with paths that have space characters. Also, temp list file is in parent dir to avoid clobbering it. ALSO, the dangerous block was not commented out by default. 05/17/2016 04:03:29 AM -RAH