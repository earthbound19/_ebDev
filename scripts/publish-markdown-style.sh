# DESCRIPTION
# A wrapper for markdown-styles (generate-md) to create an HTML publication from a source *.md file. Writes result files to a ./output folder. WARNING: this deletes and recreates the ./output folder when run.

# USAGE
# Invoke this with one parameter, being the input *.md file to create an HTML publication from, e.g.:
# ./thisScript.sh inputFile.md

# DEPENDENCES
# Nodejs with markdown-styles (generate-md) installed, and an *.md file to convert.


# CODE
generate-md --lagenerate-md --layout witex-invert --input ./$1

# Dirty hack; copy necessary images (change the *.extension list for your needs) into the ./output folder:
# cp *.gif ./output

# OPTIONAL; launch result index.html file in default html viewer (cygwin--for Mac, change `cygstart` to `open`):
srcFileNoExt=`echo $1 | sed 's/\(.*\)\..\{1,4\}/\1/g'`
cygstart ./output/$srcFileNoExt.html