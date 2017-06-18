# USAGE
# Invoke with two parameters:
# $1 instagram username (e.g. earthbound.io)
# $2 image file name to upload thereto, which image must be in your current PATH
# $3 caption for photo (surrounded by double quotes)
# -- e.g.:
# thisScript.sh earthbound.io ./_EXPORTED_M_variantWork_00099_FFsideToside_v02_PZ-8280x.jpg

# NOTE
# This script provides the password parameter to uploadImageToInstagram.php via a text file (which text file you should keep secure in your home path, and out of any repository!), ~/instagramPassword.txt -- ALSO NOTE that the /examples subdir of the Instagram-API repository must be in your PATH, as this script searches for one file UploadPhotoCLI.php in your path, and cds into that directory, AND LASTLY NOTE that owing to something butchering captions here, the caption parameter will be blanked out in this script until that is fixed.

currentDir=`pwd`
currentDir=`cygpath -w "$currentDir"`
FullIMGpath="$currentDir""$2"
echo $FullIMGpath

tmp=`which UploadPhotoCLI.php`
instagramAPIrepoPath=`dirname "$tmp"`
if [ $? == "0" ]
then
	foundAPIpath=1
else
	foundAPIpath=0
fi
		# echo path found is\:
		# echo $instagramAPIrepoPath

		# echo caption is\:
		# echo $3

# nope, doesn't work:
# caption=`echo "$3" | sed -f /cygdrive/c/_ebdev/scripts/urlencode.sed`
# TEMPORARY KLUDGE:
caption=

# Only call uploadImageToInstagram.php if the file ~/instagramPassword.txt exists AND $foundAPIpath has a value of 1:
if [ -e ~/instagramPassword.txt ] && [ $foundAPIpath == 1 ]
then
	pw=$(< ~/instagramPassword.txt)
			# echo password is $pw
			# thas right, ima kludge:
			echo saving current dir . . .
	pushd .
			echo moving to another dir . . .
	cd $instagramAPIrepoPath
			echo invoking command\:
	echo php UploadPhotoCLI.php $1 $pw $FullIMGpath $caption
	php UploadPhotoCLI.php $1 $pw $FullIMGpath $caption
# TO DO: fix whatever isn't allowing the full phrase for $3 to transmit for the caption; it seems that whatever I do (no quote marks, single quote marks, double-quote marks), it chops off the words after any space. This script even URL-encodes; that doesn't work either :(
			echo returning to saved dir . . .
	popd
fi




# NOTES copied from a dev. php script; which probably may be discarded but if not move them to other comment areas:
# Max. image dimensions 1080x1080 according to https://colorlib.com/wp/size-of-the-instagram-picture -- unsure whether that means longest any image can be on one or both sides is 1080; I assume so.
# You can share photos and videos with aspect ratios between 1.91:1 (the width almost two times the height, decimal 0.52356 = 1/1.91) and 4:5 (square with a fair amount of trim off sides, decimal 0.8 = 4/5) re: https://help.instagram.com/1469029763400082 but they may appear to users as a center-cropped square.
# You will need to point your php.ini to a valid cert file (get one if you don't have one) e.g.:
# openssl.cafile="C:\PHP\cacert.pem"
# also install this stuff by running:
# composer require mgp25/instagram-php
# --from the root of this cloned repo.