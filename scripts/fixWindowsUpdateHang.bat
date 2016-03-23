REM NOTE: run this as an Administrator.
REM re: https://support.microsoft.com/en-us/kb/2700567 and http://answers.microsoft.com/en-us/windows/forum/all/windows-update-hangs-on-checking-for-updates/b762abf5-655c-4a60-aabc-9f59785bd8d9 and http://answers.microsoft.com/en-us/windows/forum/windows_other-update/windows-update-application-hang-on-windows-7/787e6deb-69df-49d7-b7f8-eae1990dd1c2 and http://answers.microsoft.com/en-us/windows/forum/all/windows-update-on-windows-7-hangs-on-checking-for/93d85732-e066-452c-82cd-e34515fa6b7d and http://answers.microsoft.com/en-us/windows/forum/all/windows-update-hangs-on-checking-for-updates/b762abf5-655c-4a60-aabc-9f59785bd8d9 (did I already list that? :) and http://answers.microsoft.com/en-us/windows/forum/all/windows-update-on-windows-7-hangs-on-checking-for/93d85732-e066-452c-82cd-e34515fa6b7d (or that? :) 
NET STOP wuauserv
NET STOP bits
NET STOP cryptsvc
NET STOP msiserver
DEL "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
DEL %systemroot%\system32\catroot2\Edb.log
MKDIR emptyTempDir
ROBOCOPY emptyTempDir C:\Windows\System32\catroot2 /E /PURGE
ROBOCOPY emptyTempDir %systemroot%\SoftwareDistribution /E /PURGE
RMDIR emptyTempDir
CD /D %windir%\system32
regsvr32.exe atl.dll
regsvr32.exe urlmon.dll
regsvr32.exe mshtml.dll
regsvr32.exe shdocvw.dll
regsvr32.exe browseui.dll
regsvr32.exe jscript.dll
regsvr32.exe vbscript.dll
regsvr32.exe scrrun.dll
regsvr32.exe msxml.dll
regsvr32.exe msxml3.dll
regsvr32.exe msxml6.dll
regsvr32.exe actxprxy.dll
regsvr32.exe softpub.dll
regsvr32.exe wintrust.dll
regsvr32.exe dssenh.dll
regsvr32.exe rsaenh.dll
regsvr32.exe gpkcsp.dll
regsvr32.exe sccbase.dll
regsvr32.exe slbcsp.dll
regsvr32 /u mssip32.dll
regsvr32.exe cryptdlg.dll
regsvr32.exe oleaut32.dll
regsvr32.exe ole32.dll
regsvr32.exe shell32.dll
regsvr32.exe initpki.dll
regsvr32.exe wuapi.dll
regsvr32.exe wuaueng.dll
regsvr32.exe wuaueng1.dll
regsvr32.exe wucltui.dll
regsvr32.exe wups.dll
regsvr32.exe wups2.dll
regsvr32.exe wuweb.dll
regsvr32.exe qmgr.dll
regsvr32.exe qmgrprxy.dll
regsvr32.exe wucltux.dll
regsvr32.exe muweb.dll
regsvr32.exe wuwebv.dll
netsh reset winsock
net start bits
net start cryptsvc
REM net start wuauserv
ECHO DONE. If Updates still fail, install the newest windows update agent, reboot, manually stop the Windows Installer service, and try updating again. Maybe try uninstalling KB2533552 if that fails (and try again).