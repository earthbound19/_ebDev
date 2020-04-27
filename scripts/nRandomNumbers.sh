# DESCRIPTION: Generate $1 random numbers in range $2-$3 (min range and max range, inclusive)

howMany=$1

shuf -i $2-$3 -n $1

# DEVELOPMENT HISTORY
# Not sure what I wanted this script for; but I just found it was here and totally not working as intended? Fixed. 2016-06-19 06:35:35 AM -RAH
# And modded again because it didn't work in a range (fixed number of digits). Now it works with a range. 2020-04-23