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
set datestamp=%date:~-4%_%date:~-10,-8%_%date:~-7,-5%__%time:~0,2%_%time:~3,2%_%time:~6,2%

copy %username%_fontdbase_backup.rar Previous_fontdbase_backups\%datestamp%__%username%_fontdbase_backup.rar
"C:\Program Files\WinRAR\WinRar" -ep1 -as -r U -o+ %username%_fontdbase_backup.rar "C:\Program Files\Corel\CorelDRAW Graphics Suite 13\FontNav\*"
