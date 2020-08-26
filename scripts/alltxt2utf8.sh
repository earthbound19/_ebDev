# DESCRIPTION
# Converts every .txt file in the current directory and all subdirectories to Unix line endings and utf8 encoding, IF they are not encoded in us-ascii. Overwrites the original files. Needed if some tool or summat creates files in a codepage unusable by tools expecting Unix line endings/utf8.

# USAGE
# Run without any parameter:
#    alltxt2utf8.sh


# CODE
echo ""
echo "WARNING: WARNING. Things. You might not want to run this script. If you do, type VUBKUK and then press ENTER or RETURN. Also, spaces and other terminal-unfriendly characters in text file names may mess up script execution."
read -p "TYPE HERE: " SILLYWORD

if ! [ "$SILLYWORD" == "VUBKUK" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi

filesArray=(`find . -type f -name "*.txt"`)

for filename in "${filesArray[@]}"
do
	temp=`file -bi $filename`
	type=`echo $temp | sed 's/.*=\(.*\)/\1/g'`
	if [ "$type" != "us-ascii" ]
	then
		printf "\nConverting $filename . . ."
		dos2unix -l -n $filename out.txt
		rm $filename
		iconv -t utf8 out.txt >> $filename
		rm out.txt
	else
		printf "\nNOT converting $filename . . ."
	fi
done