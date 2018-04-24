REM READ THESE FIRST COMMENTS IF NOTHING ELSE: I do not guarantee that this batch file will not blow up your computer. Use at your own risk, and before any sweeping operations of any kind (like this), BACKUP YOUR CRITICAL DATA.

REM DESCRIPTION
REM Cleans unnecessary junk files--often anywhere between ~1-16 GB or more!--from a typical fully updated and well-used Windows installation. It does this by way of the built-in robocopy command, intructed to sync temp folders with an empty folder in multiple threads (faster than rd/rmdir). You may wish to read all of the REM comments in this file before running it. By junk I mean files which will not ever be used; e.g. *.dmp *.temp, *.tmp, and optionally all *.bak files on the drive. (Side note: NTLite will get you still ~4GB more garbage cleanup!)--but use that cautiously.)

REM USAGE
REM Run this as an Administrator, or from a console with Administrator rights. This is designed for Windows 7, untested on prior and newer versions of Windows (it may or may not work on those; I don't know).

REM WARNING
REM This script errs on the side of clearing possibly too much unused junk on your computer. If you've examined the contents of this batch, and you know what you're doing, and/or you're doing this in a test environment, press <enter> If you actually don't need to clear a ton of space, CLOSE THIS CONSOLE.

REM eh, probably as well or better: for /D %d in (*) do rmdir /S /Q "%d"
REM re (can't seem to link to comment directly!) : https://social.technet.microsoft.com/Forums/windows/en-US/6b8d5a57-2929-44d1-93ef-a9d825d9e17a/how-can-i-disable-this-folder-is-shared-with-other-people-message?forum=w7itprogeneral

REM 06/20/2015 12:08:03 PM RAH Added Cache and cache2 folders to list of folders to wipe clean via robowipeTempDirList.txt

REM BATCH STEPS:
REM Wipe all temp files from so many temp directories and custom directories (as delineated by the user in a text file, and as found with a search) by "tricking" the ROBOCOPY command to wipe everything in a destination directory that is not found in a deliberately empty source directory. It will also do so with a number of threads matching the number of system cores (CPUS) times 3. This is basically RMDIR on steroids for temp file cleanup.

REM RE: http://serverfault.com/questions/409948/what-are-these-tmp-directories-for-and-if-can-they-be-eliminated-how
REM RE: http://stackoverflow.com/questions/8844868/what-are-the-undocumented-features-and-limitations-of-the-windows-findstr-comman
REM RE: http://www.techrepublic.com/blog/windows-and-office/use-the-pushd-popd-commands-for-quick-network-drive-mapping-in-windows-7/
REM RE: http://stackoverflow.com/a/14499141

REM Save the current directory and go to the root:
PUSHD %CD%
CD /
REM Check for existence of empty stub dir; if it already exists, warn user and exit.
REM Make temporary robowipeStubDir:
MKDIR robowipeStubDir
REM (Re)-create a list of all temp folders
	REM Had been trying to do the following with %~d0\ which is irrelevant after discovering the PUSDH and POPD commands:
DIR * /AD /B /S | FINDSTR /E /I \temp > robowipeTempDirList.txt
DIR * /AD /B /S | FINDSTR /E /I \cache >> robowipeTempDirList.txt
DIR * /AD /B /S | FINDSTR /E /I \cache2 >> robowipeTempDirList.txt
REM Set number of threads to number of processors * 3
SET /A NUM = %NUMBER_OF_PROCESSORS% * 3

REM Delete all files in those folders (as described), and also all files in a custom folder list if it exists:
REM in development: TYPE robowipelist.txt >> robowipeTempDirList.txt

FOR /F "delims=*" %%A IN (robowipeTempDirList.txt) DO (
REM ECHO WOULD HERE WIPE DIRECTORY %%A ...
ROBOCOPY robowipeStubDir "%%A" /E /PURGE /MT:%NUM% /W:0 /R:0
)

REM Delete all *.dmp files in all directories on the drive.
REM NOTE: To NOT also delete all .bak files on a drive (this is a common extension name for needful backups), comment out the last line in this group:
DEL /S *.dmp *.temp *.tmp *.log
REM DEL /S *.bak

REM Remove temporary robowipe files:
DEL robowipeTempDirList.txt
RMDIR robowipeStubDir

POPD


REM Everything else that follows in this script is re: http://arstechnica.com/civis/viewtopic.php?f=15&t=1162579

REM NOTE: To NOT regain about the amount of RAM you have installed (in hard drive space) by turning off hibernation, comment out the next line by typing REM<space> at the start of it:
powercfg /h off

REM Remove uninstallers for service packs:
dism /online /cleanup-image /spsuperseded


REM Wipe everything in c:\windows\softwaredistribution by "tricking" ROBOCOPY into syncing it with a temporarily created empty directory. 
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


REM DEVELOPMENT HISTORY
REM Before now: Many thing.
REM 2016-07-26 Added /W:0 and /R:0 flags to skip file delete/other failures (zero retries) re: http://pureinfotech.com/robocopy-recover-and-skip-files-with-errors-from-bad-hard-drive-in-windows/