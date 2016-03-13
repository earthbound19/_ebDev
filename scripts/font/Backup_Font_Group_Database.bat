color 2A
for /f "tokens=2-7 delims=/:. " %%a in ("%date% %time%") do (set DateTime=%%c-%%a-%%b__%%d.%%e.%%f)
copy %username%_fontdbase_backup.rar Previous_fontdbase_backups\%DateTime%__%username%_fontdbase_backup.rar
"C:\Program Files\WinRAR\WinRar" -ep1 -as -r U -o+ %username%_fontdbase_backup.rar "C:\Program Files\Corel\CorelDRAW Graphics Suite 13\FontNav\*"
