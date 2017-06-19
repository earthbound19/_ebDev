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
FullIMGpath="$currentDir"\\"$2"
		# echo $FullIMGpath

tmp=`which UploadPhotoCLI.php`
instagramAPIrepoPath=`dirname "$tmp"`
if [ $? == "0" ]
then
	foundAPIpath=1
else
	foundAPIpath=0
	echo Could not locate UploadPhotoCLI.php. Aborting script.
	exit
fi
		# echo path found is\:
		# echo $instagramAPIrepoPath

caption=$3
		# echo caption is\:
		echo $caption
# exit

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
			echo Writing command to batch and invoking batch:
			echo php UploadPhotoCLI.php $1 $pw $FullIMGpath \"$caption\"
	# This is ridiculous, but the only thing I've found that works: export the command to a stinking .bat file and call that .bat file.
	echo php UploadPhotoCLI.php $1 $pw $FullIMGpath \"$caption\" > tmp_dZv7S9WXXheh298ApQFmtyWnB6ya877vZw.bat
	chmod 777 ./tmp_dZv7S9WXXheh298ApQFmtyWnB6ya877vZw.bat
	tmp_dZv7S9WXXheh298ApQFmtyWnB6ya877vZw.bat
	rm ./tmp_dZv7S9WXXheh298ApQFmtyWnB6ya877vZw.bat
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