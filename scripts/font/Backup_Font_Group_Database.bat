:: DESCRIPTION
:: Backs up a Corel Graphics Suite FontNav font group database from hard-coded directories?

:: DEPENDENCIES
:: WinRar? I would like to update this to use 7z.

:: USAGE
:: - I don't know. Rework this if you use it at all. See list under CODE comment
:: - From a command prompt, run this script, or just double-click it from Windows Explorer:
::    Backup_Font_Group_Database.bat


:: CODE
:: TO DO
:: - If I even continue to use this, update it to use 7-zip command line.
:: - Wouldn't it be better ot create the archive to begin with using a time stamp file name?
:: - Parameterize the directories? Was this run from the same dir as the database? I'd rather run it from anywhere.

:: color 2A
for /f "tokens=2-7 delims=/:. " %%a in ("%date% %time%") do (set DateTime=%%c-%%a-%%b__%%d.%%e.%%f)
copy %username%_fontdbase_backup.rar Previous_fontdbase_backups\%DateTime%__%username%_fontdbase_backup.rar
"C:\Program Files\WinRAR\WinRar" -ep1 -as -r U -o+ %username%_fontdbase_backup.rar "C:\Program Files\Corel\CorelDRAW Graphics Suite 13\FontNav\*"
