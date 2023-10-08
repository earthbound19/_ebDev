# DESCRIPTION
# Reworks an ArtRage script file to export a new image after every brush stroke. These may be strung together e.g. with ffmpegAnim.sh to create a video (animation) of the progress of a created painting from start to finish.

# USAGE
# - Create an ArtRage painting with the macro record option set (File menu > Record Script...), and stop the script recording and save the result to a new file (`.arscript` extension).
# - Use this script with that script, this way: run via python and pass one parameter, which is the ArtRage script file, e.g.:
#    python /path/to_this_script/artRage2imgs.py inputArtRageScriptFile.arscript
# - This script will create a new animation save frames script named <original_file_basename>__artRage_render_<six_random_characters>.arscript. Create a subfolder named anim_frames in the same directory as that script, and then play back that new animation save frames script in ArtRage (File menu > Play Script...). It will save a new animation frame image for every brush stroke in the script.
# - You may then string those images together in an animation e.g. with ffmpegAnim.sh, or do whatever else you might want to do with the animation frames.
# NOTES
# - ArtRage will incrementally auto-number images if it encounters a file name conflict involving a four-digit number! Resultantly, this script is complete without having to manually code incremented numbers, by hard-coding the output file name to be 0000.png.
# - There must be a folder named anim_frames in the path in which this script runs for ArtRage to successfully save animation frames when it plays back the script.
# - To create images smaller than the original painting, when you play back the script untick the option to use original size (and then set the smaller size, e.g. 50% or screen size (if you use screen size, be careful to keep the W/H aspect ratio correct).
# WISH LIST
# Option to save a new animation frame after every sub-brush stroke (strokes are composed of multiple shorter strokes, logically, in a script), if that's even possible.


# CODE
#
# TO DO
# - Better describe script in comments
# - Parameterize input script file name
# - Name output script file name based on input file name
# - Handle directories. It will not just assume current directory.
# - Handle with this script in PATH instead of current dir.

# DEVELOPER NOTES
# This works up the solution explained by ArleyArt in this thread:
# https://forums.artrage.com/archive/index.php/t-36041.html
# ~ This python script simply replaces all instances of "<StrokeEvent>"
# with that line plus an export line before it (using "\r\n" in the
# string for Windows newlines is important here). In other words:
# "<StrokeEvent>\r\n" is replaced with
# "Wait: 21.082s EvType: Command CommandID: ExportLayer Idx: -1 Channels: NO Path: \"path/to/my1.png\"\r\n<StrokeEvent>\r\n".
# NOTE: I modified that and found it works, including if you specify
#    this_dir
# or
#    /
# -- as the folder. See yprf.ascript, but the command is:
# Wait: 21.082s EvType: Command CommandID: ExportLayer Idx: -1 Channels: NO Path: "./frames_anim/artRagePainting.png"
# -- and that person's logic would not export the final frame. In my
# opinion the ExportLayer command should be _after_ the closing tag of
# a StrokeEvent: </StrokeEvent>.
import re, sys
from pathlib import Path
import random, string

# Figured out the encoding open by looking at encoding menu in npp, and these SO posts:
# https://stackoverflow.com/questions/18239373/python-writing-a-ucs-2-little-endian-utf-16-le-file-with-bom?lq=1
# https://stackoverflow.com/questions/5202648/adding-bom-Unicode-signature-while-saving-file-in-python
f = open(sys.argv[1], mode='r', encoding='utf-16-le')
# print(f)
artScriptString = f.read()
artScriptString = re.sub('</StrokeEvent>', '</StrokeEvent>\n//script hack insert: save image:\nWait: 0.0s EvType: Command CommandID: ExportLayer Idx: -1 Channels: NO Path: "./anim_frames/0000.png"', artScriptString)
# To avoid a silly "too many newlines" error:
artScriptString = re.sub('\n\n', '\n', artScriptString)
# construct output file name:
inputFileBaseName = Path(sys.argv[1]).stem
rndStr = ''.join(random.choices(string.ascii_letters + string.digits, k=6))
outputFileName = inputFileBaseName + '__artRage_render_' + rndStr + '.arscript'
o = open(outputFileName, mode='w', encoding='utf-16-le')
o.write(artScriptString)
o.close()
f.close()

print("DONE. Wrote result to:")
print(outputFileName)
print("--NOTE! Before you play back that script, you will want to make a subfolder named anim_frames in the same directory as it.")