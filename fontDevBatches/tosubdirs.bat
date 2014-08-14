ECHO OFF

REM move all files of a the given extension(s) (as may be passed to this script) into subdirectories named after each files' name.

SETLOCAL ENABLEDELAYEDEXPANSION

ECHO =============
ECHO Whichever directory you call this batch from, it will create subdirectories named after every one of the file type extensions you specify; then move those files respectively into those subdirectories. For example, if you call this script with <tosubdirs ttf>, it will creade subdirectories named after every .ttf file in the directory, and then move those ttf files into those directories (of matching name).
ECHO =============

IF '%1' equ '' SET /p 1=If you don't intend to do this for file type x, press CTRL+C. IF this is your intent, press any other key.

FOR /f "tokens=* delims= " %%F IN ('DIR *.%1 /B /S') DO (
MKDIR "%%~nF"
MOVE "%%~nF.%1" "%%~nF"
)
