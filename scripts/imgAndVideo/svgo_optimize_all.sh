# DESCRIPTION
# Invokes svgo_optimize.sh repeatedly. See comments in that script.

array=(`gfind . -maxdepth 1 -type f -iname \*.svg -printf '%f\n'`)
for element in ${array[@]}
do
	svgo_optimize.sh "$element"
done