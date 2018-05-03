# DESCRIPTION
# Invokes a script that corrupts all files of a given extension in the directory from which this script is invoked, producing N glitched e.g. image file variants of all such file types, output to a /_glitched folder. See USAGE for options. Written specifically for the purpose of deliberately making glitch art out of e.g. .jpg files, but it may produce "good" results for a variety of file formats. OR, with some code change, invokes BM.exe (Byte Molester, a free tool).

# USAGE
# Pass this script four parameters, being:
# $1, a file extension (without the .) for file types in the current directory which you want to produce glitched variants of
# $2, the number of randomly chosen images among all available images in the directory to "glitch,"
# $3, the number of glitched images per image you wish to make.
# $4 What percent of each file to corrupt (1 to 100)

# The following command, for example, will select 20 jpg images, make 10 corrupted copies of each, corrupting each copy by 2 percent:
# thisScript.sh jpg 20 10 2

find *$1 > _alles.txt
mapfile -t allFilesOfExtension < _alles.txt
rm ./_alles.txt
sizeOfallFilesOfExtension=${#allFilesOfExtension[@]}
		echo val of sizeOfallFilesOfExtension\:
		echo $sizeOfallFilesOfExtension
if [ ! -d _glitched ]; then mkdir _glitched; fi
# exit
copiedFilesCount=0

# throw an error and exit if paramater $2 passed to script is greater than the number of available files (of extension $1) to copy:
if [ $sizeOfallFilesOfExtension -le $2 ]
then
	echo ERROR\: parameter \$2\, the requested number of files to copy of type $1 \(paramater \$1\) is greater than available number of such files\, $sizeOfallFilesOfExtension\ \(this script is not designed to avoid file name conflicts by e.g. duplicating the same source file to a new target name\)\.
	exit
fi

# In case of duplicate selections, keep copying files until the count of $2 is met.
while [ $copiedFilesCount -le $2 ]
do
	whichFileNum=`shuf -i 1-$sizeOfallFilesOfExtension -n 1`
			echo Randomly chosen file is:
			echo ${allFilesOfExtension[$whichFileNum]}
	if [ ! -e _glitched/${allFilesOfExtension[$whichFileNum]} ]
		then
		# Copy a file if the target file doesn't arleady exist.
		cp "${allFilesOfExtension[$whichFileNum]}" _glitched/
		copiedFilesCount=$(( copiedFilesCount + 1 ))
		# Corrupt the file $3 times.
		cd _glitched
		for x in $( seq $3 )
			do
			glitchThisFile.sh ${allFilesOfExtension[$whichFileNum]} $4
			done
		rm "${allFilesOfExtension[$whichFileNum]}"
		cd ..
					# another option, which would be done without a loop; use bm.exe, to be found in this repository: https://github.com/earthbound19/_ebdev
					# bm.exe "${allFilesOfExtension[$whichFileNum]}" bm.exe $1 -x jpg -u 100 -r 12 -t 1 -s 9 -a 5 -v -m +-
	fi
done

# because my windows Cygwin install can be a buggy moron about permissions:
chmod 777 ./_glitched/*


# dev scrap:
# find png_512_smileys_ff_output_glitchMods/*$1 > _alles.txt