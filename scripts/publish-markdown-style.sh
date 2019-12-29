# DESCRIPTION
# A wrapper for markdown-styles (generate-md) to create an HTML publication from a source *.md file. Writes result files to a ./_publish_MD_tmp_qJt5d4bKCm folder. WARNING: this deletes and recreates the ./_publish_MD_tmp_qJt5d4bKCm folder when run.

# USAGE
# Invoke this with one parameter, being the input *.md file to create an HTML publication from, e.g.:
# ./thisScript.sh inputFile.md

# DEPENDENCES
# Nodejs with markdown-styles (generate-md) installed, my custom witex-invert style installed to that (copy from my source folder for that (find it..TO DO: archive that somewhere public) into summat node_modules/markdown-styles/layouts), and an *.md file to convert.


# CODE
# Note the _publish_MD_tmp_qJt5d4bKCm folder with a random string in the name: THIS MAY BE CONSISTENTLY REFERENCED from other scripts; the random string is to avoid clobbering any pre-existing ./output folder (./output being generate-md's default output folder) :

# CHOOSE A LAYOUT and comment out the other options:
# layoutString=witex-invert   # That's a custom tweak I made, not published at this writing
layoutString=jasonm23-dark
generate-md --lagenerate-md --layout $layoutString --input ./$1 --output ./_publish_MD_tmp_qJt5d4bKCm

# Dirty hack; copy necessary images (change the *.extension list for your needs) into the ./_publish_MD_tmp_qJt5d4bKCm folder:
# cp *.gif ./_publish_MD_tmp_qJt5d4bKCm

# OPTIONAL; launch result index.html file in default html viewer (cygwin--for Mac, change `cygstart` to `open`) ; NOTE that if the next two lines are uncommented it may break the file move code lines at the end of MD_ADDS2md.sh:
# srcFileNoExt=`echo $1 | gsed 's/\(.*\)\..\{1,4\}/\1/g'`
# cygstart ./_publish_MD_tmp_qJt5d4bKCm/$srcFileNoExt.html
