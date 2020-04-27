ECHO OFF
  REM MonitorAndBackupDirTo7z.bat periodically backs up a source directory structure (with files) into a .7z archive, named by an archive target name and the the date and time of the backup. The source folder to back up, the target archive name, the backup interval, and an optional process to suspend are all easily user-configurable--see the "User-specified variables" comment below.
  REM by Richard Alexander Hall, http://earthbound.io/blog/contact
  REM I release this work into the Public Domain.

REM NOTE DEPENDENCIES;
REM This batch relies on all of the following being either in the same directory you run this batch from, or in your PATH environment variable (it's a techy thing--do an internet search on it). All of them are freeware:
  REM 1) 7zip (7z.exe). Get it from http://7-zip.org/
  REM 2) sfk.exe, which is the "Swiss Army Knife" utility collection--so many useful functions and programs merged into one super-program. Get it from: http://stahlworks.com/
  REM 3) (Optional) Process.exe, a Command Line Process Viewer/Killer/Suspender for Windows. Get it from: http://retired.beyondlogic.org/solutions/processutil/processutil.htm In my tests, it was (unusually) unable to suspend the javaw.exe process that runs Minecraft; maybe a Java service obnoxiously resumes the process if anything else suspends it? It generally works better at suspending/resuming processes than anything else I've found (and I searched very extensively).

REM ALSO NOTE: set the SOURCE_DIR and DEST_DIR variables (in the first SET commands) to the appropriate directory you wish to archive. This batch will create the archive directory if it does not exist. Also optionally set the name of an executable which manipulates the files you wish to archive (for example, set the command to SET PAUSE_AND_RESUME_EXE=Minecraft.exe), so that Process.exe will pause that process before backup and resume the process after. (This is to avoid the problem of backing up files which fall out of sync with other files during backup--if in fact that's a problem. Hence the "optional.") Also, set BACKUP_MINUTES_INTERVAL to the number of minutes you wish for this batch to wait between backups.

REM Finally, you can cancel execution of this batch from the Windows console by pressing CTRL+C, then Y.

REM === THE SCRIPT ===

REM User-specified variables.
SET SOURCE_DIR=Minecraft
SET DEST_DIR=minecraft_backup
SET PAUSE_AND_RESUME_PROCESS=
REM for example: SET PAUSE_AND_RESUME_PROCESS=javaw.exe
SET BACKUP_MINUTES_INTERVAL=12
REM Compression level 0 is storage (no compression), 9 is ultra compression:
SET COMPRESSION_LEVEL=0

REM Script-created variable.
SET /A BACKUP_SECONDS_INTERVAL = %BACKUP_MINUTES_INTERVAL% * 60

REM Create archive directory if it does not exist.
IF NOT EXIST %DEST_DIR% MKDIR %DEST_DIR%

REM The main, useful loop.
:LOOP

REM Pause applicable executable, if any.
PROCESS -S %PAUSE_AND_RESUME_PROCESS%
ROBOCOPY %SOURCE_DIR% %DEST_DIR% /MIR /MT[:%NUMBER_OF_PROCESSORS%]
  REM switch not used for monitoring and backing up every 6 minutes (since this loop's TIMEOUT command accomplishes that) : /MOT:6
  REM Yes, we could just operate directly on SOURCE_DIR with 7zip. I prefer copying the directory because that won't produce inordinate slowdown (from compression) of bare files backup *if* any compression level higher than "storage" is used.

REM 7zip the copied directory structure into one archive file prefixed by year/date/time formatting that actually makes sense to a simple file "sort by name" view.
REM Resume applicable executable, if any.
PROCESS -R %PAUSE_AND_RESUME_PROCESS%

  REM A batch breakthrough in passing files to a command is given in the most up-voted answer here: http://stackoverflow.com/questions/1746475/windows-batch-help-in-setting-a-variable-from-command-output
  REM ALSO! Awesome, simple solution: http://stackoverflow.com/a/19024533/1397555

REM format date and time stamp for use in a filename, then use it to determine the archive filename.
sfk time h-m-s > temp_time.txt
SET /P TIMESTAMP=< temp_time.txt
7z a %DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%_%TIMESTAMP%__%DEST_DIR%.7z %SOURCE_DIR% -r x=%COMPRESSION_LEVEL% mt=on

REM We could here delete the temporary archive to save diskspace, but if we leave it there, ROBOCOPY will backup to it faster (it will only copy/delete/move files which have changed between the source and backup directories). If you want to wipe that temporary backup directory, uncomment the four lines of this batch, and then wipe that puppy. He's got crap all over his bottom.
REM MKDIR roboWipeTemp
REM ROBOCOPY roboWipeTemp %DEST_DIR% /MIR /MT[:%NUMBER_OF_PROCESSORS%]
REM RMDIR roboWipeTemp
REM RMDIR %DEST_DIR%

REM Wait the number of seconds of this variable before looping back to the start of this section via GOTO.
TIMEOUT /T %BACKUP_SECONDS_INTERVAL%
GOTO:LOOP

REM === END SCRIPT ===