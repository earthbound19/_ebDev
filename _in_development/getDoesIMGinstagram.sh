# DESCRIPTION
# Retrieves the aspect of an image as a decimal and informs you (to do: and does stuff based on) whether the image falls within Instagram's allowed aspects of 0.8:1 to 1.9:1 (WxH) for uploads.

# NOTE Image aspects and dimensions allowed by Instagram are 0.8:1 through 1.9:1 and it may upload images larger than 1080px on a side but it will always shrink them to that if not to 600 px on a side. re: https://help.instagram.com/1631821640426723 -- and other URLs in comments in this script.

# USAGE
# Invoke with one parameter, being the image file name to check for Instagram aspect restraints fit (for upload), e.g.:
#  getDoesIMGinstagram.sh ./_EXPORTED_M_variantWork_00099_FFsideToside_v02_PZ-8280x.jpg
# NOTE that if you invoke this script with the source command before it, e.g.:
#  source getDoesIMGinstagram.sh ./_EXPORTED_M_variantWork_00099_FFsideToside_v02_PZ-8280x.jpg
# -- then the boolean variable $doesInstagram created by this script survives in the shell (for e.g. another script to use) after this script returns.

# DEPENDENCIES
# graphicsmagick, and a 'nix environment with the bc command-line calculator.

# TO DO
# Algebra if image is outside allowed aspect range to determine padding necessary to bring it into acceptable range; AND/OR to do that anyway along with padding image with a color scheme printout derived from it.


# CODE
		echo -~-~-~-~-~-~-
		echo getting aspect ratio for file by running command\; if something is wrong with the image information about that may appear after the command\:
		echo gm identify $1
identStr=`gm identify $1`
		# echo $identStr
xPix=`echo $identStr | sed 's/.* \([0-9]\{1,\}\)x[0-9]\{1,\}.*/\1/g'`
yPix=`echo $identStr | sed 's/.* [0-9]\{1,\}x\([0-9]\{1,\}\).*/\1/g'`
srcAspect=`echo "scale=5; $xPix / $yPix" | bc`		# thas right ima do hundred thousanths re (decimal accuracy) scale=5
		echo -~-~-~-~-~-~-
		echo x pix: $xPix
		echo y pix: $yPix

# re https://help.instagram.com/1469029763400082 "You can share photos and videos with aspect ratios between 1.91:1 and 4:5." ; is also in my aspect calc. spreadsheet resolution_and_aspect_etc_calculator.ods. Figure out which of those is closest to our aspect.
minAllowedAspect=0.8		# == 0.8:1 (which is also 4:5) OR with sum of ratios normalized to one: 0.444444:0.555556 -- a squarish, narrower image.
maxAllowedAspect=1.9		# == 1.9:1 OR with sum of ratios normailized to one: 0.655172:0.344828 -- a wide image.
		# re https://stackoverflow.com/a/31087503/1397555:
grtMaxBool=`echo "$srcAspect > $maxAllowedAspect" |bc -l`
lssMinBool=`echo "$srcAspect < $minAllowedAspect" |bc -l`
		echo srcAspect is $srcAspect\, grtMaxBool is $grtMaxBool and lssMinBool is $lssMinBool

if [ "$grtMaxBool" -eq "1" ] || [ "$lssMinBool" -eq "1" ]
then
		doesInstagram=0
		echo Source image $1 is OUTSIDE minimum or maximum aspect allowed by Instagram. You\'ll want to make the image wider or taller to bring it within the allowed range.
fi

if [ "$grtMaxBool" -eq "0" ] && [ "$lssMinBool" -eq "0" ]
then
		doesInstagram=1
		echo Source image $1 is within aspect range allowed by Instagram.
fi

# Decision? if source image exceeds max. allowed aspect, do maths to find pad image dimensions targeting aspect 1.38. or 1.65? or min. .22 less on aspect? -- target aspect 1.727 looks best in try off max allowed aspect img. ALSO if past a certain aspect (which?) FUHGETTABOUTIT.
# Decision? if source aspect is below min. allowed, do maths to find pad image dimensions targeting aspect 1.2. or 1.1? or min .22 more on aspect? ALSO if too narrow, FUHGETTABOUTIT.
