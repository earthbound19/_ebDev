# USAGE
# pass one parameter, being another path. All files in that other path will be deleted which have a duplicate file name in the current path, PERMAENENTLY AND WITHOUT WARNING. You must comment out the echo line and uncomment the delete line in this code for this to happen, though.

filesHere=(`gfind . -maxdepth 1 -type f -iname \*.* -printf '%f\n'`)

for element in "${filesHere[@]}"
do
  echo "COMMAND WOULD BE: $1/$element"
  # rm $1/$element
done