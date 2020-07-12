# DESCRIPTION
# Reworks an ArtRage script file to export a new image after every
# "brush stroke." These may be strung together e.g. with
# ffmpegAnim.sh to create a video (animation) of the progress of
# a created painting from start to finish.

# USAGE
# Invoke via python and pass one parameter, being an ArtRage script file:
# python artRage2imgs.py inputArtRageScriptFile.arscript
# To do: describe.
# NOTES: there must be a folder named anim_frames in the path in which
# this script runs.
# To create images smaller than the original painting, when you play
# back the script untick the option to use original size (and then set
# the smaller size, e.g. 50% or screen size (if you use screen size,
# be careful to keep the W/H aspect ratio correct).

# TO DO
# - Parameterize input script file name
# - Name output script file name based on input file name
# - Handle directories. It will not just assume current directory.
# - Handle with this script in PATH instead of current dir.

# PROGRAMMER NOTES
# This works up the solution explained by ArleyArt in this thread:
# https://forums.artrage.com/archive/index.php/t-36041.html
# ~ This python script simply replaces all instances of "<StrokeEvent>"
# with that line plus an export line before it (using "\r\n" in the
# string for Windows newlines is important here). In other words:
# "<StrokeEvent>\r\n" is replaced with
# "Wait: 21.082s EvType: Command CommandID: ExportLayer Idx: -1 Channels: NO Path: \"path/to/my1.png\"\r\n<StrokeEvent>\r\n".
# NOTE: I modified that and found it works, including if you specify
#  this_dir or / as the folder. See yprf.ascript, but the command is:
# Wait: 21.082s EvType: Command CommandID: ExportLayer Idx: -1 Channels: NO Path: "./frames_anim/artRagePainting.png"
# -- and that person's logic would not export the final frame. In my
# opinion the ExportLayer command should be _after_ the closing tag of
# a StrokeEvent: </StrokeEvent>.


# CODE
import re
import os

os.chdir("D:\\Ussins\\Alex\\Art\\__ART_WORKSHOP__IN_PROGRESS\\__STAGING_from_devices\\2019-08-25__08-35-46_AM_from_iPad__sort\\snail_anim_workup")
# Figured out the encoding open by looking at encoding menu in npp, and these SO posts:
# https://stackoverflow.com/questions/18239373/python-writing-a-ucs-2-little-endian-utf-16-le-file-with-bom?lq=1
# https://stackoverflow.com/questions/5202648/adding-bom-unicode-signature-while-saving-file-in-python
f = open('Snail.arscript', mode='r', encoding='utf-16-le')
# print(f)
artScriptString = f.read()
artScriptString = re.sub('</StrokeEvent>', '</StrokeEvent>\n//SAVE IMAGE SCRIPTED INSERT via artRage2imgs.py:\nWait: 0.0s EvType: Command CommandID: ExportLayer Idx: -1 Channels: NO Path: "./anim_frames/artRagePainting_fr.png"', artScriptString)
# To avoid a silly "too many newlines" error:
artScriptString = re.sub('\n\n', '\n', artScriptString)
o = open('artRage_render.arscript', mode='w', encoding='utf-16-le')
o.write(artScriptString)
o.close()
f.close()

# Happy discovery! ARTRAGE WILL AUTO-NUMBER (INCREMENTALLY!) IMAGES if it encountered a file name conflict! Resultantly, this script is complete without having to manually code incrementing numbers! EXCEPT that the first frame (file) must be manually renamed to 0000 (or whatever)!