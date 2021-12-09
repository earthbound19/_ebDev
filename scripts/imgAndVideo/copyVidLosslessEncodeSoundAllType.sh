# DESCRIPTION
# Repeatedly calls copyVidLosslessEncodeSound.sh with every file of type $1 in the current directory as a parameter for each call. (Converts so many video files of type $1, using that script.)

# DEPENDENCIES
#    ffmpeg, copyVidLosslessEncodeSound.sh

# USAGE
# Run with these parameters:
# - $1 file type to list and pass every one in the list to copyVidLosslessEncodeSound.sh (for example MOV)
# For example, to convert every .MOV file in the current directory via copyVidLosslessEncodeSound.sh, run:
#    copyVidLosslessEncodeSoundAllType.sh MOV


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file type of movies in the current directory to convert) passed to script. Exit."; exit 1; else inputFileType=$1; fi

inputFiles=( $(find . -maxdepth 1 -type f -iname "*.$inputFileType" -printf "%P\n") )
for inputFile in ${inputFiles[@]}
do
	copyVidLosslessEncodeSound.sh $inputFile
done
