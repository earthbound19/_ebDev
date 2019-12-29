# DESCRIPTION
# Creates a random grid of images from a ./selected directory (which you must create and populate); alterable by parameter. Except it doesn't. Read comments in this script.

# USAGE
# Before running this script, you will need to make and copy files into a ./selected directory, which must be a subdirectory of the current directory from which you run this script. Pass this script two parameters, $1 being the width of the grid to create (default 19), $2 being the height (default 9). It will produce a random $1x$2 collage of images from the ./selected directory. Except it won't. At this writing.

# NOTES
# If you have file names with spaces or other terminal-unfriendly characters in the ./_selected directory, it will throw errors and fail to copy them. Use metamorphose and the Metamorphose1BadFileNameCharacterRemoval_step01.cfg - ~03.cfg configuration files for it first if necesarry.

# DEPENDENCIES
# allRandomFileNames.sh, and you will want to use imagemagick_grid_montage_GUI.ahk.

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
