# DESCRIPTION
# Crawls all directories in the current path and runs palettesMarkdownGallery.sh in every one.

array=(`gfind . -type d -printf '%f\n'`)

currdir=`pwd`

for element in ${array[@]}
do
	pushd .
	cd $currdir/$element
	palettesMarkdownGallery.sh
	popd .
done

# echo "DONE running palettesMarkdownGallery.sh in every directory in this path."