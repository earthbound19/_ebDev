# WARNING: this script has no safeguard. Back up whatever images this would destroy before invoking this script!

# DESCRIPTION
# Overwrites all images of a given type $1 (in the directory you invoke this script from) with a text render of an arbitrary phrase and a number count of which image in the list has been written to.

# DEPENDENCIES
# run these commands on a Mac with homebrew installed:
# brew install graphicsmagick
# brew install ghostscript
# ALTERNATE POSSIBILITY; re: https://gist.github.com/oalders/1355751#gistcomment-62636
# brew install --use-gcc --with-perlmagick graphicsmagick

# USAGE
# call this script from the terminal to thusly destroy so many images thusly, e.g.:
# ./thisScript.sh png "SET A"
# To have global use of it, copy this script to somewhere in your $PATH, or make such a path.

# CODE

count=0

find *.$1 > tmp_lst.txt

while read listItem
do
  count=$(($count + 1))
  tmp=`gm identify $listItem`
  xPix=`echo $tmp | sed 's/.*PNG \([0-9]\{1,\}\).*/\1/'`
  # echo xPix is $xPix
  yPix=`echo $tmp | sed 's/.*PNG [0-9]\{1,\}x\([0-9]\{1,\}\).*/\1/'`
  # echo yPix is $yPix
  gm convert -size "$xPix"x"$yPix" -font Helvetica label:"$2 $count" $listItem
done < tmp_lst.txt

rm ./tmp_lst.txt
