# USAGE
# Invoke with two parameters:
# $1 instagram username (e.g. earthbound.io)
# $2 image file name to upload thereto
# -- e.g.:
# thisScript.sh earthbound.io ./_EXPORTED_M_variantWork_00099_FFsideToside_v02_PZ-8280x.jpg
#
# NOTE that the script provides the password parameter to uploadImageToInstagram.php via a text file (which text file you should keep secure in your home path, and out of any repository!), ~/instagramPassword.txt

# TO DO: test this!

if [ -e ~/instagramPassword.txt ]
then
	pw=$(< ~/instagramPassword.txt)
			# echo password is $pw
			# thas right, ima kludge:
	pushd .
# TO DO? : modularize so I don't have to give an absolute path here:
	cd "D:\Alex\Programming\instagram\Instagram-API\examples"
	php uploadImageToInstagram.php $1 $pw $2
	popd
fi