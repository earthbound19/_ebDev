REM # DESCRIPTION
REM Archive, to all_originalMetaData.7z, all metadata *.xmp sidecars in a path (including all subdirs), *without* overwriting .xmp sidecars that already exist in the archive (or, preserving already existing .xmp sidecars). In the case of .xmp sidecars which are in a path, but which are not in the .7z archive, they will be added to the .7z archive. NOTES: to update a .xmp sidecar in the archive, you would then first manually delete it from the archive; the newer/modified version of the sidecar on disk (in a path) will then be re-added to the .7z archive. What are .xmp sidecars? They archive metadata from associated image (and video!) files.

REM # DETAILS AND USAGE
REM Why? Because I want to keep metadata for files when they were first finalized, or as they are when incorporated into other works, for recordkeeping in case I need to track down information about any image file.
REM This batch is intended to be called after archiveMetadata.sh.

REM Relevant from 7za help:
REM Usage: 7za <command> [<switches>...] <archive_name> [<file_names>...]
REM Commands:
REM a : Add files to archive
REM Exactly the archive command options I need (a -up1q1r2x1y1z1w1) found thanks to: http://stackoverflow.com/a/19676682/1397555
REM Switches:
REM -i[r[-|0]]{@listfile|!wildcard} : Include filenames
REM -spf : use fully qualified file paths (creates folders mirroring the full path to files in the archive).

REM The code, already! :) :

DIR /b /s *_originalMetaData* > XMPsToArchive.txt
7za a -up1q1r2x1y1z1w1 -spf -ir@XMPsToArchive.txt all_originalMetaData.7z

REM TO DO: code option to nuke all those _originalMetaData folders after they're archived to .7z files.

REM ## VERSION HISTORY
REM 01/10/2016 12:39:39 AM v0.9.9 created. -RAH