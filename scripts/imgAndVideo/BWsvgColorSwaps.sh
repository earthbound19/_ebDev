# DESCRIPTION
# Allows quick workup of many color pair options for designs. Swaps the first and last color (line) from every `.hexplt` file in the current directory (optional: also subdirectories) into copies of `SVG` file $1, named after the `SVG` and `.hexplt` file. The files are in a subdirectory named `<SVG_file_base_name>_colorOptions`.

# USAGE
# From a directory with `.hexplt` files in it, run with:
# - $1 `SVG` file name which you want to create SVG variant files with color options for.
# For example:
#    BWsvgColorSwaps.sh design.svg


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (SVG file name) passed to script. Exit."; exit 1; else srcSVG=$1; fi
# If no parameter two, maxdepthParameter will be left at default, which causes find to search only the current directory:
maxdepthParameter='-maxdepth 1'
# But if parameter two is passed to script, that changes to maxdepthParameter nothing, and find's default recursive search will be used (as no maxdepth switch will be passed) :
if [ "$1" ]; then maxdepthParameter=''; fi
srcSVGnoExt=${srcSVG%.*}
SVG_colorSwapsSubdirName="$srcSVGnoExt"_colorSwaps

# wipe rendered options dir if it exists:
if [ -d $SVG_colorSwapsSubdirName ]; then rm -rf $SVG_colorSwapsSubdirName; fi
# recreate it if it doesn't exist:
if [ ! -d $SVG_colorSwapsSubdirName ]; then mkdir $SVG_colorSwapsSubdirName; fi

hexplts=($(find . $maxdepthParameter -type f -iname \*.hexplt -printf "%P\n"))
for hexpltFileName in ${hexplts[@]}
do
	colorOne=$(sed -n '1p' $hexpltFileName)
	colorTwo=$(sed -n '$p' $hexpltFileName)
	echo ""
	echo $hexpltFileName colorOne is $colorOne
	echo $hexpltFileName colorTwo is $colorTwo
	hexpltFileNameNoExt=${hexpltFileName%.*}
# ==== BEGIN RENDER OPTION A: colorOne, colorTwo ====
# HACK HERE: target file name template A:
	# targetFileA="svg_opts/color_growth_logo_opt_""$hexpltFileNameNoExt"_A.svg
	
	targetFileA="$SVG_colorSwapsSubdirName/$srcSVGnoExt"__"$hexpltFileNameNoExt"_AB.svg
	echo "Creating target file $targetFileA . . ."
	# copy src file to target to enable sed text repl. operations for it:
	cp -f $srcSVG $targetFileA
# REPLACE BLACK with colorOne; note that the variable includes "#" so no need to put that:
	sed -i "s/fill=\"#000000\"/fill=\"$colorOne\"/" $targetFileA
# REPLACE WHITE with colorTwo:
	sed -i "s/fill=\"#ffffff\"/fill=\"$colorTwo\"/" $targetFileA
# ==== END RENDER OPTION A: colorOne, colorTwo ====
# -~-~
# ==== BEGIN RENDER OPTION B: colorOne, colorTwo ====
# HACK HERE: target file name template A:
	targetFileB="$SVG_colorSwapsSubdirName/$srcSVGnoExt"__"$hexpltFileNameNoExt"_BA.svg
	echo "Creating target file $targetFileB . . ."
	# copy src file to target to enable sed text repl. operations for it:
	cp -f $srcSVG $targetFileB
# REPLACE BLACK with colorOne:
	sed -i "s/fill=\"#000000\"/fill=\"$colorTwo\"/" $targetFileB
# REPLACE WHITE with colorTwo:
	sed -i "s/fill=\"#ffffff\"/fill=\"$colorOne\"/" $targetFileB
# ==== END RENDER OPTION B: colorOne, colorTwo ====
done