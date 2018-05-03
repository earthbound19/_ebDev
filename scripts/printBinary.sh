# DESCRIPTION
# Prints a string of the binary values of the data in the file given as parameter $1, stripping out all information besides the actual binary 0s and 1s.

# USAGE
# thisScript.sh anyFile.dat
# Or to pipe the string to a file:
# thisScript.sh anyFile.dat > anyFileBinaryReadout.txt

xxd -b $1 > tmp_28GpWnXdJtjjNKdd8CgXhCw8pxT7WB8bcQ.txt
sed 's/^[0-9a-z]*: \(.*\)  .*/\1/g' tmp_28GpWnXdJtjjNKdd8CgXhCw8pxT7WB8bcQ.txt | tr -d '\n '
rm tmp_28GpWnXdJtjjNKdd8CgXhCw8pxT7WB8bcQ.txt