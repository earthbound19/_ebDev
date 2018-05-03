# DESCRIPTION: Generate x random numbers (by passing a paramater, x (number) to this script, of length y (second parameter to this script).

howMany=$1
whatLength=$2

for (( i=1; i<=$howMany; i++ ))
do
	str1=`cat /dev/urandom | tr -dc '0-9' | head -c $whatLength`
	echo $str1
done

# DEVELOPMENT HISTORY
# Not sure what I wanted this script for; but I just found it was here and totally not working as intended? Fixed. 06/19/2016 06:35:35 AM -RAH