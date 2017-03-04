# USAGE
# invoke with parameter $1, being the name of a true-type font file, which probably has to be in the same  name in your $PATH.

  # basic latin unicode code page ref: http://www.fileformat.info/info/unicode/block/index.htm
  # OR: http://www.fileformat.info/info/unicode/block/basic_latin/list.htm
  # extract glyphs in basic latin range:
while read -r line; do
  # NOTE: if the text file being read here must have unix line endings, else errors.
  ./ttf2eps -unicode $line $1
done < printableBasicLatinUnicode_codepages.txt

# rename resultant files after font file name.
# //using mac find; dunno whether this will work with cygwin or other 'nix environments; re: http://apple.stackexchange.com/a/1449
fontFileNameNoExt=`echo $1 | sed 's/\(.*\)\.ttf/\1/g'`
epsArray=`find . -type f -name '*.eps'`
for epsFileName in ${epsArray[@]}
do
  epsFileName=`basename "$epsFileName"`
  # mv $epsFileName "$fontFileNameNoExt"_"$epsFileName"
done

# // sort them into a folder named after the font file name.
if [ ! -d $"$fontFileNameNoExt"_glyphs ]
then
  mkdir "$fontFileNameNoExt"_glyphs
fi

mv *.eps ./"$fontFileNameNoExt"_glyphs
