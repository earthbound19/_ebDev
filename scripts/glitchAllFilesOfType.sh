# DESCRIPTION
# Calls glitchThisFile.sh repeatedly, to create glitched versions of all files of a given extension in the directory from which this script is run, producing N glitched image file variants for each file, output to a `/_glitched folder`. See USAGE for options. Written specifically for the purpose of deliberately making glitch art out of e.g. .jpg files, but it may produce "good" results for a variety of file formats. OR, with some code change, runs BM.exe (Byte Molester, a free tool).

# USAGE
# Run with these parameters:
# - $1 a file extension (without the .) for file types in the current directory which you want to produce glitched variants of
# - $2 the number of glitched images per image you wish to make.
# - $3 what percent of each file to corrupt (1 to 100)
# Example command that will create 10 glitched versions of all jpg images in the current directory, corrupting 30 percent of their data:
#    glitchAllFilesOfType.sh jpg 10 30


# CODE
array=$(find . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n')

if [ ! -d _glitched ]; then mkdir _glitched; fi

for element in ${array[@]}
do
			echo corrupting file $element . . .
	cp "$element" ./_glitched/
	# Corrupt the file $2 times.
	cd ./_glitched
			corrupt_file_copy=0
	for x in $(seq $2)
		do
				corrupt_file_copy=$((corrupt_file_copy + 1))
				echo generating corrupt file copy number $corrupt_file_copy for $element . . .
		glitchThisFile.sh "$element" $3
		done
	rm "$element"
	cd ..
done

# In case Cygwin is silly about file permissions, uncomment the next line:
# chmod 777 ./_glitched/*