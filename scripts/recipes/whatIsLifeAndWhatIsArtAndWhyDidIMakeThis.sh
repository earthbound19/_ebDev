# DESCRIPTION
# Makes a video that should not exist, of random pitches paired with random color screens, for random durations, concatenated.

# USAGE
# invoke with these optional parameters, which have defaults if not provided:
# - $1 minimum duration of each color/pitch component of video (in seconds, float, e.g. 0.68)
# - $2 maximum duration of "
# - $3 how many such videos to make before assembling them into a larger one
# whatIsLifeAndWhatIsArtAndWhyDidIMakeThis.sh 42
# Result file is named after a time stamp and the convoluted initials of the title of this script, e.g.


# CODE
if ! [ "$1" ]; then minimumDuration=0.14; else minimumDuration=$1; fi
if ! [ "$2" ]; then maximumDuration=1.21; else maximumDuration=$2; fi
if ! [ "$3" ]; then howMany=42; else howMany=$3; fi

floatsArray=`/c/_ebSuperBin/randomFloatsInRange.exe $minimumDuration $maximumDuration $howMany`

if [ -d tmp_42_WILAWIAAWDTVE ]; then rm -rf tmp_42_WILAWIAAWDTVE; fi
mkdir tmp_42_WILAWIAAWDTVE
cd tmp_42_WILAWIAAWDTVE

for float in ${floatsArray[@]}
do
	RNDcolorAndPitchVid.sh $float
done

concatVidFiles.sh mp4
timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
mv _mp4sConcatenated.mp4 ../"$timestamp"_WILAWIAAWDTVE.mp4
cd ..
rm -rf tmp_42_WILAWIAAWDTVE

echo "DONE. Result file from whatIsLifeAndWhatIsArtAndWhyDidIMakeThis.sh is $timestamp"_WILAWIAAWDTVE.mp4"