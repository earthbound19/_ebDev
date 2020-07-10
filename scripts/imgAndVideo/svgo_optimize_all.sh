# DESCRIPTION
# Invokes svgo_optimize.sh for every .svg file in the current directory. See comments in that script.

# USAGE
#  svgo_optimize_all.sh


# CODE
array=(`find . -maxdepth 1 -type f -iname \*.svg -printf '%f\n'`)
for element in ${array[@]}
do
	svgo_optimize.sh "$element"
done