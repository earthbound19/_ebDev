# DESCRIPTION
# Returns one password of length 44 characters or per paramaters you pass to the script.

# USAGE
# pass this script two paramaters:
# $1 how many strings you want it to return
# $2 the length of each string. Example:
# thisScript.sh 5 44
# -- will return 5 passwords of length 44 characters each.

# SEE ALSO: http://passwordmaker.sourceforge.net/downloads/cli.html


# CODE
if [ -z "$1" ]; then howMany=1; else howMany=$1; fi
if [ -z "$2" ]; then length=44; else length=$2; fi

# To force tr to operate on non-text (urandom) output:
export LC_CTYPE=C
for (( i=1; i<=$howMany; i++ ))
do
	cat /dev/urandom | tr -dc 'a-z0-9A-Z{}[]~!@#$%^&*()_+-' | head -c $length
# Possibly more efficient option that sacrifices many unusual characters from entropy pool; re https://unix.stackexchange.com/a/476125/110338 :
	# base64 < /dev/urandom | head -c $length
		# For newline between printed strings:
		echo
done


# DEVELOPMENT LOG:
# 2016-05-05 4:18 PM RAH horked from randomString.sh; see comments therein for reference.
# 01/03/2017 10:15:50 PM RAH removed the characters =<> from the tr -dc '...' parameter, as they produced commas which hurt passwords in some settings (and may not have ever produced any of the characters =<>).
