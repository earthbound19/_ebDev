from itertools import product        # for permutation with repetition, re: https://stackoverflow.com/a/3100016/1397555
alphabet = [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ]

# allAlpha2perms = product(alphabet, repeat = 7)
# for element in allAlpha2perms:
    # print(element)

# allAlpha2perms = product(alphabet, repeat = 6)
# for element in allAlpha2perms:
    # print(element)

# allAlpha2perms = product(alphabet, repeat = 5)
# for element in allAlpha2perms:
    # print(element)

allAlpha2perms = product(alphabet, repeat = 4)
listAllAlpha2Perms = list(allAlpha2perms)
len(listAllAlpha2Perms)
# THAT GIVES: 50,625 possible combinations allowing repetition from a set of 16 characters, selecting 4.
# If one combination is displayed every second, it will take ~14 hours to display them all; re:
# https://www.wolframalpha.com/input/?i=50625+seconds+in+hours

# allAlpha2perms = product(alphabet, repeat = 3)
# for element in allAlpha2perms:
    # print(element)

# allAlpha2perms = product(alphabet, repeat = 2)
# for element in allAlpha2perms:
    # print(element)