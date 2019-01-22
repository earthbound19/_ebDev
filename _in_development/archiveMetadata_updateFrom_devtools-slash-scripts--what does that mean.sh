# Re: http://www.sno.phy.queensu.ca/~phil/exiftool/metafiles.html
# Create XMP (metadata) sidecar file in a subdirectory; the -r option causes sub-directories to be recursively processed:
# Thanks to: http://stackoverflow.com/a/4909968 and http://stackoverflow.com/a/4040324

# TO DO
# - What? What was I trying to do with this? And an .ahk script (see notes at end)?
# If I revive use of this, make it not automatically overwrite existing files, including in archives (and only add files to an archive if they don't already exist).


# CODE
echo "!============================================================"
	echo "WARNINGS: This script may fail to archive metadata from file names which include spaces or other terminal-unfriendly characters. It writes .xmp metadata backups into (a) new ./_originalMetaData subfolder(s) in the directory and subdirectories for which it backs up image metadata. It will also overwrite any existing metadata .xmp backup files without prompting. NOTE: if you want to preserve already backed up metatada .xmp files, wrap them all up in a .zip or .7z archive and keep that in a safe folder. ALSO NOTE: before running this script, run fixIMGnames.sh in this same directory, and mind the NOTE it gives you before running this script. As this script invokes exiftool so many times, it will say that it creates images files, which is kinda inaccurate. It creates .xmp sidecar files which are backups of all the metadata in all the images this script finds--which includes very many file types. Edit the script to add further types."
	echo "Do you wish to run this script?"
	echo "!============================================================"
	echo "IF YOU HAVE READ the above warning, type the number corresponding to your answer, then press <enter>. If you haven't read the warning, your answer is 2 (No)."
	select yn in "Yes" "No"
	do
		case $yn in
			Yes ) echo Dokee-okee! Working . . .; break;;
			No ) echo Doh!; exit;;
		esac
	done

list=(`gfind . \( -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.raw  -o -iname \*.crw -o -iname \*.pdf \) -printf '%f\n' | sort`)
# \*.ptg (ArtRage) and *.kra (Krita) no recognized metadata :( I'd be surprised if .ora (any program) and .rif/.riff (any program though most likely Corel Painter) have readable metadata.

for element in ${list[@]}
{
	# echo ELEMENT:
	# echo "$element"
	imagePath=`expr match "$element" '\(.*\/\).*'`
	exiftool -o $imagePath/_originalMetaData/%f.xmp "$element"
}


# ==VERSION HISTORY==
# 01/19/2019 06:32:32 AM -- revived development by fixing functionality of find -> gfind in so many scripts. I think this is intended to back up metadata. Don't I already have something that does that though?
# 01/05/2016 01:17:42 AM -- seriously . . . good night. Got working in tandem with companion script, getShorterImageName.ahk/.exe. Added feature that it's smart enough to properly create and write to _originalMetaData subfolders for respective image directories.