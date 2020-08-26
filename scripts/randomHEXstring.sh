# DESCRIPTION
# Prints $1 randomly generated hex strings of length $2 (default values used if no parameters provided).

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. How many hex strings you want to print.
# - $2 OPTIONAL. The length of each hex string.
# For example, to print 14 hex strings, each 42 characters long, use:
#    randomHexString.sh 14 42
# To use default settings, omit any or all parameters, e.g.
#    randomHexString.sh 8
# Or:
#    randomHexString.sh


# CODE
if [[ $1 == "" ]]; then howMany=1; else howMany=$1; fi
if [[ $2 == "" ]]; then length=6; else length=$2; fi
for (( i=1; i<=$howMany; i++ ))
do
	export LC_CTYPE=C
	cat /dev/urandom | tr -dc 'a-f0-9' | head -c $length
		echo
done

