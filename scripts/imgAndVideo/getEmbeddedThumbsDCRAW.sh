# DESCRIPTION
# - Renames a raw format extension (for all files of type $1 in the current directory) from uppercase to lowercase (if they are uppercase).
# - Extracts all jpg thumbnails from all "raw" (camera) files of type $1 in the current directory. Renames them from .thumb.jpg extensions to just .jpg.

# DEPENDENCIES
# dcraw, a bash environment that can run this script (e.g. what comes with a Mac, or MSYS2 on Windows), toLowercaseExtensions.sh

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Image file format to search for (for example CRW, CR2, MRW, NEF, RAF..), without any . in the extension. If you omit this, it defaults to CR2.
# - $2 OPTIONAL. Any string, which will cause the script to search and operate on all subdirectories in the current directory also. Extracted thumbnails will be placed in the same directory (alongside their source "raw" file). If you use this parameter you must use (specify a type for) paramter $1.
# EXAMPLES
# Example command to operate on all NEF format files:
#    getEmbeddedThumbsDCRAW.sh NEF
# Example command to operate on all CR2 format files in the current directory and all subdirectories:
#    getEmbeddedThumbsDCRAW.sh CR2 foo

# CODE
if [ "$1" ]
then
	rawFormat=$1
else
	printf "\nNo parameter \$1 (\"raw\" image file format to search for) passed to script.\nDefaulting to CR2.\n"
	rawFormat="CR2"
fi
toLowercaseExtensions.sh $rawFormat
# since we just forced them to lowercase (if they were uppercase), change the search to lowercase if it is upper:
rawFormat=$(echo "$rawFormat" | tr '[:upper:]' '[:lower:]')

subDirSearchParam='-maxdepth 1'
fileList=($(find . $subDirSearchParam -name \*.$rawFormat -printf "%P\n"))

for file in ${fileList[@]}
do
	srcThumbName=${file%.*}.thumb.jpg
	destThumbRename=${file%.*}.jpg
	if [ -f $srcThumbName ] || [ -f $destThumbRename ]
	then
		echo Target file $srcThumbName OR $destThumbRename already exists\; will not overwrite.
	else
			# DEPRECATED approach because I want to skip renaming if the target existed; thanks to a genius breath yon https://stackoverflow.com/a/45703829, rename all .thumb.jpg files to just .jpg, and all .jpeg to jpg:
			# for x in *.thumb.jpg; do mv -i "$x" "${x%.thumb.jpg}.jpg"; done
		dcraw -e $file
		fileNameNoExt=${file%.*}
		mv "$fileNameNoExt".thumb.jpg "$fileNameNoExt".jpg
	fi
done