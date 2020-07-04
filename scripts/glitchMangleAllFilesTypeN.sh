# DESCRIPTION
# Repeatedly calls byte, uh, mangler dot exe to create corrupted copies of all files of a given type from the directory in which it is invoked. Hard-coded custom parameters at this writing.

# USAGE
# two parameters: $1 a file type to scan for and make corrupt copies of. $2 how many corrupt copies to make.

# DEPENDENCIES bm.exe, uh, byte . . . mangler. The original author named it byte molester, and programmed it to use .fck file extensions. No thanks. And did he want it to be mistakenly thought of as BowelMovement.exe?


# CODE
# if [ ! -d ./out ]; then mkdir out; fi

array=(`gfind . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n'`)

for element in ${array[@]}
do
	# randomCharsString=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $numRandomCharsToGet`
	bm.exe $element -x jpg -u $2 -r 6 -t 1 -s 100 -v -a -m +-
	mv ./out ./"$element"_corrupted
	mkdir out
	echo element is $element
done