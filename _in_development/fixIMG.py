# DESCRIPTION
# Opens all files of a given type (parameter) via Python's PIL image library and re-saves them, only adding _repaired to the end of the file base name.

# TO DO
# Save to arbitrary type parameterically (necessarily convert beforehand)
# Fix arbitrary image type parametrically
# TRY AND POSSIBLY ADAPT or mix into the below--I think it just needs a save step added; RE: https://stackoverflow.com/a/20068394/1397555
# if img and img.meta_type == 'Image':
    # pilImg = PIL.Image.open( StringIO(str(img.data)) )
# elif imgData:
    # pilImg = PIL.Image.open( StringIO(imgData) )
# try:
    # pilImg.load()
# except IOError:
    # pass # You can always log it to logger
# pilImg.thumbnail((width, height), PIL.Image.ANTIALIAS)


# CODE
from os import listdir
from os import path
from PIL import Image, ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True

for filename in listdir('./'):
	if filename.endswith('.png'):
		print('Examining file ', filename)
		try:
			img = Image.open('./'+filename)
			# img.verify()		# verify that it is, in fact an image
		except (IOError, SyntaxError) as e:
			# print borken files. re: https://opensource.com/article/17/2/python-tricks-artists
			print('Could not open file:', filename)
		# If that "try:" test passes:
		print('Attempting to save new version of image . . .')
		base_file_name = path.splitext(filename)[-0].lower()
		# fileExtension = path.splitext(filename)[-1].lower()		# I think
		file_out = base_file_name + "_repaired.png"
		img.save(file_out)