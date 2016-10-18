# TO DO:
# Explain this script in comments.
# Make this generate a noise replacement image for every irrecoverably corrupt image.
# ? Have it repeat corruptions in a loop over the result of each loop?

ffmpeg -i $1 %20d.jpg
corruptMangleAllFilesOfTypeNtimes.sh jpg 1
rm *.jpg
identifyCorruptIMGs.sh jpg
rm ./_irrecoverable/*.*
renumberFiles.sh jpg
# Nukes all resultant empty directories:
CygwinFind -type d -empty -delete
ffmpegAnim.sh 29.97 29.97 13 jpg
mkdir _frames
mv *.jpg ./_frames
cygstart _out.mp4