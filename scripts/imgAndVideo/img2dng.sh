# DESCRIPTION
# Converts file $1 to Adobe DNG (digital negative), but don't use DNG. At best you have to keep the original raw image around anyway (in case the DNG toolchain becomes outdated), and DNG has not seen wide adoption.

# DEPENDENCIES
# AdobeDNGConverter.exe in your PATH.

# USAGE
# Run with one parameter, which is a file name for an image to convert to DNG, e.g.:
#    img2dng.sh inputFile.cr2


# CODE
# Command line options and use of program found here: http://cpicture.thecloudsite.net/blog/content/public/upload/convert-Raw-to-TIFF.ps1.txt 08/20/2015 06:06:35 PM -RAH
# NOTE if you add the -e switch it will embed the original raw (/CR2 etc) file in the dng.
echo "I recommend against using DNG files because they have mixed support among software vendors and manufacturers . . ."
AdobeDNGConverter.exe -c -fl -cr7.1 -e $1


# DEVELOPER NOTES
# Formerly img2dng.bat, functionally identical but run from Windows cmd.