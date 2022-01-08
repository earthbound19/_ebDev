# DESCRIPTION
# Finds all empty directories in the current directory and their subdirectories (if they exist) and deletes them. Does so recursively; also removes empty directories that result from removal of an empty subdirectory.

# WARNING
# I don't know how this script might misbehave on directories with hidden files etc. Use at your own risk.

# USAGE
# Run without any parameters:
#    deleteEmptyDirectoryTrees.sh
# It prints feedback of anything it deletes as it runs. If it prints nothing, no empty directory was found.


# CODE
directories=( $(find . -type d) )
directories=( ${directories[@]:1} )
foundEmptyDirectory=FALSE

while [ borf ]		# Bash eveluates even an expression that will cause an error as true in a while loop condition?!
do
	for directory in ${directories[@]}
	do
		# checking for existence of directory here because while loop would otherwise lead to attempt to remove directory that does not exist (error printout):
		if [ -d $directory ] && [[ $(ls $directory) == "" ]]
		then
			foundEmptyDirectory=TRUE
			echo "found empty directory $directory; will delete."
			rm -rf $directory
		fi
	done
	
	if [ $foundEmptyDirectory == "FALSE" ]
	then
		break
	fi
	# if we don't reset this var here, the loop will contine forever:
	foundEmptyDirectory=FALSE
done
