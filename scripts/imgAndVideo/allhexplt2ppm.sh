# DESCRIPTION
# Invokes hexplt2ppm.sh for every .hexplt file in the path from which this script is invoked (non-recusrive).

# USAGE
# Invoke this script, optionally with the following parameters:
#  $1 OPTIONAL. Edge length of each square tile to be composited into final (png) image.
#  $2 OPTIONAL. MUST HAVE VALUE 0 or nonzero (anything other than 0). If nonzero, the script will randomly shuffle the hex color files before compositing them to one image.
#  $3 OPTIONAL. number of tiles accross of tiles-assembled image (columns).
#  $4 OPTIONAL. IF $3 IS PROVIDED (?), you probably want to provide this also, as the script does math you may not want if you don't provide (?) [Edit: I don't remember which parameter that is but it isn't $5, as I had written here--$5 is no longer a script option). Number of tiles down of tiles-assembled image (rows).
#  EXAMPLE COMMAND; for every ppm file in the current directory, create a palette image, where each tile is a square 250px wide, squares in the palette rendered in random order, and the palette image being 5 columns wide and 6 rows down:
#  ./thisScript.sh 250 foo 5 6


# CODE
echo "finding all *.hexplt files in the current path and subpaths . . ."
find . -maxdepth 1 -iname "*.hexplt" > all_hexplt.txt
		HEXPLTfilesCount=$(wc -l < all_hexplt.txt)
find . -maxdepth 1 -iname "*.ppm" > all_ppm.txt
		PPMfilesCount=$(wc -l < all_ppm.txt)
rm all_ppm.txt
		echo Number of ppm rendered palette files found\: $PPMfilesCount
		filesToRender=$(( $HEXPLTfilesCount - $PPMfilesCount ))

renderedCount=0
while read fileName
do
	targetFileName=`echo "${fileName%.*}.ppm"`	# removes .hexplt extension from filename and adds .ppm
	echo ~~~~
	# NOTE: Notwithstanding the following check is redundant (it is also done in the script this script calls), it will save time of needlessly invoking the script this calls:
	if [ ! -f $targetFileName ]
	then
				echo Target file $targetFileName not found\; WILL RENDER.
				renderedCount=$(( $renderedCount + 1 ))
				echo Rendering ppm file \#$renderedCount of \#$filesToRender
				echo invoking hexplt2ppm.sh for $fileName . . .
	# If parameters 1-4 weren't passed to the script, the variables will print nothing, and therefore pass no parameters to hexplt2ppm.sh:
	hexplt2ppm.sh $fileName $1 $2 $3 $4
	else
				echo Target file $targetFileName found\; WILL SKIP RENDER.
	fi
done < all_hexplt.txt

rm all_hexplt.txt

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path and subpaths. Palette images are named after the source *.hexplt files. If you used parameter \$2, then blown up png images by the same base file name were created also."