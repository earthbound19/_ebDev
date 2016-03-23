REM move all files of the given extension(s) (as may be passed to this script) into subdirectories named after each files' name.

ECHO ~
ECHO USAGE:
ECHO =============
ECHO Whichever directory you call this batch from, it will create subdirectories named after every one of the file type extensions you specify; then move those files respectively into those subdirectories. For example, if you call this script with <tosubdirs ttf>, it will create subdirectories named after every .ttf file in the directory, and then move those ttf files into those directories (of matching name).

ECHO OFF

IF '%1' equ '' ECHO NO PARAMETER passed to script. Terminating. && GOTO END

IF '%1' neq '' SET /p 1=If you don't intend to do this for file type %1, close this terminal, or press CTRL+C. If you DO intend to do this for file type %1, press ENTER.

SETLOCAL ENABLEDELAYEDEXPANSION

FOR /f "tokens=* delims= " %%F IN ('DIR *.%1 /B /S') DO (
MKDIR "%%~nF"
MOVE "%%~nF.%1" "%%~nF"
)

ENDLOCAL

:END
ECHO DONE.