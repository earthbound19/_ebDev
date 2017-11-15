# DESCRIPTION
# Indexes all text files in a directory tree with a file name of pattern _EXPORTED_.*_MD_ADDS (case-sensitive). Such file names which contain the string:
# -EXIF:ImageHistory=".*First publication.*
# -- will be written to _publishedFinalWorks.txt, BY OVERWRITE (the file contents will be replaced). Such file names which do *not* contain that string will be written to _unpublishedFinalWorks.txt, also by overwrite.
# These files are reference for publishing my art work (determining what to publish next).

labelOne=_EXPORTED_

# List all files matching desired pattern and write them to temp file
gfind . -regex .*_EXPORTED_.*_MD_ADDS.txt -type f > _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt

while read element
do
	element=`echo $element | gsed 's/..\(.*\)/\1/g'`
		# stupid workaround for gsed producing windows line endings:
		echo $element > glorp_tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt
		dos2unix -q glorp_tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt
		element=$(<glorp_tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt)
	echo
	echo checking element $element . .
	grep public $element
	echo errorlevel is $?
	echo 0 means match found\, 1 means no match found
done < _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt



