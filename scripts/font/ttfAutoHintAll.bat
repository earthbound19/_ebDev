:: DESCRIPTION
:: Autohints all ttf format files in the current directory, via ttfautohint.exe.

:: WARNING
:: If it is important to keep earlier revisions of files that this script would update, only run this script on files that you have backed up. It overwrites files without warning!

:: USAGE
:: From a command prompt opened to a directory with TrueType font files to be autohinted, run this script:
::    ttfAutoHintAll.bat


:: CODE
@echo off

SETLOCAL ENABLEDELAYEDEXPANSION

for /f "tokens=* delims= " %%F in ('DIR *.ttf /B ') do (
REN %%F _%%F
COPY _%%F %%F
ttfautohint -i -l 8 -r 50 -G 0 -x 0 -w "GD" -W -p "_%%F" "%%~nF.ttf"
DEL _%%F
)


:: DEVELOPER NOTES
:: - A prior version of ttfautohint might have used the -f argument to designate input file? The batch was formerly this way; it broke on new version. The batch as-is now (modified to discard the -f argument) works. These were the arguments for the prior version:
:: ttfautohint -i -l 8 -r 50 -G 0 -x 0 -w "GD" -W -p -f "%%F" "%%~nF_TTFAutoHinted.ttf"
:: - Changed batch to make a copy of the source ttf, autohint from the copy, save to the original file name, and delete the copy. 08/29/2014 11:47:07 AM -RAH