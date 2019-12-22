# DESCRIPTION
# Invokes irfanView2imgNN.sh for all files of type $1 in the current directory. See USAGE.

# USAGE
# $1 input format
# $2 output format
# $3 px wide to resize to by nearest neighbor method, maintaining aspect
# For example:
# ./thisScript.sh ppm png 540


# CODE
# Store a list of all files of type $1 in an array, trimming off any leading ./ from the listed files:
allParam1files=(`gfind . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n'`)

# Step through that array, converting each element from type $2 to $3 via irfanView2imgNN.sh:
echo "Rendering images from type $2 to type $3 . . ."
for element in ${allParam1files[@]}
do
			# echo Invoking command\:
			# echo "irfanView2imgNN.sh $element $2 $3"
	irfanView2imgNN.sh $element $2 $3
done
