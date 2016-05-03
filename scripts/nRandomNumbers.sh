# DESCRIPTION: Generate n random numbers (by passing a paramater, n (number) to this script.

howMany=$1
# printf "making $howMany password(s) . . ."

for (( i=1; i<=$howMany; i++ ))
do
	str1=`cat /dev/urandom | tr -dc '0-9' | head -c $lower`
	echo $password
done