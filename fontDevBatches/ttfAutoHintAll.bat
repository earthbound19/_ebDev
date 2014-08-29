@echo off

SETLOCAL ENABLEDELAYEDEXPANSION

if '%1' equ '' set /p 1=If you don't intend to encode every file of that type in the directory which you're running this command from, press CTRL+C. If this is your intent, type anything else, then press ENTER.

for /f "tokens=* delims= " %%F in ('DIR *.ttf /B ') do (
REN %%F _%%F
COPY _%%F %%F
ttfautohint -i -l 8 -r 50 -G 0 -x 0 -w "GD" -W -p "_%%F" "%%~nF.ttf"
DEL _%%F
)

REM prior version of ttfautohint might have used the -f argument to designate input file? The batch was formerly thus; it broke on new version. The batch as-is now (modified to discard the -f argument) works. These were the arguments for the prior version:
REM ttfautohint -i -l 8 -r 50 -G 0 -x 0 -w "GD" -W -p -f "%%F" "%%~nF_TTFAutoHinted.ttf"

REM Changed batch to make a copy of the source ttf, autohint from the copy, save to the original file name, and delete the copy. 08/29/2014 11:47:07 AM -RAH