# reading: https://docs.python.org/3.1/library/itertools.html

# eh, way over my head: https://docs.python.org/2/library/functions.html#max

# import string
import itertools
all_hardchars = (['b','c','d','f','g','h','j','k','l','m','n','p','q','r','s','t','v','w','x','y','z']) 
four_hardchars_allpermutations = list(itertools.permutations(all_hardchars, 4))
outfile = open('all_hardchars_four_permutations.txt', 'w')
# !!
for i in four_hardchars_allpermutations:
	outfile.write(i[0] +i[1]  +i[2]  +i[3] +'\n')
outfile.close()