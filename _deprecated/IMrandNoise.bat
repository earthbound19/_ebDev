ECHO OFF
REM WARNING: As good practice, backup any images you work from before running this. It shouldn't change the original images, though. Also, this will not work if there are spaces in any of the folders or in the filename of the full image PATH (and it is also good practice to avoid that).

REM This relies on the ImageMagick toolset (mogrify specifically), and generates pseudorandom color noise from every image you pass to this batch. At this writing, the images may be passed to this batch from another folder if it is done from the command line, e.g.:

REM -- with IMrandNoise.bat in your %PATH%, and with an open console in the directory location D:\Alex\Art\_Abstractions_series\src\00032-00372\_resources_for_00031-00372 :
REM IMrandNoise.bat *.tif

REM It will create a subfolder named IMrandNoise_output in the same directory of whatever image file(s) it processes.

REM You can force output to a given image size by changing the parameter (in this batch) of the -resize switch accordingly.

REM The output is deterministic from -seed %%J (which can be simply replaced with any number via the %%j .. (x,y,z) for loop, where x is the start number, y is the interval, and z is the end number. Note that the %%j loop will produce so many seed variants of *every* image you pass to the batch. It is deterministic, meaning that if you give it the same number in the %%j for loop, you will always get the same output from any given file.

REM Thanks to these posts:
REM http://www.imagemagick.org/discourse-server/viewtopic.php?t=21324#p86984
REM http://www.imagemagick.org/discourse-server/viewtopic.php?t=12768
REM http://serverfault.com/a/59026/121188

REM 09/04/2015 09:07:38 AM -RAH

SETLOCAL ENABLEDELAYEDEXPANSION

FOR %%I IN (%*) DO (
set driveletter=%%~dI
set filepath=%%~pI
set filename=%%~nxI
set filenameNoExt=%%~nI

IF NOT EXIST !driveletter!!filepath!IMrandNoise_output MKDIR !driveletter!!filepath!IMrandNoise_output
	FOR /L %%J IN (5894,1,5896) DO (
		IF NOT EXIST !driveletter!!filepath!IMrandNoise_output\!filename!__IMrandomNoise_seed-%%J.png (
		ECHO ================================================================================ COMMENCE MONSTRO MOGRIFY NOISE CREATION COMMAND . . .
		mogrify -write !driveletter!!filepath!IMrandNoise_output\!filename!__IMrandomNoise_seed-%%J.png -seed %%J -resize 1080x720! xc: +noise Random %%I >> !driveletter!!filepath!IMrandNoise_output\_IMrandNoiseRunLog.txt
		ECHO RRRRWAAAAARGH^^!^^! DONE.
		) ELSE (
		ECHO ================================================================================ IMAGE !driveletter!!filepath!IMrandNoise_output\!filename!__IMrandomNoise_seed-%%J.png already exists; skipping render.
		)
	)
)

ECHO ================================================================================ DONE. Any target files that already existed via these batch settings were ignored. Check the above output for any errors and adjust your workflow as necessary. If there were errors, and you attempt to correct for them and run this batch again, it will attempt to recreate the files (and if the error is not corrected, it will fail again). I apologize that at this writing it may produce only vague errors.

ENDLOCAL