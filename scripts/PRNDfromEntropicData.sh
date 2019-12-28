# DESCRIPTION
# Produce psuedo-random data which for all anyone knows could be called true random data if you begin with pure random entropy files like jpeg photograps. Reference: https://crypto.stackexchange.com/a/43121 WARNING: do this only on a copy of data or on expendable data--it will destroy all original data in the folder from which it was run! It moves generated PRND data into the ../_final_TRND_archive folder

# USAGE
# Invoke with one optional parameter, being the block size to split the concatenated data into before hashing, e.g.:
# thisScript.sh 780
# -- if the optional parameter is not chosen it will pseudo-randomly choose a split block size between 464 and 1247.

# DEPENDENCIES
# xxd, rehash, and unless rehash is available on other platforms, Windows. On Cygwin install it via `apt-cyg install hxd`

# PROCESS
# This script: creates a .dat file by 1) concatenating all data in a directory into one file, moving that new file out of the way, deleting all files in the directory, moving the concatenated file back, and 2) cutting the file (binary split) into files of a size of bytes psuedo-randomly chosen between 242-512 bytes, extracting noise from all of them via non-cryptographic hashing (and collating the hashes into one hex string and interpreting that as binary values written to a new random data file (.dat). It then moves the new random data file into an archive folder and concatenates all the split files into one file which may be "recycled" with this same "chaos machine" process. 

# TO DO
# - If applicable? : adapt this to have output in pure hex to begin with via e.g. hexData=`xxd -ps dataFile.dat`
# - adapt this to a TRND script which doesn't invoke any chaos machine process on files.
# - find cross-platform tools that will accomplish the same as rehash -- OH. OR: compile the source code which is here: https://sourceforge.net/projects/rehash/files/rehash/0.2/
# - use--and additional algos provided by? : https://github.com/ColumPaget/Hashrat
# - use cksum? re: https://stackoverflow.com/a/3328620/1397555
# - and/or use openssl Message Digest (dgst) command to get these types:
#  - md2            md4            md5            mdc2           rmd160         sha            sha1
#  - e.g.:
#  echo "wut" | openssl dgst -mdc2
# OR? :
# SHA256
# openssl dgst -sha256 path/to/myfile
# MD5
# openssl dgst -md5 path/to/myfile
#  - re https://stackoverflow.com/q/11066171/1397555
# OH: openssl can do a lot of hash types; see them with:
# openssl list -digest-algorithms
# re: https://wiki.openssl.org/index.php/Command_Line_Utilities
# . . . see list after code!


# CODE

if [ -z "$1" ]
	then
		echo No split block size passed to script. Picking one at random \(for super-concatenated superBlock.dat to be made\) . . .
		blockSplitSize=`shuf -i 242-512 -n 1`
		echo chose block size $blockSplitSize.
	else
	blockSplitSize=$1
	echo block size specified is $blockSplitSize.
fi

# Large bytes blocks pseudo-random rearrangement to reuse the data; if you don't like this you need to read the code to alter implications for later code in the script:
cat * > ../superBlock.dat
rm *.*
mv ../superBlock.dat .
splits superBlock.dat $blockSplitSize
rm ./superBlock.dat
# Psuedo-randomly renames all files, effectively shuffing their order so they can be re-concatenated into a new, unique, timestamped ~superBlock.dat at the end of the script; this is VERY inneficient and could be replaced by a shuffled array of file names iterating over cat commands to append to the dest data:
allRandomFileNames.sh 11

# NOTE: fcs32 hashes collide with crc32.
# Huh. The following command sometimes does and sometimes doesn't run under cygwin; it apparently consistently does though if I invoke it on windows' cmd (terminal) by calling *that* from the cygwin shell, thusly:
cmd /c 'rehash -none -adler32 -crc16 -crc16c -crc16x -crc32 -elf32 -fcs16 -fnv32 -fnv64 -ghash3 -ghash5 -rmd120 -rmd160 -xum32 -out:raw -out:pad:false -out:nospaces *.* > rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt'
# because that results in windows "newlines" (\n\r), change them to 'nix:
dos2unix rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt
# strip down that output to only hex prints and newlines:
sed -i -e 's/.*: \(.*\).*/\1/g' -e 's/<.*>//g' rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt
timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
tr -d '\n' < rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt > __trueRandomData_"$timestamp"_HEXsrcTable.txt
rm rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt
# Huh? There is no -p flag. Did I mean -ps? TO DO: check:
# xxd -r -p __trueRandomData_"$timestamp"_HEXsrcTable.txt __trueRandomData_"$timestamp".dat
xxd -r -ps __trueRandomData_"$timestamp"_HEXsrcTable.txt __trueRandomData_"$timestamp".dat

mv __trueRandomData_"$timestamp"_HEXsrcTable.txt __trueRandomData_"$timestamp".dat ../_final_TRND_archive

echo ----
# nah -- and __trueRandomData_"$timestamp"_HEXsrcTable.txt have
echo DONE. __trueRandomData_"$timestamp".dat has been moved to ../_final_TRND_archive

timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
cat * > ../_superblock_SOURCE_notPRND__$timestamp.dat
rm *.*
mv ../_superblock_SOURCE_notPRND__$timestamp.dat ./


# DEV NOTES
# usage of rehash:
# rehash [options1] filespec [options2] [> outputfile]
# for further help, see: http://rehash.sourceforge.net/rehash.html#resamples

# usage of xhd to convert a hex string to a binary file (of corresponding actual hex binary values):
# https://stackoverflow.com/a/7826789/1397555 -- e.g. `xxd -r -p in.txt out.bin` OR `echo 17F6EC7100437960F8EEDFD0A2D33B514DCC9726 | xxd -r > out.dat`

# openssl digest algoriths:
# blake2b512        blake2s256        gost              md4               
# md5               mdc2              rmd160            sha1              
# sha224            sha256            sha3-224          sha3-256          
# sha3-384          sha3-512          sha384            sha512            
# sha512-224        sha512-256        shake128          shake256          
# sm3
# . .
# invoke any of these with binary output, converted to hex, without extranous print information, for example, this way; re https://unix.stackexchange.com/a/90242/110338 :
# openssl dgst -md5 Photo_on_11-6-19_at_10.41_PM.jpg

# what hash functions are unique to what tool (preferring openssl where multiple tools have it;
# --openssl:
# blake2b512
# blake2s256
# gost
# md4               
# md5
# mdc2
# rmd160
# sha1              
# sha224
# sha256
# sha3-224
# sha3-256          
# sha3-384
# sha3-512
# sha384
# sha512            
# sha512-224
# sha512-256
# shake128
# shake256          
# sm3
# --rehash:
# adler32
# crc16
# crc16c
# crc16x
# crc32
# elf32
# fcs16
# fnv32
# fnv64
# ghash3
# ghash5
# rmd120
# xum32