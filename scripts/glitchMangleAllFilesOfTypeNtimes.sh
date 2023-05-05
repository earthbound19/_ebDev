# DESCRIPTION
# Repeatedly calls byte, uh, mangler dot exe to create corrupted copies of all files of a given type from the directory in which it is run. This is hardly recommended; it can give very unpredictable and either too much or too little results.

# DEPENDENCIES bm.exe, uh, byte . . . mangler. The original author named it byte molester, and programmed it to use .fck file extensions. No thanks.

# USAGE
# Run with these parameters:
# - $1 a file type to scan for and make corrupt copies of
# - $2 how many corrupt copies to make
# - $3 OPTIONAL. Percent rate of destruction, as an integer, e.g. 8 for eight percent. If not provided, a default is used.
# Example that will create 12 corrupt copies for every jpg file in the current directory (so, for example, if there are two .jpg files you'll get 24 files; 12 corrupted copies of each) :
#    glitchMangleAllFilesOfTypeNtimes.sh jpg 12
# To do the same an instruct it to corrupt by 8 percent:
#    glitchMangleAllFilesOfTypeNtimes.sh jpg 12 8
# NOTE
# bm has four destruction-related parameters, and in my use of them I'm only guessing what they mean; the output from `bm --help` about them is:
#    -t THRESHOLD, --threshold=THRESHOLD Amount of destruction (0-255). Default: 1
#    -m MODE, --mode=MODE  Mode of destruction: +, -, +- or n. Default: +
#    -r RATE, --rate=RATE  Rate (%) of destruction (0-100). Default: 10
#    -a, --randomize       Randomize rate.
# You can try hacking the -t THRESHOLD parameter, but in my doing so, results varied extremely, and were mostly unusable above 1, and rarely usable above 3.


# CODE
if [ "$1" ]; then inputExt=$1; else printf "\nNo parameter \$1 (input file extension) passed to script. Exit."; exit 1; fi
# set number of output files to make:
if [ "$2" ]; then numberOfFilesToMake=$2; else printf "\nNo parameter \$2 (number of corrupt files to make) passed to script. Exit."; exit 2; fi
# optionally set destruction rate percent:
if [ "$3" ]; then percentRateDestruction=$3 ; else percentRateDestruction=3; fi

files=( $(find . -maxdepth 1 -type f -iname \*.$inputExt -printf '%f\n') )

if [ ! -e out ]; then mkdir out; else echo "POTENTIAL PROBLEM: subdirectory '/out' already exists. Rename or delete the '/out' subdirectory, then run the script again."; exit 3; fi
for file in ${files[@]}
do
	# because even if you tell it to make the output extension different, it does no conversion (it's just the same file format), make the output extension the same as the input:
	bm.exe $file -x $inputExt -u $numberOfFilesToMake -t 1 -r $percentRateDestruction -s 100 -v -a -m +-
	subdir_files=( $(find ./out -maxdepth 1 -type f -iname \*.$inputExt -printf '%f\n') )
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