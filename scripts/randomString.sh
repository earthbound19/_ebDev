# DESCRIPTION
# Prints $1 randomly generated alphanumeric strings (excluding characters that can be confused for other characters) of length $2. Default values used if no parameters provided.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. How many random strings you want to print.
# - $2 OPTIONAL. The length of each string.
# For example, to print 14 random strings, each 42 characters long, use:
#    randomString.sh 14 42
# To use default settings, omit any or all parameters, e.g.
#    randomString.sh


# CODE
# See DEVELOPER NOTES comments at end of script.
if [ "$1" ]; then howMany=$1; else howMany=1; fi
if [ "$2" ]; then length=$2; else length=9; fi

for (( i=1; i<=$howMany; i++ ))
do
	# cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c $length
	# cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9{}[]~!@#$%^&*()_+-=<>' | head -c $length
	# re a stackoverflow answer abt illegal byte sequence in tr:
	export LC_CTYPE=C
	cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c $length
		# For newline between printed strings:
		echo
	# OPTION 3, adapted to generate secure passwords; uncomment if you prefer (and comment out the other) ; NOTE that complexPassword.sh now des this:
	# cat /dev/urandom | tr -dc 'a-z0-9A-Z{}[]~!@#$%^&*()_+-=<>' | head -c $length
done


# DEVELOPMENT LOG:
# Prior to now: A lot of stuff.
# 04/16/2016 02:29:36 PM Fixed a goof with it sometimes printing square brackets. I mistakenly thought the tr utility needed bracket grouping.

# DEVELOPER NOTES
# 103 wide for Fira Mono standard (not medium or bold) 16-pt.
# NOTES: 88 wide for 1280x720 pixels Cygwin prompt with OCR A Std 14-point.
# Generate random alphanumeric string of specified length, as in parameter fold -w (n). Optional single numeric parameter will generate n (or that number of) random strings.
# Source: https://gist.github.com/earthgecko/3089509
# Note also comment: https://gist.github.com/earthgecko/3089509#gistcomment-1541056
			# Bash generate random 32 character alphanumeric string (upper and lowercase) and
			# NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
			# echo NEW_UUID $NEW_UUID
			#
			# Bash generate random 32 character alphanumeric string (lowercase only)
			# cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
			#
			# WILL WORK on all POSIX systems, but slower--alternate one:
			# tr -dc '[:alnum:]' < /dev/urandom  | dd bs=4 count=8 2>/dev/null
# PREFERRED method for performance; alternate two--change the number in -c (n) to change length of string:
# NOTE: The fastest possible random output I've found is: cat /dev/urandom | tr -dc 'your chosen characters here'