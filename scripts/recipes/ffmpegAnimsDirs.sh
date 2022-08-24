# DESCRIPTION
# Runs ffmpegAnim.sh against every subfolder in the current folder, with default hard-coded values if you provide no parameters, or passing on to ffmpegAnim.sh whatever parameters you provide for this script. Renames the resulting animation videos after the respective subfolders. See USAGE and NOTES.

# USAGE
# From a directory with so many subdirectories, each with image series suitable for ffmpegAnim.sh (SEE), run this script. Run it without any parameters to use provided defaults, or pass to this script the same parameters that ffmpegAnim.sh will accept, and this script will pass those to ffmpegAnim.sh for every call of that script, for every subfolder. To use without any parameters, run like this:
#    ffmpegAnimsDirs.sh
# NOTES
# - For every render made from files in subfolders, this script renames the resultant _out.mp4 animation after the folder that contains the animation frames, and moves it one directory up from the folder.
# - Also, before it calls ffmpegAnim.sh for a subfolder, it checks if the animation video that would result from rendering already exists, and skips the render if it does (to avoid duplicating work, and also so that you may interrupt and resume renders from this script).
# - This script does not scan subfolders recursively; it will only operate on folders one folder level down from the current folder, and will not work on subfolders of those. 


# CODE
if ! [ "$1" ]; then srcRate=30; else srcRate=$1; fi
if ! [ "$2" ]; then destRate=30; else destRate=$2; fi
if ! [ "$3" ]; then quality=12; else quality=$3; fi
if ! [ "$4" ]; then imgFormat='png'; else imgFormat=$4; fi
if ! [ "$5" ]; then rescaleParam='NULL'; else rescaleParam=$5; fi
# If I define finalStillSeconds even without a value, then ffmpegAnim.sh does things with it. So, don't even define it if no $6 parameter is passed (only define it if there is a parameter $6) :
if [ "$6" ]; then finalStillSeconds=$6; fi

# sorts by newest first:
directories=( $(find . -maxdepth 1 -type d -printf '%f\n' | sort -n | sed 's/.*[AM|PM] \.\/\(.*\)/\1/g') )
# the :1 in the following slices the array to omit
# the first element, ., which we don't want;
# re: https://stackoverflow.com/a/2701872/1397555
directories=("${directories[@]:1}")

parentDir=$(pwd)
for element in ${directories[@]}
do
	cd $element
	# trim any trailing "_frames" string off that we don't want:
	fileNameNoExt=${element%"_frames"}
	renderTargetFileName="$fileNameNoExt"".mp4"
	if ! [ -e ../"$fileNameNoExt".mp4 ]
	then
		printf "\nRendering to _out.mp4; will rename to ../""$renderTargetFileName"" . . .\n\n"
		ffmpegAnim.sh $srcRate $destRate $quality $imgFormat $rescaleParam $finalStillSeconds
		mv _out.mp4 ../"$renderTargetFileName"
echo "sleeping for 40 seconds to let computer cool off . . ."
sleep 40
	else
		printf "\nTarget animation ../""$renderTargetFileName""already exists; skipping render."
	fi
	cd $parentDir
done

# OPTIONAL: concatenates all the resulting videos into _mp4sConcatenated.mp4:
# concatVideos.sh mp4

printf "\nDone."