# DESCRIPTION
# Uses several other scripts to make animated bent data art from any series of files of a given extension. The resulting _out.gif (or out.mp4) animation visually represents (as animated data bent art) changes made in a file over time. Every (blown up) pixel in an animation represents a datum from the source file (in an animated series of images).

# DEPENDENCIES
# The dependencies of this script sadly may not all be platform-neutral. They are:
#    IrfanView
#    all_data_bend_type2PPMglitchArt.sh
#    imgs2imgsNN.sh
#    renumberFiles.sh
#    ffmpegAnim.sh
# -- and their various dependencies, and a series of automatically backed up files from a file that was edited AND/OR pulled out of git via gitDumpAllFileVersions.sh.

# USAGE
# From a path containing so many incremental (or otherwise saved!) *.bak files, run this script with:
# - $1 the file extension of so many files to make an animation from. Do not include a . character in the extension.
# Example that will produce an animation from all files in the current directory that end in .bak:
#    mkDataBentAnim.sh bak
# NOTES
# - This script names the result mp4 after the folder containing the .bak files. So, if they are in a folder named `hexplt2rgbplt_as_dataBentAnim`, the mp4 will be named `hexplt2rgbplt_as_dataBentAnim.mp4`.
# - See gitDumpAllFileVersions.sh to get a collection of all versions of a file from any git repository's history, to work up to a data bent animation via this script.


# CODE

if [ -z "$1" ]; then echo No parameter one \(input files extension e.g. txt\)\. Will exit.; exit; else fileExt=$1; echo SET fileExt to $1; fi

pushd .

all_data_bend_type2PPMglitchArt.sh $fileExt
mkdir ppm
mv *.ppm ./ppm
cd ppm
# formerly used 550 as last parameter here:
imgs2imgsNN.sh ppm png 720 720
# ANOTHER OPTION instead of that last line; doesn't work on 'nix/mac (gm / ImageMagick doesn't like my ppm files) :
# imgs2imgsnn.sh ppm png 1280

mkdir ../png
mv *.png ../png/
cd ../png
renumberFiles.sh png
ffmpegAnim.sh 11 30 13 png NULL 6
# rename the result _out.mp4 after this directory;
# re a genius breath: parentname="$(basename "$(dirname "$filepath")")" -- forgot to link to source of that finding!
thisPath=$(pwd)
parentDirectoryName="$(basename "$(dirname "$thisPath")")"
mv ./_out.mp4 ../__"$parentDirectoryName".mp4
popd


echo DONE. result is __"$parentDirectoryName".mp4.

# OPTIONAL: subdirs cleanup:
rm -rf ppm
rm -rf png
# OPTIONAL: launch the result media file; if you're on windows:
# cygstart ../__"$parentDirectoryName".mp4 ../__"$parentDirectoryName".gif
# OR if you're on mac:
# open ../__"$parentDirectoryName".mp4 ../__"$parentDirectoryName".gif