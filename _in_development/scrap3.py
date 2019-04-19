from itertools import product        # for permutation with repetition, re: https://stackoverflow.com/a/3100016/1397555
alphabet = [
"roller shade",
"auto roller shade",
"blind",
"auto blind",
"bridge",
"switch",
"solar panel"
]
allAlpha2perms = product(alphabet, repeat = 7)
for element in allAlpha2perms:
    print(element)

allAlpha2perms = product(alphabet, repeat = 6)
for element in allAlpha2perms:
    print(element)

allAlpha2perms = product(alphabet, repeat = 5)
for element in allAlpha2perms:
    print(element)

allAlpha2perms = product(alphabet, repeat = 4)
for element in allAlpha2perms:
    print(element)

allAlpha2perms = product(alphabet, repeat = 3)
for element in allAlpha2perms:
    print(element)

allAlpha2perms = product(alphabet, repeat = 2)
for element in allAlpha2perms:
    print(element)