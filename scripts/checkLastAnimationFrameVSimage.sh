# DESCRIPTION
# Intended to help check the last frame of an animation render (in a folder of numbered e.g. images), to see if it matches a file outside it. Which only happens as a result of color_growth render scripts I have. Or maybe in other settings. How it does this: finds all folders with the same base file name as all files of type $1 in the current directory, and opens both the check file of type $1 and the last listed file for each matched-name folder. (At this writing, via the `start` command, which dunnae work on all platforms.)

# USAGE
# Run with one parameter ($1), which is the file name of a file expected to be identical to the last file found in a folder with the same base name as that file $1. For example:
#    checkLastAnimationFrameVSimage.sh 750_from_uGSQNAA6__2020_07_16__05_51_52__6077c6.png


# CODE
# TO DO
# Detect OS and use appropriate launch command (`start` vs. I think `open`)

if ! [ "$1" ]
then
	printf "\nNo parameter \$1 (source file type to find file names expected to be identical to the last file found in a folder with the same base name GLARBL GLARBL GLOB *GOLLUM*) passed to script. Exit."; exit 1;
else
	sourceTypes=($(find . -maxdepth 1 -name "*.$1" -printf '%f\n'))
	numberOfSourceTypes=${#sourceTypes[@]}
fi

count=0
for element in ${sourceTypes[@]}
do
	count=$((count + 1))
	printf "\nRunning comparison no. $count of $numberOfSourceTypes for $element . . . \n"
	fileNameNoExt=${element%.*}
	fileExt=${element##*.}
	checkFile=$(ls $fileNameNoExt/*.$fileExt | tail -n 1)
	printf "\nOpening check source file $element and check target file $checkFile. If they don't match, CRY FOR SORROW. If they do, CRY FOR JOY, and press any key to continue.\n"
	start $element
	start $checkFile
	read -rsn1
done
