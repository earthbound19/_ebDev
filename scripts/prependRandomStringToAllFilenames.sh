# DESCRIPTION
# Given a filename, appends one random string of length 20 characters or per paramaters you pass to the script.

# USAGE
# Pass this script one parameter $1, being the length of the random string (default 20; number of possible strings breaks past the nonillians) to prepend to every file name in the current folder.


# CODE
if [ -z ${1+x} ]; then echo No paramater one \(length of random string to prepend\)\. Defaulting to 20\.; rndStringlength=20; else rndStringlength=$1; fi

ls > meerp_gvucavE6ahYEWmEJq267.txt
while read n
do
			# No l, L, ,i, I, O, 1, 0, as those can get confused:
	randString=`cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c $rndStringlength`
	echo executing command mv $n $randString\_$n . . .
	mv $n "$randString"_"$n"
done < meerp_gvucavE6ahYEWmEJq267.txt

# Funny, we have to use a wildcard here because by the time this script ends, the temp .txt file is renamed with a prepended random string:
rm *meerp_gvucavE6ahYEWmEJq267.txt