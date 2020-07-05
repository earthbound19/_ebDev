# DESCRIPTION
# Optimizes all svg files in the current directory (writing result to
# <originalFileName>_scoured.svg) via python scour script.

# DEPENDENCIES
# Python with scour installed and in your PATH: pip install scour

# USAGE
# From a path with svg files you wish to optimize and clean up, run this script:
# svg_scour_all.sh

array=(`find . -maxdepth 1 -type f -iname \*.svg -printf '%f\n'`)
for element in ${array[@]}
do
  fileNameNoExt=${element%.*}
  scour -i "$element" -o "$fileNameNoExt"_scoured.svg --enable-id-stripping --enable-comment-stripping --shorten-ids
done