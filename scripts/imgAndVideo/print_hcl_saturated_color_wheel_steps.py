# DESCRIPTION
# Prints RGB hex code values (in format #dddddd) for colors in hue (LCH) steps of N, from 0 to 360 (N is hard-coded to 7; hack the script to change that), via spectra library. Luminance and Chroma are hard-coded to 70 (of 100) and 50 (of 100); also hack the script to alter those.


# CODE
import spectra

# min and max valid parameters (or components) for LCH gamut in this implementation (from what I can tell) are: l (Luminance) 0 to 100, c (Chroma--basically saturation or intensity) 0 to 100, h (Hue or color) 0 to 360; to broaden the range of colors decrease the value of the "step" variable that follows, and conversely to tighten it, increase that value: 
step = 51
for i in range(0, 360, step):
	this_color = spectra.lch(70, 50, i)
	print(this_color.hexcode)
