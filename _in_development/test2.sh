# the -e flag checks if a file exists:
if [ -e blor.txt ]
then
	echo blor.txt was found.
	else
	echo blor.txt was not found.
fi

# putting a ! flag before it reverses the sense (checks for 'does not exist') :
if [ ! -e blor.txt ]
then
	echo blor.txt was not found.
	else
	echo blor.txt was found.
fi