:: DESCRIPTION
:: Updates or creates `all_originalMetaData.7z` with metadata `.xmp` sidecars from `_originalMetaData` folders.

:: USAGE
:: Before you run this script, run `archiveMetadata.sh`. Then run this without any parameter, at any time you want to update the metadata archive:
::    imgMetaDataTo7z
:: NOTES
:: - Because I may want to keep metadata for files when they were first finalized, or as they are when incorporated into other works, for record keeping in case I need to track down information about any image file, this script exists.
:: - This batch is intended to be called after `archiveMetadata.sh`.
:: - This adds all metadata `.xmp` sidecars in folders with `_originalMetaData` in their name (and their subfolders) to an `all_originalMetaData.7z` archive, *without* overwriting `.xmp` sidecars that already exist in the archive (or, preserving already existing `.xmp` sidecars). In the case of `.xmp` sidecars which are in a path, but which are not in the `.7z` archive, they will be added to the `.7z` archive.
:: - To update an `.xmp` sidecar in the archive, you would then first manually delete it from the archive; the newer/modified version of the sidecar on disk (in a path) will then be re-added to the `.7z` archive. What are `.xmp` sidecars? They archive metadata from associated image (and video!) files.


:: CODE
:: TO DO: Make that script and this the same script, updating the archive if it exists, and creating it if it does not?
:: Relevant from 7za help:
:: Usage: 7za <command> [<switches>...] <archive_name> [<file_names>...]
:: Commands:
:: a : Add files to archive
:: Exactly the archive command options I need (a -up1q1r2x1y1z1w1) found thanks to: http://stackoverflow.com/a/19676682/1397555
:: Switches:
:: -i[r[-|0]]{@listfile|!wildcard} : Include filenames
:: -spf : use fully qualified file paths (creates folders mirroring the full path to files in the archive).

:: The code, already! :) :

DIR /b /s *_originalMetaData* > XMPsToArchive.txt
7za a -up1q1r2x1y1z1w1 -spf -ir@XMPsToArchive.txt all_originalMetaData.7z
REM RMDIR /S /Q _originalMetaData
echo DONE. Archive is in all_originalMetaData.7z. Check it against the _originalMetaData subdirectory, and if they match, you may delete that directory, as it is archived.

:: TO DO: code option to nuke all those _originalMetaData folders after they're archived to .7z files.

:: ## VERSION HISTORY
:: 01/10/2016 12:39:39 AM v0.9.9 created. -RAH