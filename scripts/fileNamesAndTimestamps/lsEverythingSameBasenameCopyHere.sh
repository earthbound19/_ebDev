# DESCRIPTION
# For all files in the current directory, iterates over them, identifies the file name without the extension ("base name"), and copies all files that Everything search engine (voidtools.com) finds elsewhere on the computer which have that same base name but a different extension. For example, if you have files in the current directory named:
#    2_combo_05.png
#    2_combo_16.png
# -- and files elsewhere which Everything can find, named:
#    2_combo_05.hexplt
#    2_combo_16.hexplt
# This will figure out the basename of those .png files:
#    2_combo_05
#    2_combo_16
# -- and do an Everything search for all files that have that same basename, and copy here all the ones that have a different extension (and do not already exist in the current folder). The result will be that in the current directory you have these files:
#    2_combo_05.png
#    2_combo_05.hexplt
#    2_combo_16.png
#    2_combo_16.hexplt
# Does not clobber (overwrite) any duplicate file names in the current directory.

# USAGE
# Run without any parameters:
#    lsEverythingSameBasenameCopyHere.sh
# NOTE
# In case of duplicate file names on the computer, this will copy the first one that Everything lists and no others.


# CODE
# make an array of all filenames in the current directory
allFileNamesHere=( $(find . -maxdepth 1 -type f -printf "%P\n") )
# set variable of current directory to check against:
currDir=$(pwd)

# iterate over the array of file names, searching Everything for each file:
for fileName in ${allFileNamesHere[@]}
do
	# just in case we can end up with a blank array item? -- which would cause es to return ALL FILES ON THE COMPUTER -- AND LEAD TO TRYING TO MOVE EVERYTHING HERE -- check if fileName is blank (""); also ignore Windows thumbnail database files:
	if [ $fileName != "" ] && [ $fileName != "Thumbs.db" ]
	then
		# get file name without extension:
		fileNameNoExt=${fileName%.*}
		# the -a-d switch restricts results to files only (no folders) ; the tr statement deletes windows-style newlines, which throw win-ported GNU tools out of whack:
		everythingFound=( $(es -a-d $fileNameNoExt | tr -d '\15\32') )
		for found in ${everythingFound[@]}
		do
			nixyPath=$(cygpath $found)
				# printf "\nChecking path $nixyPath . . ."
			pathNoFileName="${nixyPath%\/*}"
			# if the path to the file is *different*, move it here:
			if [ ! "$pathNoFileName" == "$currDir" ]
			then
				printf "\nCHECKING IF OK TO COPY HERE: $nixyPath"
				# get found file name without path
				fileNameNoPath="${nixyPath##*/}"
				if [ ! -f $fileNameNoPath ]
				then
					printf "\nMay copy file here; is not already here; will copy $fileNameNoPath."
				cp -n $nixyPath .
				else
					printf "\nMay NOT copy file here; already here; will NOT copy $fileNameNoPath."
				fi
			fi
		done
	fi
done


