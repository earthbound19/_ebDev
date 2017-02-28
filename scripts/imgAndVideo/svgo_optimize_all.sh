# DESCRIPTION
# Invokes svgo_optimize.sh repeatedly. Optimizes all .svg files in a given directory according to configuration of svgo_optimize.sh and 

# USAGE
# Ensure this script is in your $PATH, and invoke it from a directory with svg files you wish to produce optimized copies of.

# DEPENDENCIES
# As listed in svgo_optimize.sh

find *.svg > allSVGs.txt
mapfile -t allSVGs < allSVGs.txt
rm allSVGs.txt
for element in "${allSVGs[@]}"
do
	svgo_optimize.sh "$element"
done