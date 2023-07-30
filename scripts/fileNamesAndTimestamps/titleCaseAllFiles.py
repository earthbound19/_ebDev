# source: https://askubuntu.com/a/589324
# brilliant but doesn't filter by file type per my need.
import os
import sys
import shutil

directory = sys.argv[1]

skip = ["a", "an", "the", "and", "but", "or", "nor", "at", "by", "for", "from", "in", "into", "of", "off", "on", "onto", "out", "over", "to", "up", "with", "as"]
replace = [["(", "["], [")", "]"], ["{", "["], ["}", "]"]]
def exclude_words(name):
    for item in skip:
        name = name.replace(" "+item.title()+" ", " "+item.lower()+" ")
    # on request of OP, added a replace option for parethesis etc.
    for item in replace:
        name = name.replace(item[0], item[1])
    return name

for root, dirs, files in os.walk(directory):
    for f in files:
        split = f.find(".")
        if split not in (0, -1):
            name = ("").join((f[:split].lower().title(), f[split:].lower()))
        else:
            name = f.lower().title()
        name = exclude_words(name)
        shutil.move(root+"/"+f, root+"/"+name)
for root, dirs, files in os.walk(directory):
    for dr in dirs:
        name = dr.lower().title()
        name = exclude_words(name)
        shutil.move(root+"/"+dr, root+"/"+name)