# DESCRIPTION
# For all files in the current directory, attempts to extract basic metadata from exiftool information dumps: File Name (for reference), Exposure Time, F Number, and ISO, and compiles all that to allEssentialImageCameraInfo.txt. Useful for comparing the effects of camera settings on photography.

# USAGE
# Run from a directory which has only a given set of photos whose essential camera parameter characteristics you wish to compare. The script will automatically open the resultant tab-delimited text file of data.


# CODE
rm allEssentialImageCameraInfo.txt

exiftool * > alles.txt
sed -n 's/\(^File Name*.\)/\1/p' alles.txt > fileNames.txt
sed -n 's/\(^Exposure Time*.\)/\1/p' alles.txt > exposures.txt
sed -n 's/\(^F Number*.\)/\1/p' alles.txt > Fnumbers.txt
sed -n 's/\(^ISO[^0-9]*[0-9].*\)/\1/p' alles.txt > ISOs.txt

paste ./fileNames.txt ./exposures.txt ./Fnumbers.txt ./ISOs.txt > allEssentialImageCameraInfo.txt

rm alles.txt fileNames.txt exposures.txt Fnumbers.txt ISOs.txt

start allEssentialImageCameraInfo.txt