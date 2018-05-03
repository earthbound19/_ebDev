# For windows file systems where copies lead to inconsistent or incorrect date stamps; scans the creation date, modification date, access date, and metadata Create Data and Metadata Date/time stamps (the latter two for image etc. files), then sets the file modification date and time to the earliest of these.

exiftool $1 > temp.txt

printf "" > temp2.txt

sed -n 's/\(.*File Modification Date\/Time *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' temp.txt >> temp2.txt
sed -n 's/\(.*File Access Date\/Time *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' temp.txt >> temp2.txt
sed -n 's/\(.*File Creation Date\/Time *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' temp.txt >> temp2.txt
sed -n 's/\(.*Create Date *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' temp.txt >> temp2.txt
sed -n 's/\(.*Metadata Date *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' temp.txt >> temp2.txt

sort temp2.txt > temp.txt

adjustmentDateStamp=`head -n 1 temp.txt`

		# echo adjustmentDateStamp val is\:
		# echo $adjustmentDateStamp

exiftool -overwrite_original -CreateDate="$adjustmentDateStamp" $1