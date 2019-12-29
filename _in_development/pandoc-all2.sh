IN DEVELOPMENT. Canna seem to get this to work as intended on Windows, although swapping in literals in the find .. command (instead of parameters) _does_ work.
exit

# DESCRIPTION
# Converts all documents of type $1 (parameter 1) to type $2 via pandoc.

# USAGE
# Invoke the script with paramater 1 being the input format and paramater 2 being the output format. Example:
# ./pandoc-all2.sh docx txt

# DEPENDENCIES
# pandoc, gfind (find), a 'nix environment with exec and basename.

# re: https://stackoverflow.com/a/26304106/1397555
gfind ./ -iname "*.$1" -type f -exec sh -c 'pandoc "${0}" -o "$(basename ${0%.}.$2)"' {} \;