# DESCRIPTION
# Repeatedly calls byte, uh, mangler dot exe to create corrupted copies of all files of a given type from the directory in which it is run. Hard-coded custom parameters at this writing.

# DEPENDENCIES bm.exe, uh, byte . . . mangler. The original author named it byte molester, and programmed it to use .fck file extensions. No thanks. And did he want it to be mistakenly thought of as BowelMovement.exe?

# USAGE
# Run with these parameters:
# - $1 a file type to scan for and make corrupt copies of
# - $2 how many corrupt copies to make
# Example that loads input.jpg and creating 12 corrupt copies of it:
#    glitchMangleAllFilesOfTypeNtimes.sh input.jpg 12


# CODE
# if [ ! -d ./out ]; then mkdir out; fi

files=( $(find . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n') )

if [ ! -e out ]; then mkdir out; else echo "POTENTIAL PROBLEM: subdirectory '/out' already exists. Rename or delete the '/out' subdirectory, then run the script again."; exit 2; fi
for file in ${files[@]}
do
	bm.exe $file -x jpg -u $2 -r 6 -t 1 -s 100 -v -a -m +-
	subdir_files=( $(find ./out -maxdepth 1 -type f -iname \*.$1 -printf '%f\n') )
	for subdir_file in ${subdir_files[@]}
	do
		echo generating rnd file name for moved file . . .
		randomCharsString=$(cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c 9)
		if [ ! -e "$file"_corrupted ]; then mkdir "$file"_corrupted; fi
		echo moving to ./out/$subdir_file to ./"$file"_corrupted/"$randomCharsString"_"$file" . . .
		mv ./out/$subdir_file ./"$file"_corrupted/"$randomCharsString"_"$file"
	done
done
rm -rf ./out