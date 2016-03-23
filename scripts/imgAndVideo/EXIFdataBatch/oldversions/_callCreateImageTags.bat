ECHO OFF
CLS
REM ECHO =============WARNING!=========================================================== ONLY PASS COPIES of images to this batch file--make sure the images are backed up somewhere else first, because if something goes wrong adding metadata via this batch, you might hose your only copies of those images. ALWAYS run this batch on a copy of images, not originals. If you acknowledge this, press any key. ================================================================================
REM PAUSE

FOR %%X IN (%*) DO (
REM CALL _createImageTags.bat %%X
REM TO DO: make sure the following archives metadata from an image *only* if such an archive file does not already exist; if such a file already exists, leave it alone.
REM Re: http://www.sno.phy.queensu.ca/~phil/exiftool/metafiles.html
REM Create XMP (metadata) sidecar file in a subdirectory:
REM NOTE that in the following, where in DOS batch it would be just %%X, since we are passing it to no maybe that doesn't make sense but for some reason each percent sign has to be escaped %%, resulting in %%%%X. NO, for mystical reasons that must be three %%%, not four.

exiftool -o _originalMetaData\%%f.xmp -r %%%X

REM single file variant (e.g. to use by passing a parameter to this script):
REM exiftool -o originalMetaData\%f.xmp file.tif
)

ECHO =============NOTE=============================================================== This batch should have created a subfolder __originalImageMetaData in the same directory as any image which you drag on to this batch file. In that folder, I created exiftool .xml archives for the image(s). If there were already .xml metadata archives for any image(s), I left them alone. I strongly recommend that you compress that folder into a .7z or .zip archive for safekeeping of your original metadata, which can be restored to the images. __ You see that I have also created some metadata population text files in a __metadataAdditions subfolder. Note that the .txt filenames in that folder each correspond to the image(s) passed to this batch. Add or edit desired metadata in those text files as necessary, and then save those files. __ In the next step, all this metadata will be written to the corresponding image files. To execute the next step, drag and drop the same image files on to customImageMetadataPopulate.bat.