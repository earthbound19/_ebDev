# DESCRIPTION
# Prints $1 randomly generated strings of length $2, with characters randomly chosen from a hackable charset. Default values used if no parameters provided.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. How many random strings you want to print.
# - $2 OPTIONAL. The length of each string.
# For example, to print 14 random strings, each 42 characters long, use:
#    randomNsetString.sh 14 42
# To use default settings, omit any or all parameters, e.g.
#    randomNsetString.sh


# CODE
if [ "$1" ]; then howMany=$1; else howMany=1; fi
if [ "$2" ]; then length=$2; else length=16; fi

# modify this array to have the characters you want, separated by spaces:
charset=(▎ ▏ ▐ ░ ▒ ▓ ▔ ▕ ▖ ▗ ▘ ▙ ▚ ▛ ▜ ▝ ▞ ▟ )
charsetLength=${#charset[@]}
# echo charsetLength is $charsetLength
for ((i=1; i <= $howMany; i++))
do
	rndString=
	for ((j=1; j <= $length; j++))
	do
		rand=$((RANDOM%$charsetLength))
		rndString="$rndString""${charset[$rand]}"
	done
	printf $rndString
	if [[ $howMany -gt 1 ]]; then printf "\n"; fi
done







