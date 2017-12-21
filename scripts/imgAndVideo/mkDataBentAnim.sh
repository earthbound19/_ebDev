# DESCRIPTION
# Uses several other scripts to make animated bent data art from any series of files of a given extension. The resulting _out.gif (or out.mp4) animation visually represents (as animated data bent art) changes made in a file over time.

# USAGE
# From a path containing so many incremental (or otherwise saved!) *.bak files, invoke this script with one parameter $1, being the file extension of so many files to make an animation from. Do not include a . character in the extension. Example:
# ./thisScript.sh txt
# NOTE that you may wish to isolate all such source files as copies in .e.g a /progress subdirectory, and run this script from that.

# DEPENDENCIES
# allDataType2PPMglitchArt.sh, imgs2imgsNN.sh, mkNumberedLinks.sh, ffmpegAnim.sh, and their various dependencies; a series of automatically backed up files from a file that was edited.

# NOTES
# You will afterward have a numberedLinks subdirectory, which is full of numbered junction links to *.png files in the path above it. You may safely discard this subdirectory.

# TO DO
# Bug fix whichever of these scripts can take care of file name not always representing date . . . or do I already have a script that does that? I think so -- but optionally order/rename the .bak files by creation date, not just name. Hm. It looks like `renumberFiles.sh bak` may sometimes do the trick?

# CODE

if [ -z ${1+x} ]; then echo No paramater one \(input files extension e.g. txt\)\. Will exit.; exit; else fileExt=$1; echo SET fileExt to $1; fi

pushd .

allDataType2PPMglitchArt.sh $fileExt
mkdir ppm
mv *.ppm ./ppm
cd ppm
imgs2imgsNN.sh ppm png 550
mkNumberedLinks.sh png
cd numberedLinks
ffmpegAnim.sh 23 29.97 13 png
# move the result file up to the path we launched this script from:
mv _out* ../../

popd

# OPTIONAL: launch the result media file; if you're on windows:
cygstart _out.mp4 _out.gif
# OR if you're on mac:
# open _out.mp4 _out.gif