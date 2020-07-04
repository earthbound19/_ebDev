# DESCRIPTION
# Creates a random grid of images from a ./selected directory (which you must create and populate); alterable by parameter. Except it doesn't. Read comments in this script.

# USAGE
# Before running this script, you will need to make and copy files into a ./selected directory, which must be a subdirectory of the current directory from which you run this script. Pass this script two parameters:
# - $1 the width of the grid to create (default 19
# - $2 the height (default 9). It will produce a random $1x$2 collage of images from the ./selected directory. Except it won't. At this writing.
# Example command:
#  ./ copyNrandomFilesToTemp.sh 8 4

# DEPENDENCIES
# allRandomFileNames.sh, autoMontageIM.sh

# TO DO
# - Finish this script, making use of autoMontageIM.sh
# - Rename this script to reflect that it creates RND montages.

# CODE
xTiles=$1
echo xTiles is $xTiles
yTiles=$2
echo yTiles is $yTiles
totalTiles=$((xTiles * yTiles))

gfind ./_selected/* > alles.txt
mapfile -t alles < alles.txt
allesSize=${#alles[@]}

if [ ! -d temp ]; then mkdir temp; fi

for i in $( seq $totalTiles )
do
	chooseIndex=`shuf -i 1-$allesSize -n 1`
	echo copying file ${alles[$chooseIndex]} to ./temp . . .
	cp "${alles[$chooseIndex]}" ./temp
done

echo Done copying file selection to ./temp and randomly renaming files therein . . .
cd ./temp
allRandomFileNames.sh
cd ..

echo Done.
