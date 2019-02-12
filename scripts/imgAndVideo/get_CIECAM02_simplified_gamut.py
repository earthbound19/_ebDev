# DESCRIPTION
# Creates a list of colors expressed as components OR RGB hexadecimal values, from a simplified CIECAM02 color space. Capture the list with the > operator via terminal (see USAGE).

# USAGE
# python get_CIECAM02_simplified_gamut.py > CIECAM02_simplified_gamut.gamut

# DEPENDENCIES
# ..?

# PROGRAMMER NOTES
# This page -- https://colorspacious.readthedocs.io/en/latest/tutorial.html -- describes a gamut in HCL (actually Jcl there) which is "state of the art:" CIECAM02. Supported as such by chronology in this article: https://en.wikipedia.org/wiki/Color_appearance_model#CIECAM02 Excellent article about it describing well different attributes of color and colorfulness: https://en.wikipedia.org/wiki/CIECAM02
# Packages that support it:
# - https://colorspacious.readthedocs.io/en/latest/reference.html#supported-colorspaces
# - https://colour.readthedocs.io/en/latest/colour.appearance.html#ciecam02
# - winner if it works: https://colorspacious.readthedocs.io/en/latest/reference.html#ciecam02 : "If you just want a better replacement for traditional ad hoc spaces like “Hue/Saturation/Value”, then use the string "JCh" for your colorspace (see Perceptual transformations for a tutorial) and be happy."

A_min = 0
A_max = 100
A_step = int(100 / 18)

B_min = 0
B_max = 182
B_step = int(182 / 24)

C_min = 0
C_max = 360
C_step = int(360 / 7)

# Stepping (counting) down because it's difficult (or with this code depending, impossible) to hit the max ranges counting up:
simplified_gamut = []
for i in range(C_max, C_min, -C_step):
	for j in range(A_max, A_min, -A_step):
		for k in range(B_max, B_min, -B_step):
			this_color = spectra.lch(j, k, i)
			simplified_gamut.append(this_color.hexcode)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
# -- or TO DO--this without importing another library, re: https://thispointer.com/python-how-to-remove-duplicates-from-a-list/
from more_itertools import unique_everseen
simplified_gamut = list(unique_everseen(simplified_gamut))


# WIP: DELETE COLORS WHICH ARE SO SIMILAR as to be practically the same.., via colormath (to reduce the list further) :
#list_len = len(simplified_gamut)
#print("list_len val:", list_len)
#for outer_idx in range(list_len -1, 0, -1):
#	for inner_idx in range(outer_idx-1, 0, -1):


for element in simplified_gamut:
	print(element)


# Write lists of all two-and-three pairs from reduced gamut:
# import string
# import itertools
# all_two_permutations = list(itertools.permutations(simplified_gamut, 2))
# outfile = open('all_gamut_two_pairs.txt', 'w')
# 
# for i in all_two_permutations:
# 	outfile.write(i[0] +"," + i[1] +'\n')
# outfile.close()

# all_three_permutations = list(itertools.permutations(simplified_gamut, 3))
# outfile = open('all_gamut_three_pairs.txt', 'w')
# 
# for i in all_three_permutations:
# 	outfile.write(i[0] +i[1] +i[2] +'\n')
# outfile.close()