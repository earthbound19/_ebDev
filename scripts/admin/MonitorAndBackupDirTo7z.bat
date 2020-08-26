:: DESCRIPTION
:: Periodically backs up a source directory structure (with files) into a .7z archive, named by an archive target name and the the date and time of the backup. The source folder to back up, the target archive name, the backup interval, and an optional process to suspend are all easily user-configurable--see the "User-specified variables" comment below.

:: DEPENDENCIES
:: These need to be in your PATH:
:: - 7zip (7z.exe). Get it from http://7-zip.org/
:: - sfk.exe, which is the "Swiss Army Knife" utility collection--so many useful functions and programs merged into one super-program. Get it from: http://stahlworks.com/
:: - OPTIONAL. process.exe Command Line Process Viewer/Killer/Suspender for Windows, from beyondlogic.org.

:: USAGE
:: - Hack the SOURCE_DIR and DEST_DIR variables (in the first SET commands after the CODE comment) to the appropriate directory you wish to archive. This batch will create the archive directory if it does not exist. Also optionally set the name of an executable which manipulates the files you wish to archive (for example, set the command to SET PAUSE_AND_RESUME_EXE=Minecraft.exe), so that process.exe will pause that process before backup and resume the process after. (This is to avoid the problem of backing up files which fall out of sync with other files during backup--if in fact that's a problem. Hence the "optional.") Also, set BACKUP_MINUTES_INTERVAL to the number of minutes you wish for this batch to wait between backups.
:: - With those preparations in place, run this script without any parameters:
::        MonitorAndBackupDirTo7z.bat
:: - Finally, you can cancel execution of this batch from the Windows console by pressing CTRL+C, then Y.

:: CODE
:: - In my tests, process.exe was (unusually) [(un?)]able to suspend the javaw.exe process that runs Minecraft; maybe a Java service obnoxiously resumes the process if anything else that suspends it? It generally works better at suspending/resuming processes than anything else I've found (and I searched very extensively).

:: User-specified variables.
SET SOURCE_DIR=Minecraft
SET DEST_DIR=minecraft_backup
SET PAUSE_AND_RESUME_PROCESS=
:: for example: SET PAUSE_AND_RESUME_PROCESS=javaw.exe
SET BACKUP_MINUTES_INTERVAL=12
:: Compression level 0 is storage (no compression), 9 is ultra compression:
SET COMPRESSION_LEVEL=0

:: Script-created variable.
SET /A BACKUP_SECONDS_INTERVAL = %BACKUP_MINUTES_INTERVAL% * 60

:: Create archive directory if it does not exist.
IF NOT EXIST %DEST_DIR% MKDIR %DEST_DIR%

:: The main, useful loop.
:LOOP

:: Pause applicable executable, if any.
PROCESS -S %PAUSE_AND_RESUME_PROCESS%
ROBOCOPY %SOURCE_DIR% %DEST_DIR% /MIR /MT[:%NUMBER_OF_PROCESSORS%]
:: switch not used for monitoring and backing up every 6 minutes (since this loop's TIMEOUT command accomplishes that) : /MOT:6
:: Yes, we could just operate directly on SOURCE_DIR with 7zip. I prefer copying the directory because that won't produce inordinate slowdown (from compression) of bare files backup *if* any compression level higher than "storage" is used.

:: 7zip the copied directory structure into one archive file prefixed by year/date/time formatting that actually makes sense to a simple file "sort by name" view.
:: Resume applicable executable, if any.
PROCESS -R %PAUSE_AND_RESUME_PROCESS%

:: A batch breakthrough in passing files to a command is given in the most up-voted answer here: http://stackoverflow.com/questions/1746475/windows-batch-help-in-setting-a-variable-from-command-output
:: ALSO! Awesome, simple solution: http://stackoverflow.com/a/19024533/1397555

:: format date and time stamp for use in a filename, then use it to determine the archive filename.
sfk time h-m-s > temp_time.txt
SET /P TIMESTAMP=< temp_time.txt
7z a %DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%_%TIMESTAMP%__%DEST_DIR%.7z %SOURCE_DIR% -r x=%COMPRESSION_LEVEL% mt=on

:: We could here delete the temporary archive to save diskspace, but if we leave it there, ROBOCOPY will backup to it faster (it will only copy/delete/move files which have changed between the source and backup directories). If you want to wipe that temporary backup directory, uncomment the four lines of this batch, and then wipe that puppy. He's got crap all over his bottom.
:: MKDIR roboWipeTemp
:: ROBOCOPY roboWipeTemp %DEST_DIR% /MIR /MT[:%NUMBER_OF_PROCESSORS%]
:: RMDIR roboWipeTemp
:: RMDIR %DEST_DIR%

:: Wait the number of seconds of this variable before looping back to the start of this section via GOTO.
TIMEOUT /T %BACKUP_SECONDS_INTERVAL%
GOTO:LOOP