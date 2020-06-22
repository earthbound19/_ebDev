# DESCRIPTION
# runs idiff_all_img_pairs.sh, then gm_average_all_img_pairs.sh (both from the _ebDev repository--both those scripts and their dependencies must be in your PATH), then takes all the results of the former and averages them with all the results of the latter (for more interesting/subtle effects that lighten up too dark results), rendering all those results to the /process_hybrids subfolder. See comments in those first two scripts to learn what they do. NOTE: This script takes a random pair from array A and super-composites it against every image in array B. In contrast, a very similar script, diff_avg_supercomposites.sh, repeatedly supercomposites random pairs from array A and B.

# USAGE
# diff_avg_supercomposites_nested_loop.sh

# DEPENDENCIES
# _ebDev repo in your path via _ebPathMan, graphicsmagic, openimageio, and/or if you're on windows, _ebSuperBin.

# NOTE: if you've already run the following two scripts, comment them out before you run this:
idiff_all_img_pairs.sh
gm_average_all_img_pairs.sh

# DEV NOTE: Thought experiment on diffing a diff: things would just get really dark. Hm. Unless some of the diffs are bright. Also you could outright add an averaged result to a differed result . .


# CODE
# make arrays of all files that resulted from the first two scripts; SHUFFLE them so that we get early random output (as the target image pool can be so huge that if your source image set has similar properties from one image to the next in the set, it can labor on similar images forever, but I want to see a random selection early) :

cd image_pairs_diffs
array_A=(`gfind . -maxdepth 1 \( \
-iname \*.tif \
-o -iname \*.tiff \
-o -iname \*.png \
-o -iname \*.psd \
-o -iname \*.psb \
-o -iname \*.ora \
-o -iname \*.rif \
-o -iname \*.riff \
-o -iname \*.jpg \
-o -iname \*.jpeg \
-o -iname \*.gif \
-o -iname \*.bmp \
-o -iname \*.cr2 \
-o -iname \*.raw \
-o -iname \*.crw \
 \) -printf '%f\n' | gshuf`)

cd ../image_pairs_averages
array_B=(`gfind . -maxdepth 1 \( \
-iname \*.tif \
-o -iname \*.tiff \
-o -iname \*.png \
-o -iname \*.psd \
-o -iname \*.psb \
-o -iname \*.ora \
-o -iname \*.rif \
-o -iname \*.riff \
-o -iname \*.jpg \
-o -iname \*.jpeg \
-o -iname \*.gif \
-o -iname \*.bmp \
-o -iname \*.cr2 \
-o -iname \*.raw \
-o -iname \*.crw \
 \) -printf '%f\n' | gshuf`)

cd ..

# make dir for output if it doesn't exist already:
if [ ! -d process_hybrids ]; then mkdir process_hybrids; fi

for A in ${array_A[@]}
do
	for B in ${array_B[@]}
	do
		B_no_ext=${B%.*}
		A_no_ext=${A%.*}
		
		# Take a diff (subtraction) result and average it with an averaged results:
		outfileNoExt="process_hybrids/""$A_no_ext"__"$B_no_ext"__avg
		outfile="$outfileNoExt".tif
		if [ ! -e "$outfileNoExt"* ]
		then
			echo Doing average of pair $A and $B . . .
			gm convert image_pairs_diffs/$A image_pairs_averages/$B -average $outfile
		else
			echo ~- Target file or similarly named already exists \($outfile\). Skipped render.		
		fi
		
		# Take an averaged result and subtract (diff) a diffed result from it:
		# outfileNoExt="process_hybrids/""$B_no_ext"__"$A_no_ext"__diff
		# outfile="$outfileNoExt".tif
		# if [ ! -e "$outfileNoExt"* ]
		# then
			# echo Subtracting $B from $A \/  . . .
			# idiff -fail 1 -warn 1 -abs -o $outfile image_pairs_averages/$B image_pairs_diffs/$A
		# else
			# echo ~- Target file or similarly named already exists \($outfile\). Skipped render.		
		# fi
		
		# DON'T Take a diffed result and subtract (diff) an averaged result from it, because that repeats work: it gives the same result as subtracting a diffed result from an averaged result.
	done
done