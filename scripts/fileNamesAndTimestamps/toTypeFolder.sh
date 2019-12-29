# DESCRIPTION
# move all files of a given type into a new subdirectory named after that type, *only* if such a subdirectory does not already exist.

# USAGE
# Pass this script one parameter ($1), being a file type to so sort, without any . in the file extension. NOTE: It does this for every file of that type in a tree (recursive--it scans all subfolers).

# EXAMPLE:
# ./thisScript.sh png

# list all directories in path.
gfind -type d > allDirs.txt
# remove all directories from listing which are a name match for the extension in paramater $1. Dunno why -i won't work here:
sedPattern="s/\(.*\/$1.*\)//p"
gsed $sedPattern allDirs.txt > allDirsMinusType.txt
# strip blank lines from that result.
gsed -i ':a;N;$!ba;s/\n\n//g' allDirsMinusType.txt
mapfile -t allIMGs < allDirsMinusType.txt
rm allDirs.txt allDirsMinusType.txt

for dirName in ${allIMGs[@]}
do
						# re: http://stackoverflow.com/a/3856879
						# test command:
						# count=`ls -1 $dirName*.$1 2>/dev/null | wc -l`
						echo ---------------------
						echo dirName is $dirName
	count=`ls -1 $dirName/*.$1 2>/dev/null | wc -l | tr -d ' '`
		if [ $count != 0 ];
			then
						echo $1 file found.
				if [ ! -d $dirName/$1 ]
					then
						echo no $1 dir\, will create and move all $1 files into.
						mkdir $dirName/$1
						mv $dirName/*.$1 $dirName/$1
					else
						echo $1 dir exists, will not attempt to create.
				fi
			else
						echo no $1 file found\; did not even check for dir.
		fi
						echo =====================
done