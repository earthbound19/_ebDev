# DESCRIPTION
# See get_simple_gamut.py. This is adapted for RGB, and the output is horrible and garish, as is RGB math.

import spectra
A_min = 0
A_max = 1
B_min = 0
B_max = 1
C_min = 0
C_max = 1

# create all possible combinations over the distribution via step_increments
# NOTE: each domain is how many thingers we want:
A_domain = 4
B_domain = 4
C_domain = 4
simplified_gamut = []
# [x/10 for x in range(0, 10)] -- that is a list comprehension to get a decimal range, re: https://stackoverflow.com/a/477513/1397555
A_range = [x/(A_max * A_domain) for x in range(A_min, (A_max * A_domain + 1))]
B_range = [x/(B_max * B_domain) for x in range(B_min, (B_max * B_domain + 1))]
C_range = [x/(C_max * C_domain) for x in range(C_min, (C_max * C_domain + 1))]
for i in A_range:
	for j in B_range:
		for k in C_range:
			this_color = spectra.rgb(i, j, k)
			print(this_color.hexcode)