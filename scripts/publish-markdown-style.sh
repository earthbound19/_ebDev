# DESCRIPTION
# A wrapper for markdown-styles (generate-md) to create an HTML publication from a source *.md file. Writes result files to a ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm folder. WARNING: this deletes and recreates the ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm folder when run.

# USAGE
# Invoke this with one parameter, being the input *.md file to create an HTML publication from, e.g.:
# ./thisScript.sh inputFile.md

# DEPENDENCES
# Nodejs with markdown-styles (generate-md) installed, my custom witex-invert style installed to that (copy from my source folder for that (find it..TO DO: archive that somewhere public) into summat node_modules/markdown-styles/layouts), and an *.md file to convert.


# CODE
# Note the publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm folder with a random string in the name: THIS MAY BE CONSISTENTLY REFERENCED from other scripts; the random string is to avoid clobbering any pre-existing ./output folder (./output being generate-md's default output folder) :
generate-md --lagenerate-md --layout witex-invert --input ./$1 --output ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm

# Dirty hack; copy necessary images (change the *.extension list for your needs) into the ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm folder:
# cp *.gif ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm

# OPTIONAL; launch result index.html file in default html viewer (cygwin--for Mac, change `cygstart` to `open`) ; NOTE that if the next two lines are uncommented it may break the file move code lines at the end of MD_ADDS2md.sh:
# srcFileNoExt=`echo $1 | sed 's/\(.*\)\..\{1,4\}/\1/g'`
# cygstart ./publish_markdown_tmp_qJtm3M8rGBpm2Q2WX5d4bKCm/$srcFileNoExt.html