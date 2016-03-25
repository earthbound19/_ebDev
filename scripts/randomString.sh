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
# OPTION 1: uncomment if you prefer (and comment out the others) :
# cat /dev/urandom | tr -dc 'a-z0-9A-Z' | head -c $1
# OPTION 2: uncomment if you prefer (and comment out the others) :
# howMany=$1
if [[ $1 == "" ]]; then howMany=1; else howMany=$1; fi
for (( i=1; i<=$howMany; i++ ))
do
		# 103 wide for Fira Mono standard (not medium or bold) 16-pt.
		# NOTES: 88 wide for 1280x720 pixels cygwin prompt with OCR A Std 14-point.
	# cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 88
	# cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9{}[]~!@#$%^&*()_+-=<>' | head -c 88
	cat /dev/urandom | tr -dc ' 0oO' | head -c 103
	# OPTION 3, adapted to generate secure passwords; uncomment if you prefer (and comment out the other) :
	# cat /dev/urandom | tr -dc 'a-z0-9A-Z{}[]~!@#$%^&*()_+-=<>' | head -c 42
done
