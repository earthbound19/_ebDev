# DESCRIPTION
# For all images of many types in the current directory, creates metadata archive files in a _originalMetaData subfolder. Metadata archives are named after the original image.

# USAGE
# Hack the list of image types to archive in the list= assignment code if you wish, and invoke this script.


# CODE
# Re: http://www.sno.phy.queensu.ca/~phil/exiftool/metafiles.html
# Create XMP (metadata) sidecar file in a subdirectory; the -r option causes sub-directories to be recursively processed:
# Thanks to: http://stackoverflow.com/a/4909968 and http://stackoverflow.com/a/4040324

# TO DO
# - integrate functionality from the .bat file this calls into this script
# - don't clobber existing metadata files
# - verify archive and delete metadata files (to save file space/clutter)
# - use the -args flag to archive this in a format suitable for re-entering into metadata (in -argument format for exiftool).
# NOT TO DO: update this to only work on file names that include _final_. I do actually want to archive metadata from everything. Even if it means it takes longer the first run.

list=(`find . -maxdepth 1 \( -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.raw  -o -iname \*.crw -o -iname \*.pdf \) -printf '%f\n' | sort`)
# \*.ptg (ArtRage) and *.kra (Krita) no recognized metadata :( I'd be surprised if .ora (any program) and .rif/.riff (any program though most likely Corel Painter) have readable metadata.

for element in ${list[@]}
{
	# echo ELEMENT:
	# echo "$element"
	# From exiftool help:
	# -u          (-unknown)           Extract unknown tags
	# -U          (-unknown2)          Extract unknown binary tags too
	# -z          (-zip)               Read/write compressed information
	imagePath=`expr match "$element" '\(.*\/\).*'`
	exiftool -u -U -o $imagePath/_originalMetaData/%f.xmp "$element"
}

# CALL DOS batch \(I know, the inconsistency of it all!\) which creates/updates an all_originalMetaData.7z (in this path), with everything in all _originalMetaData folders in this path \(meaning, including all _originalMetaData folders in all subfolders in this path\). See comments in the following invoked DOS batch for details:

imgMetaDataTo7z.bat

# TO DO:
# EXCEPT NO; DO THAT DER IN ANOTHER SCRIPT; BUT: MAKE CODE HERE TO NORK ALL DEM _originalMetaData FOLDERS IN THE PATH THIS SCRIPT IS EXECUTED FROM. Der.
# Add a switch to delete all _originalMetaData folders after calling this batch \(via the prior line mentioned "to do"\); include a default option for that switch set at the start of this script code \(I want it set by default to delete them\).
# Determine whether this will overwrite existing .xmp sidecars; if it does, have it *not* do that, but instead list sidecars that already exist \(list them to a text file\), and notify the user about that and the file.

# ==REVISION HISTORY==
# v1.0 01/05/2016 01:17:42 AM -- seriously . . . good night. Got working in tandem with companion script, getShorterImageName.ahk/.exe [01/31/2016 06:59:37 PM that's now renamed to getCorrectedImageName.ahk/exe]. Added feature that it's smart enough to properly create and write to _originalMetaData subfolders for respective image directories. This batch had been in development long prior; this is the first feature complete/functioning version, I think.
# v1.09 01/10/2016 01:00:47 AM . . . yerp :\) Good morning again. Created accompanying batch imgMDto7z.bat and invoked it from this here script. Good night.