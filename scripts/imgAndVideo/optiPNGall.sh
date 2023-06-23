# DESCRIPTION
# Recursively optimizes all pngs in the current directory and subdirectories, via optpng, preserving full fidelity of original pixels. See NOTE for pngquant option.

# USAGE
#    optiPNGall.sh
# NOTE: see various HACK comments in script for additional options.


# CODE
# TO DO: backup time stamp of file and restore it? optipng can't do that (the --preserve switch doesn't, anyway).
pngsFileNamesArray=( $(find . -type f -name "*.png") )
arraySize=${#pngsFileNamesArray[@]}

count=0
for element in ${pngsFileNamesArray[@]}
do
	count=$((count + 1))
	echo "working on file $count of $arraySize . . ."
# COUNTING HACK: skip all files up to count N (ex. here 965) :
#	if [ $count -le 965 ]; then echo SKIPPING . . .; continue; else	echo RESTING . . .; sleep 3; fi
# PGNQUAINT HACK: uncomment the next line if you want to use it before optpng:
	# pngquant --skip-if-larger --ext=.png --force --quality 100 --speed 1 --nofs --strip --verbose $element
# OPTIMIZATION LEVEL HACK: change the number in the -o switch to anything between 0 (lowest optimization) to -o7 (highest optimization) :
	optipng -o4 $element
# LOG CONVERTED COUNT HACK; uncomment the next line to log convert counts, e.g. to interrupt and resume with the hack of an above line checking to skip the count of all already-converted files:
	# echo $count > optiPNGallProgressLog.txt
done