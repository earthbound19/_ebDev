# DESCRIPTION: exifDataBatch is a toolset for Windows to easily generate text files accompanying images, from which new metadata will be inserted or updated into the images. There is also a batch to backup all desired image metadata in exiftool .xml files (archiveMetadata.sh, for maximum data preservation and best ease of restoration).

# USAGE
First, ALWAYS use this toolset on copies of images, not originals! Things can go wrong adding metadata, and if they do, you want it to happen on a disposable file, not your originals!

# TO DO
Update / integrate this documentation. oldversions\_callCreateImageTags.bat may have comments/output worth copying; also from this file.

This toolset requires exiftool (a free utility) to be in your %PATH%; you may need to download and install it.

To use this toolset:

1) Drag and drop images on to _callCreateImageTags.bat and follow the prompts. It calls other batch files, so that this happens:
 A) It creates a subfolder __originalImageMetaData in the same directory as any image which you dragged on to this batch file. In that folder, it creates exiftool .xml archives of the original metadata from the image(s). If there were already .xml metadata archives for the image(s), it leaves them alone.
 B) By way of prepNewMetaData.sh (which replaces customImageMetaDataPrePrep.bat): . . .
 DEPRECATED:
	B) (EXCEPT IT DOESN'T--I think customImageMetaDataPrePrep.bat does now) It creates metadata population text files in a __metadataAdditions subfolder. The .txt filenames in that folder each correspond to the image(s) passed to this batch. You may then add or edit desired metadata in those text files as necessary, and then save those files.
2) With the metadata prepared for insertion into images, drag and drop the same image files on to customImageMetadataPopulate.bat. If all goes well, it will display only messages about updating images. 

NOTE: It will automatically open so many text files as it creates, for you to edit, save and close. If you drag a lot of images on to the _callCreateImageTags.bat file, be prepared for a lot of new text file windows or tabs :)

IMPORTANT NOTE: Despite what the below document says, this only seems to work as expected if you copy your image files to the same directory as this toolset, and then open a console and run a command such as this:

_callCreateImageTags.bat *.tif *.png *.jpg

Sorry about that. I hope to eventually find a fix.

You can verify changed or added metadata resulting from this process bunniesy by opening a command prompt and typing:

exiftool <image file name>

It will print text to the console in which you will see the new or modified metadata.

----
NO, the following does not work; I want to debug to learn why:

You can execute this from the console, passing multiple different image file types to it all at once, by adding this distribution folder's path to your %PATH% environment variable, and, from the directory with images, running the command:

_callCreateImageTags.bat *.tif *.png *.jpg

For my workflow, I export from archival source files (for example Open Raster .ora files or .psd files) to final export .tif or .png files (I may prefer .tif), with the prefix _final_ in the exported (as also the source archive) file names. I then prepare their metadata with the following command, via this toolset:

_callCreateImageTags.bat _final_*.tif _final_*.png _final_*.jpg


----
TO DO:
Get drag-and-drop working.
Get invocation from another directory (via console), with this toolset in your %PATH%, working.
	First guess of cause: full paths not getting input correctly when invoked from another folder.


VERSION HISTORY
09/04/2015 12:21:17 AM v0.9 INITIAL RELEASE -RAH
12/30/2015 08:42:59 PM v0.95 I sincerely don't remember if the initial release worked, but I found it buggy; maybe I lost it and was working from an old backup. Fixed/coded to have essential functionality. -RAH
03/12/2016 04:02:39 PM Uh, if I did get that working, I don't know how. This is a wreck. -RAH