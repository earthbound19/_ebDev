find . -iname *.sh > _all_sh_files.txt

mapfile -t all_shArray < _all_sh_files.txt

for element in "${all_shArray[@]}"
do
	# echo elm is $element
	dos2unix.exe -u --oldfile -D utf8 $element
done