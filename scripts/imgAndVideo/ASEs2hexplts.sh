# DESCRIPTION
# Converts all .ase (Adobe Swatch Exchange format) files in the current directory to .hexplt format (just a list of the sRGB hex values), named after the source file. Tested with .ase files from perception.io; whether ASE files from elsewhere will work is uknown (untested)

# DEPENDENCIES
# - python installed and in your PATH, with the 'swatch' library https://pypi.org/project/swatch/ (install with pip install swatch)
# A bash environment to run this script

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Anything, such as the word FLUANDAR, which will cause the script to look for and convert ASE format files in all subdirectories also.
# For example, to convert only ASE files in the current directory, run:
#    ASEs2hexplts.sh
# To convert all ASE format files in the current directory and all subdirectories, run:
#    ASEs2hexplts.sh FLUANDAR


# CODE
# if no parameter $1 is sent, set to search only current directory (maxdepth 1); otherwise don't define it (which means it will search all subfolders) :
if [ ! "$1" ]; then maxdepthParameter='-maxdepth 1'; fi

aseFiles=($(find . $maxdepthParameter -iname \*.ase -printf "%P\n"))

for file in ${aseFiles[@]}
do
	targetFileName=${file%.*}.hexplt
	echo ""
	echo "Checking for targetFileName $targetFileName . . ."
	if [[ ! -f "$targetFileName" ]]
	then
		echo "WILL CONVERT $file to $targetFileName . . ."
	# This might somehow be evil and dirty to mix languages this way, but THIS WORKS: invoke python and pass code to it! :
python -c """
import swatch
import os
currpath=str(os.getcwd())
		# the following convoluted mess combines the python escape sequence for a backslash \ with bash escape sequences for double-quote marks and backslashes; the python escape sequence is "\\" and the bash additions make it \"\\\\\" :
fullPathToFile = currpath + \"\\\\\" + '$file'
paletteDict = swatch.parse(fullPathToFile)
for i in paletteDict[0]['swatches']:
	print('#' + i['name'])
		# Note the delete of windows newlines via tr here; forces unix line endings (preferred) :
""" | tr -d '\15\32' > $targetFileName
	echo Done.
	else
		echo "Target file name $targetFileName already exists; SKIPPING conversion."
	fi
done
