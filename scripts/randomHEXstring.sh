# DESCRIPTION: returns one random hex string of length 6 characters or per paramaters you pass to the script.

# USAGE: pass this script two paramaters:
# $1 How many hex strings you want it to generate
# $2 The length of each hex string

if [[ $1 == "" ]]; then howMany=1; else howMany=$1; fi
if [[ $2 == "" ]]; then length=6; else length=$2; fi
for (( i=1; i<=$howMany; i++ ))
do
	export LC_CTYPE=C
	cat /dev/urandom | tr -dc 'a-f0-9' | head -c $length
		echo
done

