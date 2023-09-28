# DESCRIPTION
# Retrieves the aspect of an image as a decimal and informs you (to do: and does stuff based on) whether the image falls within Instagram's allowed aspects of 0.8:1 to 1.9:1 (WxH) for uploads. Also calculates pad dimensions to bring within aspect requirements if inside or outside them, and prints that padding information and sets environment variables with that information (for use by other scripts). See NOTES.

# DEPENDENCIES
# GraphicsMagick, and a 'nix environment with the bc command-line calculator.

# USAGE
# Run with one parameter, being the image file name to check for Instagram aspect restraints fit (for upload), e.g.:
#    getDoesIMGinstagram.sh ./_EXPORTED_M_variantWork_00099_FFsideToside_v02_PZ-8280x.jpg
# NOTES
# - if you run this script with the source command before it, e.g.:
#    source getDoesIMGinstagram.sh ./_EXPORTED_M_variantWork_00099_FFsideToside_v02_PZ-8280x.jpg
# -- then the boolean variable $doesInstagram created by this script survives in the shell (for e.g. another script to use) after this script returns.
# - in the case of the image being under or over aspect requirements, the script also calculates and sets environment variables targetXpix and targetYpix, which are dimensions that would bring the image into aspect requirements if you pad the image to them. Those environment variables may be set the same way by calling the script with `source`.
# - instagram allows uploads under/over aspect requirements, or over/under recommended resolutions, but will modify the image by cropping/padding/resizing. re: https://help.instagram.com/1631821640426723 -- and other URLs in comments in this script.


# CODE
		echo "-~-~-~-~-~-~-"
		echo "Getting aspect ratio for file by running command. If something is wrong with the image, an error may print after the following command is run:"
		echo "gm identify $1"
identStr=$(gm identify $1)
xPix=$(echo $identStr | sed 's/.* \([0-9]\{1,\}\)x[0-9]\{1,\}.*/\1/g')
yPix=$(echo $identStr | sed 's/.* [0-9]\{1,\}x\([0-9]\{1,\}\).*/\1/g')
srcAspect=$(echo "scale=5; $xPix / $yPix" | bc)		# thas right ima do hundred thousanths re (decimal accuracy) scale=5
		echo "-~-~-~-~-~-~-"
		echo "x pix: $xPix"
		echo "y pix: $yPix"

# re https://help.instagram.com/1469029763400082 (dead URL) - https://skedsocial.com/blog/the-ultimate-up-to-date-social-media-image-sizes-guide - https://blog.hootsuite.com/social-media-image-sizes-guide/#Instagram_image_sizes - https://sproutsocial.com/insights/social-media-image-sizes-guide/#instagram : ratios between 4:5 and 1.91:1
minAllowedAspect=0.8		# == 0.8:1 (which is also 4:5) OR with sum of ratios normalized to one: 0.444444:0.555556 -- a squarish, narrower image.
maxAllowedAspect=1.9		# == 1.9:1 OR with sum of ratios normalized to one: 0.655172:0.344828 -- a wide image.
		# re https://stackoverflow.com/a/31087503/1397555:
grtMaxBool=$(echo "$srcAspect > $maxAllowedAspect" | bc -l)
lssMinBool=$(echo "$srcAspect < $minAllowedAspect" | bc -l)
		echo aspect is $srcAspect
		# echo grtMaxBool is $grtMaxBool and lssMinBool is $lssMinBool

if [ "$grtMaxBool" -eq "1" ] || [ "$lssMinBool" -eq "1" ]
then
		doesInstagram=0
		echo "Source image $1 is OUTSIDE minimum or maximum aspect allowed by Instagram. To use the image there, you may want to make it wider or taller (including by padding) to bring it within the allowed range."
		if [ "$lssMinBool" -eq "1" ]
		then
			# printf to correctly round a result to nearest integer; re: https://askubuntu.com/a/574474 :
			targetXpix=$(echo "($yPix * $minAllowedAspect)" | bc -l | xargs printf %.0f)
			echo "You can adjust the image to meet aspect $minAllowedAspect (minimum allowed) by padding the X pixels (dimension across) to:"
			echo $targetXpix
			targetYpix=$yPix
		fi
		if [ "$grtMaxBool" -eq "1" ]
		then
			targetYpix=$(echo "($xPix / $maxAllowedAspect)" | bc -l | xargs printf %.0f)
			echo "You can adjust the image to meet aspect $maxAllowedAspect (maximum allowed) by padding the Y pixels (dimension down) to:"
			echo $targetYpix
			targetXpix=$xPix
		fi
fi

if [ "$grtMaxBool" -eq "0" ] && [ "$lssMinBool" -eq "0" ]
then
		doesInstagram=1
		echo "Source image $1 is within aspect range allowed by Instagram."
fi