@echo off
REM this script will rip images out of all movie files of a given type into subdirectories.
REM Uh, or will it? This looks like an encoding script. Hrm.

REM Horked and adapted from: http://www.computerhope.com/forum/index.php?topic=78901.0
REM Code to find parent directory of file adapted from: http://serverfault.com/questions/112057/getting-the-last-two-tokens-in-batch-script-for-command
REM Note the escape sequence %% before the .avi output file, which outputs only a % on the command line (otherwise, the % sign does not appear at all).

SETLOCAL ENABLEDELAYEDEXPANSION

if '%1' equ '' set /p fName=Enter file name extensions (without a .dot) for the files you would like to rip the frames from:

for /f "tokens=* delims= " %%F in ('DIR *.%1 /B /S') do (
MKDIR "%%~nF\frames"
REM ffmpeg -i "%%F" -f image2 "%%~nF\frames\%%7d.png"
REM if you also want to rip the source to an uncompressed .avi file, uncomment the following two lines:
FOR /D %%I IN ("%%F\..") DO (SET PARENTDIR=%%~nxI)
ffmpeg -i "%%F" -pix_fmt yuv420p -vcodec rawvideo -acodec adpcm_ima_wav !PARENTDIR!\%%~nF.avi
)

REM reference: http://superuser.com/questions/347433/how-to-create-an-uncompressed-avi-from-a-series-of-1000s-of-png-images-using-ff
REM also, ffprobe reports my iPhone .mov sources use this pixel format (yuv420p), and these avis load into Sony Vegas without any problems.