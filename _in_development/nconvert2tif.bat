ECHO OFF

REM Convert an image to .tif format with the same creation date metadata as the original file.
REM This batch invokes the nconvert.exe image conversion utility, which must be in your PATH. This batch expects a parameter, being an image file name to convert to .tif 6 format. (This means that you can pass it a parameter from the command line, or by dragging and dropping a file on to this script.)
REM 04/07/2015 08:34:36 PM -RAH


SETLOCAL ENABLEDELAYEDEXPANSION

FOR %%I IN (%*) DO (
set driveletter=%%~dI
set filepath=%%~pI
set filename=%%~nxI
set filenameNoExt=%%~nI
	ECHO ================================================================================ ECHO SOURCE IMAGE IS: %%I
	IF NOT EXIST !driveletter!!filepath!!filenameNoExt!.tif (
	ECHO COMMENCE CONVERSION COMMAND . . .
	ECHO INVOKING nconvert to convert given file name to a .tif file, via command: nconvert -keepfiledate -overwrite -out tiff -o !driveletter!!filepath!!filenameNoExt!.tif %%I . . .
	nconvert -keepfiledate -overwrite -out tiff -o !driveletter!!filepath!!filenameNoExt!.tif %%I . . .
	ECHO DONE.
	) ELSE (
	ECHO ==== TARGET IMAGE FILE alrady exists; skipped conversion.
	)
)

ECHO ================================================================================ DONE. Any target files that already existed via these batch settings were ignored. Check the above output for any errors and adjust your workflow as necessary. If there were errors, and you attempt to correct for them and run this batch again, it will again attempt to conver them (and fail if errors remain). I apologize that at this writing it may produce only vague errors. You can probably ignore any message that says: "Error: Can't open file (.)" -- it still correctly converts the files; I don't know what that message is about.

ENDLOCAL

