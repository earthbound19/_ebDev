# DESCRIPTION
# Makes a video that should not exist, of random pitches paired with random color screens, for random durations, concatenated.

# DEPENDENCIES
# getFullPathToFile.sh, randomFloatsInRange.exe, randomString.sh, RNDcolorAndPitchVid.sh, concatVideos.sh, and whatever utilities the scripts called by this script uses (e.g. ffmepg).

# USAGE
# Run with these optional parameters, which have defaults if not provided:
# - $1 minimum duration of each color/pitch component of video (in seconds, float, e.g. 0.68)
# - $2 maximum duration of "
# - $3 how many such videos to make before assembling them into a larger one
# Example that will produce 42 videos, of minimum duration 0.68 seconds and maximum duration 1.24 seconds, and then concatenate them into one longer video:
#    whatIsLifeAndWhatIsArtAndWhyDidIMakeThis.sh 42 0.68 1.24
# The result file is named after a time stamp and the convoluted initials of the title of this script, for example: 2020_07_20__17_51_28__899904000__WILAWIAAWDTVE.mp4


# CODE
if ! [ "$1" ]; then howMany=42; else howMany=$1; fi
if ! [ "$2" ]; then minimumDuration=0.14; else minimumDuration=$2; fi
if ! [ "$3" ]; then maximumDuration=1.21; else maximumDuration=$3; fi

pathToEXE=$(getFullPathToFile.sh randomFloatsInRange.exe)
floatsArray=($($pathToEXE $minimumDuration $maximumDuration $howMany))

rndString=$(randomString.sh 1 14)
tmpVidDir="tmp_""$rndString""_WILAWIAAWDTVE"
mkdir $tmpVidDir
cd $tmpVidDir

for float in ${floatsArray[@]}
do
	RNDcolorAndPitchVid.sh $float
done

source concatVideos.sh mp4
timestamp=$(date +"%Y_%m_%d__%H_%M_%S__%N")
renameTarget="$timestamp"__WILAWIAAWDTVE.mp4
mv $concatenatedVideoFileName ../$renameTarget
cd ..
rm -rf $tmpVidDir

echo "DONE. Result file is $renameTarget."