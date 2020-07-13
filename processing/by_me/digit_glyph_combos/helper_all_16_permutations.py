# DESCRIPTION
# writes all possible combinations of four base-16 digits (allowing repetition of digits) to all16products.txt.

# CODE
import itertools # for permutation with repetition
digits = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ]
# digits = [ "A", "B", "C", "D" ]

all16perms = itertools.product(digits, repeat = 4)

f = open("all16products.txt", "w")
for element in all16perms:
	tmpStr = ''.join(element)
	f.write(tmpStr + "\n")

f.close()