:: DESCRIPTION
:: READ THE WARNING under usage. This batch script cleans unnecessary junk files--often anywhere between ~1-16 GB or more!--from a typical fully updated and well-used Windows installation. It does this by way of the built-in ROBOCOPY command, instructed to sync temp folders with an empty folder in multiple threads (faster than rd/rmdir). You may wish to read all of the REM comments in this file before running it. By junk I mean files which will not ever be used; e.g. *.dmp *.temp, *.tmp, and optionally all *.bak files on the drive. (Side note: NTLite will get you still ~4GB more garbage cleanup!)--but use that cautiously.)

:: WARNINGS
:: - This batch file may delete files or cause other effects you do not want it to. Use at your own risk, and before any sweeping operations of any kind (like this), BACKUP YOUR CRITICAL DATA.
:: - This script errs on the side of clearing possibly too much unused junk on your computer. If you've examined the contents of this batch, and you know what you're doing, and/or you're doing this in a test environment, press <enter>. If you actually don't need to clear a ton of space, CLOSE THIS CONSOLE.
:: - I have seen this script wipe permanent license-enabling files which should be stored or named in a way that enables permanence instead be wiped because some engineer made the silly decision to store permanent files in locations and names that indicate something temporary (like "temp" in the name or ".log" for the file extension).
:: USAGE
:: Run this as an Administrator, or from a console with Administrator rights:
::    RoboWipe.bat


:: CODE
:: TO DO
:: Test if recursive directory delete commands would work instead?

:: BATCH STEPS
:: Wipe all temp files from so many temp directories and custom directories (as delineated by the user in a text file, and as found with a search) by "tricking" the ROBOCOPY command to wipe everything in a destination directory that is not found in a deliberately empty source directory. It will also do so with a number of threads matching the number of system cores (CPUS) times 3. This is basically RMDIR on steroids for temp file cleanup.

:: RE: http://serverfault.com/questions/409948/what-are-these-tmp-directories-for-and-if-can-they-be-eliminated-how
:: RE: http://stackoverflow.com/questions/8844868/what-are-the-undocumented-features-and-limitations-of-the-windows-findstr-comman
:: RE: http://www.techrepublic.com/blog/windows-and-office/use-the-pushd-popd-commands-for-quick-network-drive-mapping-in-windows-7/
:: RE: http://stackoverflow.com/a/14499141

:: Save the current directory and go to the root:
PUSHD %CD%
CD /
:: Check for existence of empty stub dir; if it already exists, warn user and exit.
:: Make temporary robowipeStubDir:
MKDIR robowipeStubDir

:: Copy the contents of the following delete folders list into the delete list for this batch:
TYPE robowipelist.txt > robowipeTempDirList.txt

:: (Re)-create a list of all temp folders
	:: Had been trying to do the following with %~d0\ which is irrelevant after discovering the PUSDH and POPD commands:
DIR * /AD /B /S | FINDSTR /E /I \temp >> robowipeTempDirList.txt
DIR * /AD /B /S | FINDSTR /E /I \cache >> robowipeTempDirList.txt
DIR * /AD /B /S | FINDSTR /E /I \cache2 >> robowipeTempDirList.txt
DIR * /AD /B /S | FINDSTR /E /I \caches >> robowipeTempDirList.txt
:: Set number of threads to number of processors * 3
SET /A NUM = %NUMBER_OF_PROCESSORS% * 3

FOR /F "delims=*" %%A IN (robowipeTempDirList.txt) DO (
:: ECHO WOULD HERE WIPE DIRECTORY %%A ...
ROBOCOPY robowipeStubDir "%%A" /E /PURGE /MT:%NUM% /W:0 /R:0
)

:: Delete all *.dmp files in all directories on the drive.
:: NOTE: To NOT also delete all .bak files on a drive (this is a common extension name for needful backups), comment out the last line in this group:
DEL /S *.dmp *.temp *.tmp *.log
:: DEL /S *.bak

:: Remove temporary robowipe files:
DEL robowipeTempDirList.txt
RMDIR robowipeStubDir

POPD

:: Everything else that follows in this script is re: http://arstechnica.com/civis/viewtopic.php?f=15&t=1162579

:: NOTE: To NOT regain about the amount of RAM you have installed (in hard drive space) by turning off hibernation, comment out the next line by typing REM<space> at the start of it:
powercfg /h off

:: Remove uninstallers for service packs:
dism /online /cleanup-image /spsuperseded

:: Wipe everything in c:\windows\softwaredistribution by "tricking" ROBOCOPY into syncing it with a temporarily created empty directory. 
PUSHD %CD%
CD c:\windows\softwaredistribution
IF EXIST cleanupTemp (
ECHO cleanupTemp directory already exists! Manually remove that directory, then run this batch again.
) ELSE (
net stop wuauserv
MKDIR cleanupTemp
SET /A NUM = %NUMBER_OF_PROCESSORS% * 3
ROBOCOPY cleanupTemp c:\windows\softwaredistribution /E /PURGE /MT:%NUM%
RMDIR cleanupTemp
)

POPD


:: DEVELOPMENT HISTORY
:: 2019-07-03 06:07 AM added custom delete list (via robowipelist.txt) functionality
:: 2016-07-26 Added /W:0 and /R:0 flags to skip file delete/other failures (zero retries) re: http://pureinfotech.com/ROBOCOPY-recover-and-skip-files-with-errors-from-bad-hard-drive-in-windows
:: 2015-06-20 12:08:03 PM RAH Added Cache and cache2 folders to list of folders to wipe clean via robowipeTempDirList.txt
:: Before now: Many thing.