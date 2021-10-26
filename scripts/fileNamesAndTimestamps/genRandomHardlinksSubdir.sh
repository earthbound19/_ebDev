# DESCRIPTION
# For the current directory, takes all files of type $1 (parameter 1), and produces a subdirectory of incrementally numbered (file name) hardlinks to them, optionally randomly shuffling the file list before generating hardlinks. Does not directly do this; creates a script which you may execute to do this.

# USAGE
# Run with these parameters:
# - $1 The file type to generate a subfolder of numbered hardlinks to, for example png
# - $2 OPTIONAL. Any word, for example SNARFBLURN, which will cause the script to randomly shuffle the list of files (of extension $1) before generating numbered hardlinks.
# Example that will generate a script which can create numbered hardlinks (in a subdirectory) to all png files in the current directory:
#    genRandomHardlinksSubdir.sh png
# Example that will generate a script which can create numbered hardlinks (in a subdirectory) to all png files in the current directory, with the source files list shuffled before numbered hardlink creation (to randomize thier order in the numbered hardlinks) :
#    genRandomHardlinksSubdir.sh png SNARFBLURN
# To see what the subfolder name will be, examine the generated script as this script prompts you to after it runs.


# CODE
# TO DO?
# - verify need of this script? Doesn't another script make hardlinks?
# - if this script is needed, improve array creation/shuffling
echo Hi persnonzez!!!!!!!!!!!!!!! HI!! -Nem

find -maxdepth 1 ./*.$1 > xQpr95b2N_list.txt

# For optional parameter 2 to shuffle list:
if [ "$2" ]
	then
		shuf xQpr95b2N_list.txt > temp_fjioem882.txt
		rm xQpr95b2N_list.txt
		mv temp_fjioem882.txt xQpr95b2N_list.txt
fi

# the tr is because some platforms (stupidly) put spaces before the printout:
arraySize=`wc -l < xQpr95b2N_list.txt | tr -d ' '`
numDigitsOf_arraySize=${#arraySize}

mapfile -t allFilesArray < xQpr95b2N_list.txt
rm xQpr95b2N_list.txt

# generate empty shell script to write so many commands into.
timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
		# wowee gee parsing . . .
hardLinkDir=_""$1""_""$timestamp""numberedHardlinks
echoThis="if [ ! -d $hardLinkDir ]; then mkdir $hardLinkDir; fi"
echoTargetFile="$timestamp"_gen_"$1"_Hardlinks.sh.txt
echo $echoThis > $echoTargetFile

counter=0
for elm in ${allFilesArray[@]}
do
			# echo current file in list is\:
			# echo $elm
	counter=$((counter + 1))
	countString=`printf "%0""$numDigitsOf_arraySize""d\n" $counter`
	echo link $elm ./$hardLinkDir/"$countString"."$1" >> $echoTargetFile
done

echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
echo Created and populated hard link creation script $echoTargetFile\. Examine that file\, and if all the commands appear suitable\, temporarily rename it from \~\.sh.txt to \~\.sh and execute it. via this command\:
echo \.\/\<thatScriptName.sh\>