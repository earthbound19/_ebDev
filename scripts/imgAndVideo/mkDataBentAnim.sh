# DESCRIPTION
# Uses several other scripts to make animated bent data art from any series of *.bak files (Notepad Plus Plus auto-backups, or from any other program that makes automatic backups so named). in a /progress subdir of whatever path this script is run from. The resulting _out.gif (or out.mp4) animation visually represents (as animated data bent art) changes made in a file over time.

# USAGE
# From a path containing so many incremental (or otherwise saved!) *.bak files, invoke this script:
# ./thisScript.sh

# DEPENDENCIES
# allDataType2PPMglitchArt.sh, imgs2imgsNN.sh, mkNumberedLinks.sh, ffmpegAnim.sh, and their various dependencies; a series of automatically backed up files from a file that was edited.

# NOTES
# You will afterward have a numberedLinks subdirectory, which is full of numbered junction links to *.png files in the path above it. You may safely discard this subdirectory.

# TO DO
# Parameterize "bak".
# Bug fix whichever of these scripts can take care of file name not always representing date . . . or do I already have a script that does that I think so -- but optionally order/rename the .bak files by creation date, not just name. Hm. It looks like `renumberFiles.sh bak` may sometimes do the trick?

# CODE
pushd .

allDataType2PPMglitchArt.sh bak
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