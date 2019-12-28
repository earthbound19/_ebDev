import spectra

# min and max valid parameters (or components) for LCH gamut in this implementation (from what I can tell) are: l (Luminance) 0 to 100, c (Chroma--basically saturation or intensity) 0 to 100, h (Hue or color) 0 to 360; to broaden the range of colors decrease the value of the "step" variable that follows, and conversely to tighten it, increase that value--this is way more commentary than code: 
step = 7
for i in range(0, 360, step):
	this_color = spectra.lch(70, 50, i)
	print(this_color.hexcode)
