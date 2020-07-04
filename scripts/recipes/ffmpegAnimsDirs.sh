# DESCRIPTION
# Invokes ffmpegAnim.sh against every subfolder in the current folder,
# with hard-coded values including N second still of last frame at 
# end (see ffmpegAnim.sh invocation line). Assumes all subfolders in 
# the current folder contain animation frames (and you may get some 
# wonky animations if you have other images in subfolders). Not 
# recursive; will only work one folder level down from current folder,
# will not work on subfolders of those. Also, renames _out.mp4 
# result animations after containing folder of animation frames, and 
# moves the resulting renamed .mp4 file one directory up. Moreoer, it
 # checks for the final renamed .mp4 file before invoking 
# ffmpegAnim.sh (before rendering), and if the target file already 
# exists it skips that render (so, you may interrupt and resume 
# renders from this script).

# sorts by newest first:
directories=(`gfind . -maxdepth 1 -type d -printf '%f\n' | gsort -n | sed 's/.*[AM|PM] \.\/\(.*\)/\1/g'`)
# the :1 in the following slices the array to omit
# the first element, ., which we don't want;
# re: https://stackoverflow.com/a/2701872/1397555
directories=("${directories[@]:1}")

parentDir=`pwd`
for element in ${directories[@]}
do
	cd $element
	# trim any trailing "_frames" string off that we don't want:
	fileNameNoExt=${element%"_frames"}
	renderTargetFileName="$fileNameNoExt"".mp4"
	if ! [ -e ../"$fileNameNoExt".mp4 ]
	then
		printf "\nRendering to _out.mp4; will rename to ../""$renderTargetFileName"" . . .\n\n"
		ffmpegAnim.sh 30 30 7 png NULL 14
		mv _out.mp4 ../"$renderTargetFileName"
		# echo "sleeping for 40 seconds to let CPU(s) cool off . . ."
		# sleep 40
	else
		printf "\nTarget animation ../""$renderTargetFileName""already exists; skipping render."
	fi
	cd $parentDir
done

# OPTIONAL: concatenates all the resulting videos into _mp4sConcatenated.mp4:
# concatVidFiles.sh mp4

printf "\nDone."