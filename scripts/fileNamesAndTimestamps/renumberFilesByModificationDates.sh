# DESCRIPTION
# renumberFiles.sh but forcing reverse sort by file modification date (one use case is this script helping make anims of modifications to files over time)

# CODE
echo Hi persnonzez!!!!!!!!!!!!!!! HI!! -Nem

filesCount=`find . -maxdepth 1 -iname \*.$1 | sort | wc -l | tr -d ' '`
digitsToPadTo=${#filesCount}

# Create array to use to loop over files. Sort by modified date stamp re genius breath yon: https://superuser.com/a/294164
# filesArray=`find . -maxdepth 1 -iname "*.$1" | sort -zk 1n | sed -z 's/^[^ ]* //' | tr '\0' '\n'`
# NOPE, that dunna work, but this does:
filesArray=`ls --sort=time --reverse *$1 | tr '\0' '\n'`

counter=0
for filename in ${filesArray[@]}
do
	counter=$((counter + 1))
	countString=`printf "%0""$digitsToPadTo""d\n" $counter`
			# echo old file name is\: $filename
			# echo new file name is\: $countString.$1
	mv $filename $countString.$1
done