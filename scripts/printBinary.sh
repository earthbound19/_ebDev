# DESCRIPTION
# Prints a string of the binary values of the data in file $1.

# DEPENDENCIES
#    xxd

# USAGE
# Run with these parameters:
# - $1 input file name
# For example:
#    printBinary.sh anyFile.dat
# Or to pipe the print to a file:
#    printBinary.sh anyFile.dat > anyFileBinaryReadout.txt


# CODE
xxd -b $1 > tmp_28GpWnXdJtjjNKdd8CgXhCw8pxT7WB8bcQ.txt
sed 's/^[0-9a-z]*: \(.*\)  .*/\1/g' tmp_28GpWnXdJtjjNKdd8CgXhCw8pxT7WB8bcQ.txt | tr -d '\n '
rm tmp_28GpWnXdJtjjNKdd8CgXhCw8pxT7WB8bcQ.txt