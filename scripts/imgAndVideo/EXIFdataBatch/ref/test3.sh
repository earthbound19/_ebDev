# gsed 's/["]//g' tests.txt
# tr '\t' ' ' < tests.txt
# tr '\n' ' _ ' < tests.txt
# pilcrow in utf8: c2 b6--or you can simply copy it from somewhere and paste it: ¶
# Or use a middle dot: ·
# degree sign: °


# TO DO; COPY THIS REF. URL TO GNU DOC.: http://stackoverflow.com/a/12675993
# filename=_FINAL_9083271807_55e09829e5_t_jpg_FF.lib_4938_1_ffxml_pre2.tiff
# echo ist $filename
# fileExt=`echo "$filename" | gsed 's/.*\(\..\{1,4\}\)\$/\1/g'`
# echo $fileExt

echo was > test.txt
foo=$( < floofy_floo.txt )
gsed "s/was/$foo/g" test.txt