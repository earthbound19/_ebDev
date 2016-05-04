# DESCRIPTION: calls poem.py from python-Backus-Naur-poetry-generator n times, to create n (bad) poems in a /poems subfolder. Poems are initially given random file names, then renamed according to the poem title.
# USAGE: call this script with one paramater, being a decimal number of times to generate poems.

mkdir generated_poems

# If a generated_poems directory exists, do nothing (other than assign a useless variable required for block flow control; if it doesn't exist, create it.
if [ -a generated_poems ]; then	bler=blor; else	mkdir generated_poems; fi

howManyPoems=$1
# NOTE: because I didn't want to bother figuring out how to get a variable expansion to work with sed, this is hard-coded to expect 5 random characters per generated poem file name.
derp=5

# Change the value of howManyCharsRedundantVariable, above, numeral in the next line of code to change how many random characters appear in each file name:
howManyRandomChars=$(($howManyPoems * 5))
		# params:		how many		length:
randomString=`randomString.sh 1 $howManyRandomChars`
		# echo randomString value is $randomString
echo $randomString > tempRandomChars.txt

for i in $(seq 1 1 $howManyPoems)
do
	randChars=`head -c 5 ./tempRandomChars.txt`
			# echo extracted random characters $randChars from ./tempRandomChars.txt
	sed -i 's/^.....//' ./tempRandomChars.txt
	# Unfortunately this slows it down . . 
	CMD /C "poem.py" > ./generated_poems/$randChars
	sed -n '/.*<h1>\(.*\)<\/h1>.*/p' ./generated_poems/$randChars > temp.txt
	sed -i 's/.*<h1>\(.*\)<\/h1>.*/\1/g' temp.txt
	peomTitleUnMunged=`sed 's/ /_/g' temp.txt`
	doubleUnderscore=__
	destFilename=./generated_poems/$peomTitleUnMunged$doubleUnderscore$randChars.html
	mv ./generated_poems/$randChars $destFilename
done

rm ./tempRandomChars.txt