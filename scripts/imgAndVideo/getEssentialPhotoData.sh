# USAGE: run from a directory which has only a given set of photos whose essential camera parameter characteristics you wish to compare. The script will automatically open the resultant tab-delimited text file of data.

rm allEssentialImageCameraInfo.txt

exiftool * > alles.txt
sed -n 's/\(^File Name*.\)/\1/p' alles.txt > fileNames.txt
sed -n 's/\(^Exposure Time*.\)/\1/p' alles.txt > exposures.txt
sed -n 's/\(^F Number*.\)/\1/p' alles.txt > Fnumbers.txt
sed -n 's/\(^ISO[^0-9]*[0-9].*\)/\1/p' alles.txt > ISOs.txt

paste ./fileNames.txt ./exposures.txt ./Fnumbers.txt ./ISOs.txt > allEssentialImageCameraInfo.txt

rm alles.txt fileNames.txt exposures.txt Fnumbers.txt ISOs.txt

cygstart allEssentialImageCameraInfo.txt

# Done 06/13/2016 08:05:19 PM -RAH