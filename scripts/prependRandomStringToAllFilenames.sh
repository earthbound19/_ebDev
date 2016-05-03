# DESCRIPTION: Given a filename, appends one random string of length 20 characters or per paramaters you pass to the script.
# USAGE: Pass this script two paramaters, the first being the file name which you want to rename by appending a random string to it, the second being the length of the random string (default 20; number of possible strings breaks past the nonillians).

ls > meerp.txt
mapfile -t fileNamesArray < ./meerp.txt

for n in ${fileNamesArray[@]}
do
	if [[ $1 == "" ]]; then fileName=; else fileName=$1; fi
	if [[ $2 == "" ]]; then length=20; else length=$2; fi
			# No l, L, ,i, I, O, 1, 0, as those can get confused:
	randString=`cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c $length`
	echo executing command mv $n $randString\_$n . . .
	mv $n $randString\_$n
	# That's an escaped underscore thar--the variables won't print if it isn't escaped.
done