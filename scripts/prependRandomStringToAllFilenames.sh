# DESCRIPTION
# Prepends a random alphanumeric string (but with similar characters excluded) of length $1 to all files in the current directory. As this is a destructive or potentially havoc-inducing action, the script prompts to be sure you want to do this and does not unless you type a given password.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. How many random characters should be prepended to every file name. If not provided, defaults to a hard-coded value.
# Example that will use the default number of random characters:
#    prependRandomStringToAllFilenames.sh
# Example that will prepend random strings 6 characters long to all files in the current directory:
#    prependRandomStringToAllFilenames.sh 6


# CODE
if [ -z "$1" ]; then echo No parameter one \(length of random string to prepend\)\. Defaulting to 20\.; rndStringlength=20; else rndStringlength=$1; fi

echo ""
echo "WARNING: this script will prefix random strings of length $rndStringlength to ALL files in the current directory. If this is _not_ what you want to do, press CTRL (or CMD)+C, or CTRL+Z, or anything besides PEDGNIMK, and press ENTER or RETURN. If this _is_ what you want to do, type PEDGNIMK and then ENTER or RETURN."
read -p "TYPE HERE: " SILLYWORD

if ! [ "$SILLYWORD" == "PEDGNIMK" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi

allFiles=$(find . -maxdepth 1 -type f -printf "%P\n")
for fileName in ${allFiles[@]}
do
			# No l, L, ,i, I, O, 1, 0, as those can get confused:
	randString=`cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c $rndStringlength`
	echo renaming file $fileName . . .
	mv $fileName "$randString"_"$fileName"
done
