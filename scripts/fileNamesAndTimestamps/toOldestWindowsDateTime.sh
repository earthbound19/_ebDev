# DESCRIPTION
# For correcting date stamps in files in Windows file systems that get into inconsistent or outright wrong states by backups, restores or other file operations. Via exiftool, scans the creation date, modification date, access date, metadata Create Data, and Metadata Date/time stamps (the latter two for image etc. files), then sets the Windows file _creation_ date/time (possibly unique to windows--not in 'nix file systems) to the earliest of these, and the file _modification_ time to the newest of these.

# USAGE
# Invoke with the name of a file to so modify the timestamps of it, e.g.:
#  toOldestWindowsDateTime.sh image.jpg
# OR e.g.:
#  toOldestWindowsDateTime.sh source_file.txt
# To do this for every file (regardless of file type) in the current directory, see allToOldestWindowsDateTime.sh.

# DEPENDENCIES
# exiftool, sed, head, tail, binarez_touch http://www.binarez.com/touch_dot_exe/ (a copy is in my _ebSuperBin repo).


# CODE
if [ -z "$1" ]; then echo "NO source file \$1 passed to script. Exiting."; exit; fi

exiftool $1 > tmp_E8eK.txt
printf "" > tmp2_E8eK5t4aw.txt

sed -n 's/\(.*File Modification Date\/Time *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' tmp_E8eK.txt >> tmp2_E8eK5t4aw.txt
sed -n 's/\(.*File Access Date\/Time *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' tmp_E8eK.txt >> tmp2_E8eK5t4aw.txt
sed -n 's/\(.*File Creation Date\/Time *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' tmp_E8eK.txt >> tmp2_E8eK5t4aw.txt
sed -n 's/\(.*Create Date *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' tmp_E8eK.txt >> tmp2_E8eK5t4aw.txt
sed -n 's/\(.*Metadata Date *: \)\([0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\2/p' tmp_E8eK.txt >> tmp2_E8eK5t4aw.txt

# TRANSFORM FOR BINAREZ_TOUCH; comment this out if you use the exiftool option below:
sed -i 's/\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\) \([0-9]\{2\}\)/\1-\2-\3T\4/g' tmp2_E8eK5t4aw.txt

sort tmp2_E8eK5t4aw.txt > tmp_E8eK.txt
dos2unix tmp_E8eK.txt
createAdjustmentDateStamp=`head -n 1 tmp_E8eK.txt`
modifyAdjustmentDateStamp=`tail -n 1 tmp_E8eK.txt`
rm tmp_E8eK.txt tmp2_E8eK5t4aw.txt

# ---- START EXIFTOOL OPTION--DEPRECATED. IF YOU USE THIS OPTION, uncomment the next two lines of code, comment out the code in the BINAREZ_TOUCH section below, and also comment out the line of code after the "TRANSFORM FOR BINAREZ_TOUCH" comment above. (Do the invert of those instructions if you use binarez_touch.) NOTE: previously this erroneously updated CreateDate, which I believe alters file metadata--but the intent of this script was to modify Windows file system time stamp attributes, which this has been corrected to do via FileCreateDate:
#exiftool -overwrite_original -FileCreateDate=\""$createAdjustmentDateStamp"\" $1
#exiftool -overwrite_original -FileModifyDate=\""$modifyAdjustmentDateStamp"\" $1
# ---- END EXIFTOOL OPTION

# ---- START BINAREZ_TOUCH OPTION--PREFERRED: this will update time stamps for files that exiftool won't; ex. call binarez_touch 027_cover.jpg -acxv -d 2019-01-18T05:15:32:
binarez_touch $1 -cxv -d $createAdjustmentDateStamp
binarez_touch $1 -cmv -d $modifyAdjustmentDateStamp
# ---- END BINAREZ_TOUCH OPTION