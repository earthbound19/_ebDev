# DESCRIPTION
# Finds all files of type $1 (parameter 1), sorts them by date
# (oldest first), then runs cat against each. Meow.

# USAGE
# Invoke with one parameter, being a filetpe (or anything else
# gfind can use), without any . before the extension (for example
# just txt) to pass repeatedly to cat (sorted by creation date
# descending), for example:
#  catByDate.sh txt
# To pipe the output to a new file, invoke thusly:
#  catByDate.sh hexplt > all_palettes.hexplt


# CODE
array=(`gfind . -name "*.$1" -print0 -printf "%T@ %Tc %p\n" | gsort -n -r | sed 's/.*[AM|PM] \.\/\(.*\)/\1/g'`)
for element in ${array[@]}
do
	cat $element
done